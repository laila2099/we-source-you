// functions/src/downloads.js
const { onCall, HttpsError } = require('firebase-functions/v2/https');
const admin = require('firebase-admin');

const db = admin.firestore();
const bucket = admin.storage().bucket();

exports.getDownloadUrl = onCall(
  { cors: true, invoker: 'public' },
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) throw new HttpsError('unauthenticated', 'Login required');

    const { purchaseId } = request.data || {};
    if (!purchaseId || typeof purchaseId !== 'string') {
      throw new HttpsError('invalid-argument', 'purchaseId is required');
    }

    // 1) Load purchase
    const purchaseSnap = await db.collection('purchases').doc(purchaseId).get();
    if (!purchaseSnap.exists) throw new HttpsError('not-found', 'Purchase not found');

    const purchase = purchaseSnap.data();

    // 2) Ownership check
    if (purchase.buyerId !== uid) {
      throw new HttpsError('permission-denied', 'Not your purchase');
    }

    // 3) Deadline check
    const deadlineTs = purchase.downloadDeadline;
    const deadlineDate = deadlineTs?.toDate?.();
    if (!deadlineDate) throw new HttpsError('failed-precondition', 'Missing downloadDeadline');

    if (Date.now() > deadlineDate.getTime()) {
      throw new HttpsError('failed-precondition', 'Download expired');
    }

    // 4) Load item to get fileRef and validate status
    const itemId = purchase.itemId;
    if (!itemId) throw new HttpsError('failed-precondition', 'Missing itemId on purchase');

    const itemSnap = await db.collection('media_items').doc(itemId).get();
    if (!itemSnap.exists) throw new HttpsError('not-found', 'Item not found');

    const item = itemSnap.data();
    if (item.status && item.status !== 'active') {
      throw new HttpsError('failed-precondition', 'Item not available');
    }

    const fileRef = item.fileRef;
    if (!fileRef || typeof fileRef !== 'string') {
      throw new HttpsError('failed-precondition', 'Missing fileRef on item');
    }

    // 5) Signed URL (10 minutes)
    const [url] = await bucket.file(fileRef).getSignedUrl({
      version: 'v4',
      action: 'read',
      expires: Date.now() + 10 * 60 * 1000,
    });

    return { url };
  }
);
