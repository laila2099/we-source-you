// functions/src/contracts.js
const { onCall, HttpsError } = require('firebase-functions/v2/https');
const { onSchedule } = require('firebase-functions/v2/scheduler');
const admin = require('firebase-admin');

const db = admin.firestore();

const DAY_MS = 24 * 60 * 60 * 1000;

function requireAuth(request) {
  const uid = request.auth?.uid;
  if (!uid) throw new HttpsError('unauthenticated', 'Login required');
  return uid;
}

function assertString(v, name) {
  if (!v || typeof v !== 'string') {
    throw new HttpsError('invalid-argument', `${name} is required`);
  }
}

function nowTs() {
  return admin.firestore.Timestamp.now();
}

function tsPlusDays(days) {
  const now = Date.now();
  return admin.firestore.Timestamp.fromMillis(now + days * DAY_MS);
}

function resolvePayoutFromUser(u) {
  const profiles = u.payoutProfile && typeof u.payoutProfile === 'object' ? u.payoutProfile : {};

  const def = (u.payoutDefault || '').toString();

  // ترتيب fallback منطقي: default -> أي متاح
  const provider =
    def === 'paypal' || def === 'stripe'
      ? def
      : profiles.paypal?.enabled && profiles.paypal?.paypalEmail
        ? 'paypal'
        : profiles.stripe?.enabled && profiles.stripe?.stripeConnectAccountId
          ? 'stripe'
          : null;

  if (!provider) return { ok: false, reason: 'Payout setup required' };

  if (provider === 'paypal') {
    const email = profiles.paypal?.paypalEmail || null;
    if (!email) return { ok: false, reason: 'PayPal payout not setup' };
    return {
      ok: true,
      payoutProvider: 'paypal',
      destination: { paypalPayoutEmail: email },
    };
  }

  if (provider === 'stripe') {
    const acct = profiles.stripe?.stripeConnectAccountId || null;
    if (!acct) return { ok: false, reason: 'Stripe payout not setup' };
    return {
      ok: true,
      payoutProvider: 'stripe',
      destination: { stripeConnectAccountId: acct },
    };
  }

  return { ok: false, reason: 'Unsupported payout provider' };
}

async function getContractFromConversation(tx, conversationId) {
  const convRef = db.collection('conversations').doc(conversationId);
  const convSnap = await tx.get(convRef);
  if (!convSnap.exists) throw new HttpsError('not-found', 'Conversation not found');

  const conv = convSnap.data();
  const contractId = conv.contractId;
  if (!contractId) throw new HttpsError('failed-precondition', 'conversation missing contractId');

  const contractRef = db.collection('contracts').doc(contractId);
  const contractSnap = await tx.get(contractRef);
  if (!contractSnap.exists) throw new HttpsError('not-found', 'Contract not found');

  return { convRef, conv, contractRef, contractSnap, contractId };
}

/**
 * (internal) create payout record + close contract + close conversation
 * idempotent: if already paidOut => no-op
 */
function buildDestinationFromPayoutProfile(payoutProfile) {
  if (!payoutProfile || !payoutProfile.provider) return null;

  if (payoutProfile.provider === 'paypal') {
    const email = (payoutProfile.paypalEmail || '').trim();
    if (!email) return null;
    return { paypalPayoutEmail: email };
  }

  if (payoutProfile.provider === 'stripe') {
    const acct = (payoutProfile.stripeConnectAccountId || '').trim();
    if (!acct) return null;
    return { stripeConnectAccountId: acct };
  }

  return null;
}

function finalizePayoutTx(tx, { contractRef, contractId, contract, convRef, payoutProfile }) {
  if (contract.status === 'paidOut') {
    return { already: true, payoutId: contract.payoutId || null };
  }

  // لازم يكون deliveryApproved + عندنا clientApprovedAt + freelancerApprovedAt
  if (contract.status !== 'deliveryApproved') {
    throw new HttpsError('failed-precondition', `Not payable yet. status=${contract.status}`);
  }
  const clientOk = !!contract.approvals?.clientApprovedAt;
  const freelancerOk = !!contract.approvals?.freelancerApprovedAt;
  if (!clientOk || !freelancerOk) {
    throw new HttpsError('failed-precondition', 'Both approvals required');
  }

  // ✅ NEW: payout setup required
  const destination = buildDestinationFromPayoutProfile(payoutProfile);
  if (!destination) {
    throw new HttpsError('failed-precondition', 'Payout setup required');
  }
  const payoutProvider = payoutProfile.provider;

  const payoutRef = db.collection('payouts').doc();

  tx.set(payoutRef, {
    contractId,
    clientId: contract.clientId,
    freelancerId: contract.freelancerId,

    // provider/paymentRef هدول تبع الدفع من الكلينت (اختياري نخليهم)
    provider: contract.provider || null,
    paymentRef: contract.paymentRef || null,

    currency: contract.currency || 'EUR',
    grossAmount: contract.grossAmount ?? null,
    platformFeeRate: contract.platformFeeRate ?? null,
    platformFee: contract.platformFee ?? null,
    freelancerNet: contract.freelancerNet ?? null,

    // ✅ NEW fields for payout sending
    payoutProvider, // 'stripe' | 'paypal'
    destination, // {stripeConnectAccountId} OR {paypalPayoutEmail}

    status: 'queued', // بدل recorded
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  tx.update(contractRef, {
    status: 'payoutQueued',
    payoutQueuedAt: admin.firestore.FieldValue.serverTimestamp(),
    payoutId: payoutRef.id,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  // close conversation
  tx.set(
    convRef,
    {
      status: 'closed',
      closedAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    },
    { merge: true },
  );

  return { already: false, payoutId: payoutRef.id };
}

/**
 * freelancer submit delivery
 * funded/inProgress -> submitted
 */
const ALLOWED = ['text', 'link', 'zip', 'files'];

exports.submitDeliveryByConversation = onCall(
  { cors: true, invoker: 'public' },
  async (request) => {
    const uid = requireAuth(request);

    const { conversationId, submissionType, submissionData } = request.data || {};
    assertString(conversationId, 'conversationId');
    assertString(submissionType, 'submissionType');

    if (!ALLOWED.includes(submissionType)) {
      throw new HttpsError(
        'invalid-argument',
        `submissionType must be one of: ${ALLOWED.join(', ')}`,
      );
    }

    // validate payload
    const data = submissionData || {};

    if (submissionType === 'text') {
      if (typeof data.text !== 'string' || !data.text.trim()) {
        throw new HttpsError('invalid-argument', 'submissionData.text is required');
      }
    }

    if (submissionType === 'link') {
      if (typeof data.url !== 'string' || !data.url.trim()) {
        throw new HttpsError('invalid-argument', 'submissionData.url is required');
      }
    }

    if (submissionType === 'zip') {
      if (typeof data.zipRef !== 'string' || !data.zipRef.trim()) {
        throw new HttpsError('invalid-argument', 'submissionData.zipRef is required');
      }
    }

    if (submissionType === 'files') {
      if (!Array.isArray(data.files) || data.files.length === 0) {
        throw new HttpsError('invalid-argument', 'submissionData.files must be a non-empty array');
      }
      for (const f of data.files) {
        if (!f || typeof f.fileRef !== 'string' || !f.fileRef.trim()) {
          throw new HttpsError('invalid-argument', 'Each file must have fileRef');
        }
      }
    }

    await db.runTransaction(async (tx) => {
      const convRef = db.collection('conversations').doc(conversationId);
      const msgRef = convRef.collection('messages').doc();

      const convSnap = await tx.get(convRef);
      if (!convSnap.exists) throw new HttpsError('not-found', 'Conversation not found');
      const conv = convSnap.data() || {};

      const { contractRef, contractSnap } = await getContractFromConversation(tx, conversationId);
      const c = contractSnap.data();

      if (c.freelancerId !== uid) {
        throw new HttpsError('permission-denied', 'Only freelancer can submit');
      }

      if (!['funded', 'inProgress'].includes(c.status)) {
        throw new HttpsError('failed-precondition', 'Contract not submittable now');
      }

      // 1) update contract
      tx.update(contractRef, {
        status: 'submitted',
        delivery: {
          submissionType,
          submissionData: data,
          submittedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // 2) add a delivery message (this is what your UI needs)
      tx.set(msgRef, {
        type: 'delivery',
        senderId: uid,
        text: '📦 Delivery submitted',
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        meta: {
          submissionType,
          // خفيفة: خزّني meta بس بدون blobs كبيرة
          submissionData: data,
        },
      });

      // 3) update conversation last message + unread counts
      const participants = Array.isArray(conv.participants) ? conv.participants : [];
      if (!participants.includes(uid)) {
        throw new HttpsError('permission-denied', 'Not a participant');
      }

      const otherUid = participants.find((p) => p !== uid) || null;
      const unread = conv.unread && typeof conv.unread === 'object' ? conv.unread : {};
      const otherUnread = otherUid ? Number(unread[otherUid] ?? 0) : 0;

      const patch = {
        lastMessageAt: admin.firestore.FieldValue.serverTimestamp(),
        lastMessageText: '📦 Delivery submitted',
        lastMessageSenderId: uid,
        [`unread.${uid}`]: 0,
      };

      if (otherUid) {
        patch[`unread.${otherUid}`] = otherUnread + 1; // زيدي للطرف التاني
      }

      tx.set(convRef, patch, { merge: true });
    });

    return { ok: true };
  },
);

/**
 * client approves delivery
 * submitted -> deliveryApproved
 */
exports.approveDeliveryByConversation = onCall(
  { cors: true, invoker: 'public' },
  async (request) => {
    const uid = requireAuth(request);

    const { conversationId } = request.data || {};
    assertString(conversationId, 'conversationId');

    await db.runTransaction(async (tx) => {
      const { contractRef, contractSnap } = await getContractFromConversation(tx, conversationId);
      const c = contractSnap.data();

      if (c.clientId !== uid) throw new HttpsError('permission-denied', 'Only client can approve');
      if (c.status !== 'submitted')
        throw new HttpsError('failed-precondition', 'Not in submitted state');

      tx.update(contractRef, {
        status: 'deliveryApproved',
        approvals: {
          ...(c.approvals || {}),
          clientApprovedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    });

    return { ok: true };
  },
);

/**
 * freelancer confirms close
 * deliveryApproved -> set freelancerApprovedAt -> finalize payout (record + close)
 */
exports.confirmCloseByConversation = onCall({ cors: true, invoker: 'public' }, async (request) => {
  const uid = requireAuth(request);
  const { conversationId } = request.data || {};
  assertString(conversationId, 'conversationId');

  const out = await db.runTransaction(async (tx) => {
    const { convRef, contractRef, contractSnap, contractId } = await getContractFromConversation(
      tx,
      conversationId,
    );

    const c = contractSnap.data();

    if (c.freelancerId !== uid) {
      throw new HttpsError('permission-denied', 'Only freelancer can confirm close');
    }
    if (c.status !== 'deliveryApproved') {
      throw new HttpsError('failed-precondition', 'Must be deliveryApproved first');
    }

    // ============================
    // ✅ NEW: enforce payoutProfile
    // ============================
    const userRef = db.collection('users').doc(uid);
    const userSnap = await tx.get(userRef);
    const u = userSnap.exists ? userSnap.data() || {} : {};

    const profiles = u.payoutProfile && typeof u.payoutProfile === 'object' ? u.payoutProfile : {};

    // default provider: payoutDefault -> legacy.provider
    const chosenProvider = (u.payoutDefault || '').toString();

    // build a single payoutProfile object (same shape as before)
    let payoutProfile = null;

    if (chosenProvider === 'paypal') {
      const email = profiles.paypal?.paypalEmail || null;

      if (!email) throw new HttpsError('failed-precondition', 'Payout setup required');

      payoutProfile = { provider: 'paypal', paypalEmail: email };
    } else if (chosenProvider === 'stripe') {
      const acct = profiles.stripe?.stripeConnectAccountId || null;

      if (!acct) throw new HttpsError('failed-precondition', 'Payout setup required');

      payoutProfile = { provider: 'stripe', stripeConnectAccountId: acct };
    } else {
      // إذا ما في default ولا legacy
      throw new HttpsError('failed-precondition', 'Payout setup required');
    }

    // سجل موافقة الفريلانسر
    tx.update(contractRef, {
      approvals: {
        ...(c.approvals || {}),
        freelancerApprovedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    const c2 = {
      ...c,
      approvals: {
        ...(c.approvals || {}),
        freelancerApprovedAt: true,
      },
    };

    // ✅ finalize payout + paidOut داخل tx
    return finalizePayoutTx(tx, {
      contractRef,
      contractId,
      contract: c2,
      convRef,
      payoutProfile, // ✅ NEW
    });
  });

  return { ok: true, payoutId: out.payoutId, alreadyPaidOut: out.already };
});

/**
 * open dispute
 * - client can open when submitted or deliveryApproved
 * - any party can open when paidOut and within disputeDeadline
 */
exports.openDisputeByConversation = onCall({ cors: true, invoker: 'public' }, async (request) => {
  const uid = requireAuth(request);
  const { conversationId, reason } = request.data || {};
  assertString(conversationId, 'conversationId');

  const disputeId = await db.runTransaction(async (tx) => {
    const { convRef, contractRef, contractSnap, contractId } = await getContractFromConversation(
      tx,
      conversationId,
    );
    const c = contractSnap.data();

    const isClient = c.clientId === uid;
    const isFreelancer = c.freelancerId === uid;
    if (!isClient && !isFreelancer) throw new HttpsError('permission-denied', 'Not a participant');

    if (c.status === 'disputeOpen') {
      // idempotent: إذا أصلاً نزاع مفتوح
      return c.disputeId || null;
    }

    const now = Date.now();
    const disputeDeadline = c.disputeDeadline?.toDate?.()?.getTime?.();

    const allowed =
      (isClient && (c.status === 'submitted' || c.status === 'deliveryApproved')) ||
      ((isClient || isFreelancer) &&
        c.status === 'paidOut' &&
        disputeDeadline &&
        now <= disputeDeadline);

    if (!allowed) {
      throw new HttpsError('failed-precondition', `Cannot open dispute at status=${c.status}`);
    }

    const disputeRef = db.collection('disputes').doc();

    tx.set(disputeRef, {
      contractId,
      conversationId,
      openedBy: uid,
      status: 'opened',
      reason: typeof reason === 'string' ? reason : null,
      openedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    tx.update(contractRef, {
      status: 'disputeOpen',
      disputeId: disputeRef.id,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    tx.set(
      convRef,
      { status: 'disputeOpen', updatedAt: admin.firestore.FieldValue.serverTimestamp() },
      { merge: true },
    );

    return disputeRef.id;
  });

  return { ok: true, disputeId };
});

/**
 * releasePayout manual (optional)
 * only support/admin later
 */
exports.releasePayout = onCall({ cors: true, invoker: 'public' }, async (request) => {
  const uid = requireAuth(request);
  const { conversationId } = request.data || {};
  assertString(conversationId, 'conversationId');

  const out = await db.runTransaction(async (tx) => {
    const { convRef, contractRef, contractSnap, contractId } = await getContractFromConversation(
      tx,
      conversationId,
    );
    const c = contractSnap.data();

    const isParty = c.clientId === uid || c.freelancerId === uid;
    if (!isParty) throw new HttpsError('permission-denied', 'Not a participant');

    return finalizePayoutTx(tx, { contractRef, contractId, contract: c, convRef });
  });

  return { ok: true, payoutId: out.payoutId, alreadyPaidOut: out.already };
});

// ========================
// Scheduled auto rules
// ========================

const AUTO_CLIENT_APPROVE_DAYS = 3;
const AUTO_FREELANCER_CONFIRM_DAYS = 3;

/**
 * submitted + no client action X days => auto approve delivery (clientApprovedAt)
 */
exports.autoApproveSubmitted = onSchedule('every 60 minutes', async () => {
  const cutoff = admin.firestore.Timestamp.fromMillis(
    Date.now() - AUTO_CLIENT_APPROVE_DAYS * DAY_MS,
  );

  const qs = await db
    .collection('contracts')
    .where('status', '==', 'submitted')
    .where('delivery.submittedAt', '<=', cutoff)
    .limit(100)
    .get();

  const tasks = qs.docs.map(async (doc) => {
    const contractRef = doc.ref;

    await db.runTransaction(async (tx) => {
      const snap = await tx.get(contractRef);
      if (!snap.exists) return;
      const c = snap.data();

      if (c.status !== 'submitted') return;

      tx.update(contractRef, {
        status: 'deliveryApproved',
        approvals: {
          ...(c.approvals || {}),
          clientApprovedAt: admin.firestore.FieldValue.serverTimestamp(),
          autoClientApproved: true,
        },
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    });
  });

  await Promise.all(tasks);
});

/**
 * deliveryApproved + freelancer didn't confirm X days => auto confirm freelancer + finalize payout
 */
exports.autoPayoutAfterClientApprove = onSchedule('every 60 minutes', async () => {
  const cutoff = admin.firestore.Timestamp.fromMillis(
    Date.now() - AUTO_FREELANCER_CONFIRM_DAYS * DAY_MS,
  );

  const qs = await db
    .collection('contracts')
    .where('status', '==', 'deliveryApproved')
    .where('approvals.clientApprovedAt', '<=', cutoff)
    .limit(100)
    .get();

  const tasks = qs.docs.map(async (doc) => {
    const contractRef = doc.ref;

    await db.runTransaction(async (tx) => {
      const snap = await tx.get(contractRef);
      if (!snap.exists) return;
      const c = snap.data();

      if (c.status !== 'deliveryApproved') return;
      if (c.status === 'paidOut') return;
      if (c.status === 'disputeOpen') return;

      // إذا الفريلانسر وافق خلاص
      if (c.approvals?.freelancerApprovedAt) return;

      // لازم يكون في conversationId لنقفل الشات
      const convId = c.conversationId;
      if (!convId) return;

      const convRef = db.collection('conversations').doc(convId);

      // سجل موافقة الفريلانسر تلقائياً
      tx.update(contractRef, {
        approvals: {
          ...(c.approvals || {}),
          freelancerApprovedAt: admin.firestore.FieldValue.serverTimestamp(),
          autoFreelancerApproved: true,
        },
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // نفّذ payout
      finalizePayoutTx(tx, { contractRef, contractId: c.id || doc.id, contract: c, convRef });
    });
  });

  await Promise.all(tasks);
});

exports.rejectDeliveryByConversation = onCall(
  { cors: true, invoker: 'public' },
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) throw new HttpsError('unauthenticated', 'Login required');

    const { conversationId, reason } = request.data || {};
    if (!conversationId) throw new HttpsError('invalid-argument', 'conversationId is required');

    const reasonText =
      typeof reason === 'string' && reason.trim() ? reason.trim() : 'Delivery rejected';

    await db.runTransaction(async (tx) => {
      const convRef = db.collection('conversations').doc(conversationId);
      const convSnap = await tx.get(convRef);
      if (!convSnap.exists) throw new HttpsError('not-found', 'Conversation not found');

      const conv = convSnap.data() || {};
      const contractId = conv.contractId;
      if (!contractId)
        throw new HttpsError('failed-precondition', 'Conversation missing contractId');

      const contractRef = db.collection('contracts').doc(contractId);
      const cSnap = await tx.get(contractRef);
      if (!cSnap.exists) throw new HttpsError('not-found', 'Contract not found');

      const c = cSnap.data() || {};
      if (c.clientId !== uid)
        throw new HttpsError('permission-denied', 'Only client can reject delivery');

      if (c.status !== 'submitted') {
        throw new HttpsError('failed-precondition', `Cannot reject now. status=${c.status}`);
      }

      // ✅ رجعها ل inProgress
      tx.update(contractRef, {
        status: 'inProgress',
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),

        // optional: سجل آخر رفض
        lastRejection: {
          reason: reasonText,
          at: admin.firestore.FieldValue.serverTimestamp(),
          by: uid,
        },
      });

      // رسالة System بالشات
      const msgRef = convRef.collection('messages').doc();
      const text = '❌ Delivery rejected. Please resubmit.';

      tx.set(msgRef, {
        type: 'system',
        senderId: uid,
        text: text + '\nReason: ' + reasonText,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        meta: { action: 'rejectDelivery', reason: reasonText },
      });

      // تحديث آخر رسالة + unread
      const participants = Array.isArray(conv.participants) ? conv.participants : [];
      const otherUid = participants.find((p) => p !== uid) || null;
      finalUnreadPatch(tx, convRef, conv, uid, otherUid, text + '\nReason: ' + reasonText);
    });

    return { ok: true };
  },
);

function finalUnreadPatch(tx, convRef, conv, senderUid, otherUid, lastText) {
  const unread = conv.unread && typeof conv.unread === 'object' ? conv.unread : {};
  const otherUnread = otherUid ? Number(unread[otherUid] ?? 0) : 0;

  const patch = {
    lastMessageAt: admin.firestore.FieldValue.serverTimestamp(),
    lastMessageText: lastText,
    lastMessageSenderId: senderUid,
    [`unread.${senderUid}`]: 0,
  };
  if (otherUid) patch[`unread.${otherUid}`] = otherUnread + 1;

  tx.set(convRef, patch, { merge: true });
}
