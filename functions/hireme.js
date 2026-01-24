// functions/src/hireme.js
const { onCall, HttpsError } = require('firebase-functions/v2/https');
const admin = require('firebase-admin');
const db = admin.firestore();

function requireAuth(request) {
  const uid = request.auth?.uid;
  if (!uid) throw new HttpsError('unauthenticated', 'Login required');
  return uid;
}
function assertString(v, name) {
  if (!v || typeof v !== 'string') throw new HttpsError('invalid-argument', `${name} is required`);
}
function assertOneOf(v, name, allowed) {
  if (!allowed.includes(v)) throw new HttpsError('invalid-argument', `${name} must be one of: ${allowed.join(', ')}`);
}

/**
 * 1) createHireMeContract
 * Creates a contract in paymentPendingInitial. Amount is derived from freelancer rates.
 */
exports.createHireMeContract = onCall({ cors: true, invoker: 'public' }, async (request) => {
  const uid = requireAuth(request);

  const { freelancerId, pricingType } = request.data || {};
  assertString(freelancerId, 'freelancerId');
  assertString(pricingType, 'pricingType');
  assertOneOf(pricingType, 'pricingType', ['hourly', 'daily', 'project']);

  if (freelancerId === uid) throw new HttpsError('failed-precondition', 'Cannot hire yourself');

  const freelancerSnap = await db.collection('team').doc(freelancerId).get();
  if (!freelancerSnap.exists) throw new HttpsError('not-found', 'Freelancer not found');

  const u = freelancerSnap.data() || {};
  const rates = {
    hourlyRate: u.hourlyRate,
    dailyRate: u.dailyRate,
    projectRate: u.projectRate,
  };

  const currency = (u.currency || 'EUR').toString();

  let rate = null;          // hourly/daily
  let kickoffAmount = null; // project
  let initialAmount = null;

  if (pricingType === 'hourly') {
    rate = Number(rates.hourlyRate);
    if (!Number.isFinite(rate) || rate <= 0)
    {
     console.log('DEBUG freelancer doc id:', freelancerId);
      console.log('DEBUG freelancer data keys:', Object.keys(u || {}));
      console.log('DEBUG freelancer hourlyRate raw:', u.hourlyRate);
      console.log('DEBUG freelancer hireMeRates:', u.hireMeRates);
    throw new HttpsError('failed-precondition', 'Missing/invalid hourlyRate');}
    initialAmount = +(rate * 1).toFixed(2);
  } else if (pricingType === 'daily') {
    rate = Number(rates.dailyRate);
    if (!Number.isFinite(rate) || rate <= 0) throw new HttpsError('failed-precondition', 'Missing/invalid dailyRate');
    initialAmount = +(rate * 1).toFixed(2);
  } else {
    kickoffAmount = Number(rates.projectRate);
    if (!Number.isFinite(kickoffAmount) || kickoffAmount <= 0) {
      throw new HttpsError('failed-precondition', 'Missing/invalid projectKickoffAmount');
    }
    initialAmount = +kickoffAmount.toFixed(2);
  }

  const contractRef = db.collection('contracts').doc();
  const contractId = contractRef.id;

  await contractRef.set({
    source: 'hireMe',
    type: 'hireMe',
    pricingType,
    currency,

    clientId: uid,
    freelancerId,

    // pricing
    rate: rate ?? null,
    kickoffAmount: kickoffAmount ?? null,

    // prepaid: first payment is REAL
    prepaidUnits: (pricingType === 'project') ? null : 1,
    prepaidAmount: (pricingType === 'project') ? initialAmount : null,

    // amounts
    initialAmount,
    grossAmount: initialAmount, // may become final later
    paidAmount: 0,

    // agreement
    agreement: {
      status: 'none',     // none | offered | accepted | cancelled
      quantity: null,     // hours/days (integer)
      notes: null,
      offeredAt: null,
      offeredBy: null,
      acceptedAt: null,
      acceptedBy: null,
    },

    // final locked fields after accept
    agreedUnits: null,
    additionalPaidUnits: null,
    remainingDue: null,

    hireStage: 'initial',
    status: 'paymentPendingInitial',

    conversationId: null,
    provider: null,
    paymentRef: null,

    platformFeeRate: null,
    platformFee: null,
    freelancerNet: null,

    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  return { contractId, initialAmount, currency };
});

/**
 * 2) freelancer sends offer inside chat
 * Allowed only after chatUnlocked
 */
exports.sendHireOfferByConversation = onCall(
  { cors: true, invoker: 'public' },
  async (request) => {
    const uid = requireAuth(request);
    const { conversationId, quantity, totalAmount, notes } = request.data || {};
    assertString(conversationId, 'conversationId');

    const cleanNotes =
      typeof notes === 'string' && notes.trim() ? notes.trim() : null;

    await db.runTransaction(async (tx) => {
      const convRef = db.collection('conversations').doc(conversationId);
      const convSnap = await tx.get(convRef);
      if (!convSnap.exists) throw new HttpsError('not-found', 'Conversation not found');

      const conv = convSnap.data() || {};
      const contractId = conv.contractId;
      if (!contractId) throw new HttpsError('failed-precondition', 'Conversation missing contractId');

      const contractRef = db.collection('contracts').doc(contractId);
      const cSnap = await tx.get(contractRef);
      if (!cSnap.exists) throw new HttpsError('not-found', 'Contract not found');

      const c = cSnap.data() || {};
      if (c.type !== 'hireMe') throw new HttpsError('failed-precondition', 'Not a hireMe contract');
      if (c.freelancerId !== uid) throw new HttpsError('permission-denied', 'Only freelancer can send offer');
      if (c.status !== 'chatUnlocked') throw new HttpsError('failed-precondition', `Not ready. status=${c.status}`);

      // build agreement + message
      const agreementPatch = {
        ...(c.agreement || {}),
        status: 'offered',
        notes: cleanNotes,
        offeredAt: admin.firestore.FieldValue.serverTimestamp(),
        offeredBy: uid,
      };

      const meta = {
        pricingType: c.pricingType,
        notes: cleanNotes,
      };

      let text = '';

      if (c.pricingType === 'project') {
        const total = Number(totalAmount);
        if (!Number.isFinite(total) || total <= 0) {
          throw new HttpsError('invalid-argument', 'totalAmount must be a positive number');
        }

        agreementPatch.totalAmount = total;

        text = `📝 Project Offer: ${total} ${c.currency}`;
        meta.totalAmount = total;
        meta.currency = c.currency ?? null;
      } else {
        const qty = Number(quantity);
        if (!Number.isInteger(qty) || qty <= 0) {
          throw new HttpsError('invalid-argument', 'quantity must be positive integer');
        }

        agreementPatch.quantity = qty;

        const unitWord = c.pricingType === 'daily' ? 'days' : 'hours';
        text = `📝 Offer: ${qty} ${unitWord} @ ${c.rate} ${c.currency}`;

        meta.quantity = qty;
        meta.rate = c.rate ?? null;
        meta.currency = c.currency ?? null;
      }

      // single contract update (مرة واحدة فقط)
      tx.update(contractRef, {
        agreement: agreementPatch,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // message
      const msgRef = convRef.collection('messages').doc();
      tx.set(msgRef, {
        type: 'offer',
        senderId: uid,
        text,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        meta,
      });

      // conversation lastMessage + unread
      const participants = Array.isArray(conv.participants) ? conv.participants : [];
      const otherUid = participants.find((p) => p !== uid) || null;
      const unread = (conv.unread && typeof conv.unread === 'object') ? conv.unread : {};
      const otherUnread = otherUid ? Number(unread[otherUid] ?? 0) : 0;

      const patch = {
        lastMessageAt: admin.firestore.FieldValue.serverTimestamp(),
        lastMessageText: text,
        lastMessageSenderId: uid,
        [`unread.${uid}`]: 0,
      };
      if (otherUid) patch[`unread.${otherUid}`] = otherUnread + 1;

      tx.set(convRef, patch, { merge: true });
    });

    return { ok: true };
  }
);


/**
 * 3) client accepts offer => locks remainingDue and flips to paymentPendingRemaining
 * NO MONEY taken here. UI will start checkout after getting contractId.
 */
exports.acceptHireOfferPrepareRemainingPayment = onCall({ cors: true, invoker: 'public' }, async (request) => {
  const uid = requireAuth(request);
  const { conversationId } = request.data || {};
  assertString(conversationId, 'conversationId');

  const out = await db.runTransaction(async (tx) => {
    const convRef = db.collection('conversations').doc(conversationId);
    const convSnap = await tx.get(convRef);
    if (!convSnap.exists) throw new HttpsError('not-found', 'Conversation not found');
    const conv = convSnap.data() || {};

    const contractId = conv.contractId;
    if (!contractId) throw new HttpsError('failed-precondition', 'Conversation missing contractId');

    const contractRef = db.collection('contracts').doc(contractId);
    const cSnap = await tx.get(contractRef);
    if (!cSnap.exists) throw new HttpsError('not-found', 'Contract not found');
    const c = cSnap.data();

    if (c.type !== 'hireMe') throw new HttpsError('failed-precondition', 'Not a hireMe contract');
    if (c.clientId !== uid) throw new HttpsError('permission-denied', 'Only client can accept');
    if (c.status !== 'chatUnlocked') throw new HttpsError('failed-precondition', `Not in chatUnlocked. status=${c.status}`);
    if ((c.agreement?.status || 'none') !== 'offered') throw new HttpsError('failed-precondition', 'No offered agreement');


      // ---------- compute remaining due ----------
      let remainingDue = 0;
      let totalGross = 0;

      // meta for message
      const meta = {
        pricingType: c.pricingType,
      };

      if (c.pricingType === 'project') {
        const total = Number(c.agreement?.totalAmount);
        if (!Number.isFinite(total) || total <= 0) {
          throw new HttpsError('failed-precondition', 'Invalid project offer totalAmount');
        }

        // what has already been paid (prepaid) from the initial 1st payment
        const alreadyPaid = Number(c.paidAmount ?? 0);
        const prepaid = Number.isFinite(alreadyPaid) ? alreadyPaid : 0;

        remainingDue = +(Math.max(0, total - prepaid).toFixed(2));
        totalGross = +total.toFixed(2);

        meta.totalAmount = totalGross;
        meta.prepaidAmount = +prepaid.toFixed(2);

        tx.update(contractRef, {
          agreement: {
            ...(c.agreement || {}),
            status: 'accepted',
            acceptedAt: admin.firestore.FieldValue.serverTimestamp(),
            acceptedBy: uid,
          },

          agreedTotalAmount: totalGross,
          remainingDue,

          grossAmount: totalGross, // lock final total
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),

          hireStage: 'pendingRemaining',
          status: 'paymentPendingRemaining',
        });
      } else {
        const qty = Number(c.agreement?.quantity);
        if (!Number.isInteger(qty) || qty <= 0) {
          throw new HttpsError('failed-precondition', 'Invalid offer quantity');
        }

        const prepaid = Number(c.prepaidUnits ?? 1);
        const remainingUnits = Math.max(0, qty - prepaid);

        const rate = Number(c.rate);
        if (!Number.isFinite(rate) || rate <= 0) {
          throw new HttpsError('failed-precondition', 'Missing rate');
        }

        remainingDue = +(remainingUnits * rate).toFixed(2);
        totalGross = +(qty * rate).toFixed(2);

        meta.qty = qty;
        meta.prepaidUnits = prepaid;
        meta.remainingUnits = remainingUnits;
        meta.rate = +rate.toFixed(2);

        tx.update(contractRef, {
          agreement: {
            ...(c.agreement || {}),
            status: 'accepted',
            acceptedAt: admin.firestore.FieldValue.serverTimestamp(),
            acceptedBy: uid,
          },

          agreedUnits: qty,
          additionalPaidUnits: remainingUnits,
          remainingDue,

          grossAmount: totalGross, // lock final total
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),

          hireStage: 'pendingRemaining',
          status: 'paymentPendingRemaining',
        });
      }

      // ---------- conversation lastMessage + unread ----------
      const participants = Array.isArray(conv.participants) ? conv.participants : [];
      const otherUid = participants.find((p) => p !== uid) || null;
      const unread = (conv.unread && typeof conv.unread === 'object') ? conv.unread : {};
      const otherUnread = otherUid ? Number(unread[otherUid] ?? 0) : 0;

      const msgText = `✅ Offer accepted. Remaining due: ${remainingDue}`;

      const patch = {
        lastMessageAt: admin.firestore.FieldValue.serverTimestamp(),
        lastMessageText: msgText,
        lastMessageSenderId: uid,
        [`unread.${uid}`]: 0,
      };
      if (otherUid) patch[`unread.${otherUid}`] = otherUnread + 1;
      tx.set(convRef, patch, { merge: true });

      // ---------- system message ----------
      const msgRef = convRef.collection('messages').doc();
      tx.set(msgRef, {
        type: 'system',
        senderId: uid,
        text: msgText,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        meta: { ...meta, remainingDue, totalGross },
      });

      return { contractId, remainingDue, currency: c.currency, totalGross };
    });

    return { ok: true, ...out };
  }
);

/**
 * 4) client says: no agreement
 * Policy A: first payment is consultation => no refund, close conversation.
 */
exports.cancelHireNoAgreementByConversation = onCall({ cors: true, invoker: 'public' }, async (request) => {
  const uid = requireAuth(request);
  const { conversationId } = request.data || {};
  assertString(conversationId, 'conversationId');

  await db.runTransaction(async (tx) => {
    const convRef = db.collection('conversations').doc(conversationId);
    const convSnap = await tx.get(convRef);
    if (!convSnap.exists) throw new HttpsError('not-found', 'Conversation not found');
    const conv = convSnap.data() || {};

    const contractId = conv.contractId;
    if (!contractId) throw new HttpsError('failed-precondition', 'Conversation missing contractId');

    const contractRef = db.collection('contracts').doc(contractId);
    const cSnap = await tx.get(contractRef);
    if (!cSnap.exists) throw new HttpsError('not-found', 'Contract not found');
    const c = cSnap.data();

    if (c.type !== 'hireMe') throw new HttpsError('failed-precondition', 'Not a hireMe contract');
    if (c.clientId !== uid) throw new HttpsError('permission-denied', 'Only client can cancel');
    if (c.status !== 'chatUnlocked') throw new HttpsError('failed-precondition', `Cannot cancel now. status=${c.status}`);
    if ((c.agreement?.status || 'none') === 'accepted') throw new HttpsError('failed-precondition', 'Already accepted');

    tx.update(contractRef, {
      status: 'cancelledNoAgreement',
      hireStage: 'chatUnlocked',
      agreement: { ...(c.agreement || {}), status: 'cancelled' },
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    tx.set(convRef, { status: 'closed', closedAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true });
// update conversation lastMessage + unread
    const participants = Array.isArray(conv.participants) ? conv.participants : [];
    const otherUid = participants.find((p) => p !== uid) || null;
    const unread = (conv.unread && typeof conv.unread === 'object') ? conv.unread : {};
    const otherUnread = otherUid ? Number(unread[otherUid] ?? 0) : 0;

    const patch = {
      lastMessageAt: admin.firestore.FieldValue.serverTimestamp(),
      lastMessageText: '❌ No agreement. Contract closed. First payment is treated as consultation and is non-refundable.',
      lastMessageSenderId: uid,
      [`unread.${uid}`]: 0,
    };
    if (otherUid) patch[`unread.${otherUid}`] = otherUnread + 1;
    tx.set(convRef, patch, { merge: true });

    const msgRef = convRef.collection('messages').doc();
    tx.set(msgRef, {
      type: 'system',
      senderId: uid,
      text: '❌ No agreement. Contract closed. First payment is treated as consultation and is non-refundable.',
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });


  });

  return { ok: true };
});


exports.rejectHireOfferByConversation = onCall({ cors: true, invoker: 'public' }, async (request) => {
  const uid = requireAuth(request);

  const { conversationId, reason } = request.data || {};
  assertString(conversationId, 'conversationId');

  const reasonText = (typeof reason === 'string' && reason.trim())
      ? reason.trim()
      : 'Offer rejected';

  await db.runTransaction(async (tx) => {
    const convRef = db.collection('conversations').doc(conversationId);
    const convSnap = await tx.get(convRef);
    if (!convSnap.exists) throw new HttpsError('not-found', 'Conversation not found');
    const conv = convSnap.data() || {};

    const contractId = conv.contractId;
    if (!contractId) throw new HttpsError('failed-precondition', 'Conversation missing contractId');

    const contractRef = db.collection('contracts').doc(contractId);
    const cSnap = await tx.get(contractRef);
    if (!cSnap.exists) throw new HttpsError('not-found', 'Contract not found');
    const c = cSnap.data() || {};

    if (c.type !== 'hireMe') throw new HttpsError('failed-precondition', 'Not a hireMe contract');
    if (c.clientId !== uid) throw new HttpsError('permission-denied', 'Only client can reject offer');

    if (c.status !== 'chatUnlocked') {
      throw new HttpsError('failed-precondition', `Cannot reject now. status=${c.status}`);
    }

    const aStatus = (c.agreement && c.agreement.status) ? c.agreement.status : 'none';
    if (aStatus !== 'offered') {
      throw new HttpsError('failed-precondition', 'No offered agreement to reject');
    }


    tx.update(contractRef, {
      agreement: {
        ...(c.agreement || {}),
        status: 'none',
        quantity: null,
        notes: null,
        offeredAt: null,
        offeredBy: null,
        acceptedAt: null,
        acceptedBy: null,
        rejectedAt: admin.firestore.FieldValue.serverTimestamp(),
        rejectedBy: uid,
        rejectReason: reasonText,
      },
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // رسالة system بالشات
    const msgRef = convRef.collection('messages').doc();
    const text = '❌ Offer rejected. Freelancer can send a new offer.';
    tx.set(msgRef, {
      type: 'system',
      senderId: uid,
      text: text+'\nReason: '+reasonText,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      meta: { action: 'rejectOffer', reason: reasonText },
    });

    // تحديث lastMessage + unread (بنفس طريقتك)
    const participants = Array.isArray(conv.participants) ? conv.participants : [];
    const otherUid = participants.find((p) => p !== uid) || null;
    const unread = (conv.unread && typeof conv.unread === 'object') ? conv.unread : {};
    const otherUnread = otherUid ? Number(unread[otherUid] ?? 0) : 0;

    const patch = {
      lastMessageAt: admin.firestore.FieldValue.serverTimestamp(),
      lastMessageText: `${text} Reason: ${reasonText}`,
      lastMessageSenderId: uid,
      [`unread.${uid}`]: 0,
    };
    if (otherUid) patch[`unread.${otherUid}`] = otherUnread + 1;

    tx.set(convRef, patch, { merge: true });
  });

  return { ok: true };
});

