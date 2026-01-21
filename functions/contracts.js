// functions/src/contracts.js
const { onCall, HttpsError } = require('firebase-functions/v2/https');
const admin = require('firebase-admin');
const db = admin.firestore();

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

  return { convRef, conv, contractRef, contractSnap };
}

/**
 * freelancer submit delivery
 * status: funded/inProgress -> submitted
 * stores delivery payload
 */

exports.submitDeliveryByConversation = onCall({ cors: true, invoker: 'public' }, async (request) => {
  const uid = request.auth?.uid;
  if (!uid) throw new HttpsError('unauthenticated', 'Login required');

  const { conversationId, submissionType, submissionData } = request.data || {};
  if (!conversationId) throw new HttpsError('invalid-argument', 'conversationId is required');
  if (!submissionType) throw new HttpsError('invalid-argument', 'submissionType is required');

  await db.runTransaction(async (tx) => {
    const { contractRef, contractSnap } = await getContractFromConversation(tx, conversationId);
    const c = contractSnap.data();

    if (c.freelancerId !== uid) throw new HttpsError('permission-denied', 'Only freelancer can submit');
    if (!['funded', 'inProgress'].includes(c.status)) {
      throw new HttpsError('failed-precondition', 'Contract not submittable now');
    }

    tx.update(contractRef, {
      status: 'submitted',
      delivery: {
        submissionType,
        submissionData: submissionData ?? null,
        submittedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  });

  return { ok: true };
});


/**
 * client approves delivery
 * status: submitted -> deliveryApproved
 */
exports.approveDeliveryByConversation = onCall({ cors: true, invoker: 'public' }, async (request) => {
  const uid = request.auth?.uid;
  if (!uid) throw new HttpsError('unauthenticated', 'Login required');

  const { conversationId } = request.data || {};
  if (!conversationId) throw new HttpsError('invalid-argument', 'conversationId is required');

  await db.runTransaction(async (tx) => {
    const { contractRef, contractSnap } = await getContractFromConversation(tx, conversationId);
    const c = contractSnap.data();

    if (c.clientId !== uid) throw new HttpsError('permission-denied', 'Only client can approve');
    if (c.status !== 'submitted') throw new HttpsError('failed-precondition', 'Not in submitted state');

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
});


/**
 * freelancer confirms close
 * status: deliveryApproved -> triggers releasePayout
 *
 * NOTE: we do NOT pay from Flutter.
 * We call server releasePayout which finalizes + closes chat.
 */
exports.confirmCloseByConversation = onCall({ cors: true, invoker: 'public' }, async (request) => {
  const uid = request.auth?.uid;
  if (!uid) throw new HttpsError('unauthenticated', 'Login required');

  const { conversationId } = request.data || {};
  if (!conversationId) throw new HttpsError('invalid-argument', 'conversationId is required');

  const DAY_MS = 24 * 60 * 60 * 1000;

  await db.runTransaction(async (tx) => {
    const { convRef, contractRef, contractSnap } = await getContractFromConversation(tx, conversationId);
    const c = contractSnap.data();

    if (c.freelancerId !== uid) throw new HttpsError('permission-denied', 'Only freelancer can confirm close');
    if (c.status !== 'deliveryApproved') {
      throw new HttpsError('failed-precondition', 'Must be deliveryApproved first');
    }

    const now = admin.firestore.Timestamp.now();
    const paidOutAt = now;
    const disputeDeadline = admin.firestore.Timestamp.fromMillis(now.toMillis() + 14 * DAY_MS);
    const downloadDeadline = admin.firestore.Timestamp.fromMillis(now.toMillis() + 90 * DAY_MS);

    // ✅ close contract
    tx.update(contractRef, {
      status: 'paidOut',
      paidOutAt,
      disputeDeadline,
      downloadDeadline,
      approvals: {
        ...(c.approvals || {}),
        freelancerApprovedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // ✅ close conversation
    tx.set(
      convRef,
      {
        status: 'closed',
        closedAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true }
    );
  });

  return { ok: true };
});


/**
 * releasePayout (MVP)
 * - checks contract
 * - sets paidOut + deadlines
 * - closes conversation to read-only
 * - writes payout record (no real Stripe transfer yet)
 */
exports.releasePayout = onCall({ cors: true, invoker: 'public' }, async (request) => {
  const uid = requireAuth(request);
  const { contractId } = request.data;
  assertString(contractId, 'contractId');

  const contractRef = db.collection('contracts').doc(contractId);

  const payoutId = await db.runTransaction(async (tx) => {
    const cSnap = await tx.get(contractRef);
    if (!cSnap.exists) throw new HttpsError('not-found', 'Contract not found');
    const c = cSnap.data();

    // allow client or freelancer to trigger (or support later)
    const isParty = c.clientId === uid || c.freelancerId === uid;
    if (!isParty) throw new HttpsError('permission-denied', 'Not a participant');

    if (c.status === 'paidOut') {
      return c.payoutId || null; // idempotent
    }

    if (c.status !== 'deliveryApproved') {
      throw new HttpsError('failed-precondition', `Not payable yet. status=${c.status}`);
    }

    // optional: require both approvals
    const clientOk = !!c.approvals?.clientApprovedAt;
    const freelancerOk = !!c.approvals?.freelancerApprovedAt;
    if (!clientOk || !freelancerOk) {
      throw new HttpsError('failed-precondition', 'Both approvals required');
    }

    const disputeDeadline = nowPlusDays(14);
    // لعقود jobs فيها ملفات تسليم: خلي downloadDeadline 90 يوم (غيريها إذا بدك)
    const downloadDeadline = nowPlusDays(90);

    const payoutRef = db.collection('payouts').doc();
    const payoutDoc = {
      contractId,
      clientId: c.clientId,
      freelancerId: c.freelancerId,
      provider: c.provider || null,
      paymentRef: c.paymentRef || null,
      grossAmount: c.grossAmount ?? null,
      platformFeeRate: c.platformFeeRate ?? null,
      platformFee: c.platformFee ?? null,
      freelancerNet: c.freelancerNet ?? null,
      status: 'recorded', // later: 'sent' when real payout done
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    tx.set(payoutRef, payoutDoc);

    tx.update(contractRef, {
      status: 'paidOut',
      paidOutAt: admin.firestore.FieldValue.serverTimestamp(),
      disputeDeadline,
      downloadDeadline,
      payoutId: payoutRef.id,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // close conversation to read-only
    if (c.conversationId) {
      const convRef = db.collection('conversations').doc(c.conversationId);
      tx.set(
        convRef,
        {
          status: 'closed',
          closedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true }
      );
    }

    return payoutRef.id;
  });

  return { ok: true, payoutId };
});
