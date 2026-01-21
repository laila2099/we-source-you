// functions/src/disputes.js
const { onCall, HttpsError } = require('firebase-functions/v2/https');
const admin = require('firebase-admin');

const db = admin.firestore();

exports.openDispute = onCall({ cors: true, invoker: 'public' }, async (request) => {
  const uid = request.auth?.uid;
  if (!uid) throw new HttpsError('unauthenticated', 'Login required');

  const { contractId, reason } = request.data || {};
  if (!contractId) throw new HttpsError('invalid-argument', 'contractId is required');

  const contractRef = db.collection('contracts').doc(contractId);

  const disputeId = await db.runTransaction(async (tx) => {
    const cSnap = await tx.get(contractRef);
    if (!cSnap.exists) throw new HttpsError('not-found', 'Contract not found');

    const c = cSnap.data();

    // ✅ only participants
    const isClient = c.clientId === uid;
    const isFreelancer = c.freelancerId === uid;
    if (!isClient && !isFreelancer) {
      throw new HttpsError('permission-denied', 'Not allowed');
    }

    // ✅ allow dispute only after paidOut (MVP)
    if (c.status !== 'paidOut') {
      throw new HttpsError('failed-precondition', 'Dispute allowed only after paidOut');
    }

    // ✅ deadline check
    const deadline = c.disputeDeadline; // Firestore Timestamp
    if (!deadline) throw new HttpsError('failed-precondition', 'Missing disputeDeadline');

    const now = admin.firestore.Timestamp.now();
    if (now.toMillis() > deadline.toMillis()) {
      throw new HttpsError('failed-precondition', 'Dispute window expired');
    }

    // ✅ idempotent: if already disputeOpen, return existing disputeId if stored
    if (c.status === 'disputeOpen' && c.disputeId) {
      return c.disputeId;
    }

    const disputeRef = db.collection('disputes').doc();
    const openedBy = uid;

    tx.set(disputeRef, {
      contractId,
      openedBy,
      reason: typeof reason === 'string' ? reason.trim() : null,
      status: 'dispute_opened',
      openedAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // update contract + conversation
    tx.update(contractRef, {
      status: 'disputeOpen',
      disputeId: disputeRef.id,
      disputeOpenedAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    if (c.conversationId) {
      const convRef = db.collection('conversations').doc(c.conversationId);
      tx.set(
        convRef,
        {
          status: 'dispute_open',
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true }
      );
    }

    return disputeRef.id;
  });

  return { ok: true, disputeId };
});
