const functions = require('firebase-functions');
const admin = require('firebase-admin');
const db = admin.firestore();

exports.adminReviewKyc = functions.https.onCall(async (data, context) => {
  // 1. Verify Admin Role (Assuming custom claims or a DB lookup)
  if (!context.auth) throw new functions.https.HttpsError('unauthenticated', 'Login required');

  // Check if caller is admin via Firestore (Secure method)
  const adminDoc = await db.collection('users').doc(context.auth.uid).get();
  if (!adminDoc.exists || adminDoc.data().role !== 'admin') {
    throw new functions.https.HttpsError('permission-denied', 'Admins only.');
  }

  const { targetUserId, decision, reason } = data; // decision: 'approve' | 'reject'

  if (!targetUserId || !['approve', 'reject'].includes(decision)) {
    throw new functions.https.HttpsError('invalid-argument', 'Invalid parameters');
  }

  const updates = {
    'kyc.status': decision === 'approve' ? 'approved' : 'rejected',
    'kyc.verifiedAt': decision === 'approve' ? admin.firestore.FieldValue.serverTimestamp() : null,
    'kyc.reviewedBy': context.auth.uid,
    'kyc.rejectionReason': reason || null,
  };

  await db.collection('users').doc(targetUserId).update(updates);

  return { success: true };
});
