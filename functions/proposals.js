// functions/src/proposals.js
const { onCall, HttpsError } = require('firebase-functions/v2/https');
const admin = require('firebase-admin');

const db = admin.firestore();

exports.acceptProposal = onCall({ cors: true, invoker: 'public' }, async (request) => {
  console.log('GCLOUD_PROJECT', process.env.GCLOUD_PROJECT);
  console.log('FUNCTION_IDENTITY_HINT', process.env.FUNCTION_TARGET);

  try {
    const uid = request.auth?.uid;
    if (!uid) throw new HttpsError('unauthenticated', 'Login required');

    const { proposalId } = request.data;
    if (!proposalId) throw new HttpsError('invalid-argument', 'proposalId is required');

    const proposalRef = db.collection('proposals').doc(proposalId);

    const { contractId } = await db.runTransaction(async (tx) => {
      const pSnap = await tx.get(proposalRef);
      if (!pSnap.exists) throw new HttpsError('not-found', 'Proposal not found');

      const proposal = pSnap.data();

      // Idempotent
      if (proposal.status === 'accepted' && proposal.contractId) {
        return { contractId: proposal.contractId };
      }

      if (proposal.status && proposal.status !== 'pending') {
        throw new HttpsError('failed-precondition', 'Proposal not pending');
      }

      // owner check
      if (proposal.jobOwnerId !== uid) throw new HttpsError('permission-denied', 'Not job owner');

      const grossAmount = Number(proposal.bidAmount);
      if (!Number.isFinite(grossAmount) || grossAmount <= 0) {
        throw new HttpsError('invalid-argument', 'Invalid bidAmount');
      }

      const jobId = proposal.jobId;
      if (!jobId) throw new HttpsError('failed-precondition', 'Proposal missing jobId');

      const jobRef = db.collection('jobs').doc(jobId);
      const jSnap = await tx.get(jobRef);
      if (!jSnap.exists) throw new HttpsError('not-found', 'Job not found');

      const job = jSnap.data();

      const contractRef = db.collection('contracts').doc();
      const newContractId = contractRef.id;

      tx.set(contractRef, {
        source: 'jobProposal',
        jobId,
        proposalId,

        clientId: proposal.jobOwnerId,
        freelancerId: proposal.userId,

        grossAmount,
        currency: job?.currency || 'EUR',

        status: 'paymentPending',
        conversationId: null,
        paymentRef: null,

        platformFeeRate: null,
        platformFee: null,
        freelancerNet: null,

        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      tx.update(proposalRef, {
        status: 'accepted',
        acceptedAt: admin.firestore.FieldValue.serverTimestamp(),
        contractId: newContractId,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      return { contractId: newContractId };
    });

    return { contractId };
  } catch (err) {
    console.error('acceptProposal failed:', err);
    if (err instanceof HttpsError) throw err;
    throw new HttpsError('internal', err?.message || 'Unknown error');
  }
});
