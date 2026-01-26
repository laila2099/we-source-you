// functions/src/downloads.js
const { onCall, HttpsError } = require('firebase-functions/v2/https');
const admin = require('firebase-admin');

const db = admin.firestore();
const bucket = admin.storage().bucket();

exports.getDownloadUrl = onCall({ cors: true, invoker: 'public' }, async (request) => {
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
});

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

exports.getDeliveryDownloadUrlByConversation = onCall(
  { cors: true, invoker: 'public' },
  async (request) => {
    const uid = requireAuth(request);

    const { conversationId, fileIndex } = request.data || {};
    assertString(conversationId, 'conversationId');

    const idx = fileIndex == null ? 0 : Number(fileIndex);
    if (!Number.isInteger(idx) || idx < 0) {
      throw new HttpsError('invalid-argument', 'fileIndex must be a non-negative integer');
    }

    // 1) load conversation => contractId
    const convSnap = await db.collection('conversations').doc(conversationId).get();
    if (!convSnap.exists) throw new HttpsError('not-found', 'Conversation not found');
    const conv = convSnap.data();
    const contractId = conv.contractId;
    if (!contractId) throw new HttpsError('failed-precondition', 'Conversation missing contractId');

    // 2) load contract
    const contractSnap = await db.collection('contracts').doc(contractId).get();
    if (!contractSnap.exists) throw new HttpsError('not-found', 'Contract not found');
    const c = contractSnap.data();

    const isParty = c.clientId === uid || c.freelancerId === uid;
    if (!isParty) throw new HttpsError('permission-denied', 'Not a participant');

    // 3) status check: لازم يكون submitted أو deliveryApproved أو paidOut
    if (!['submitted', 'deliveryApproved', 'payoutQueued', 'paidOut'].includes(c.status)) {
      throw new HttpsError('failed-precondition', `No delivery download at status=${c.status}`);
    }

    // 4) deadline check (نسمح بالتنزيل بعد paidOut ضمن downloadDeadline)
    // إذا لسا مش paidOut، خلي التنزيل مسموح طالما submitted/deliveryApproved (حسب قرارك)
    if (c.status === 'paidOut') {
      const deadlineTs = c.downloadDeadline;
      const deadlineDate = deadlineTs?.toDate?.();
      if (!deadlineDate) throw new HttpsError('failed-precondition', 'Missing downloadDeadline');
      if (Date.now() > deadlineDate.getTime()) {
        throw new HttpsError('failed-precondition', 'Delivery download expired');
      }
    }

    const delivery = c.delivery;
    if (!delivery) throw new HttpsError('failed-precondition', 'Missing delivery');

    const st = delivery.submissionType;
    const data = delivery.submissionData || {};

    let fileRef = null;
    let filename = null;

    if (st === 'zip' && typeof data.zipRef === 'string') {
      fileRef = data.zipRef;
      filename = 'delivery.zip';
    } else if (st === 'files' && Array.isArray(data.files)) {
      const f = data.files[idx];
      if (!f || typeof f.fileRef !== 'string') {
        throw new HttpsError('not-found', 'File not found in delivery.files');
      }
      fileRef = f.fileRef;
      filename = f.name || `file_${idx}`;
    } else {
      throw new HttpsError('failed-precondition', `submissionType=${st} not downloadable`);
    }

    // 5) Signed URL (10 minutes)
    const [url] = await bucket.file(fileRef).getSignedUrl({
      version: 'v4',
      action: 'read',
      expires: Date.now() + 10 * 60 * 1000,
      responseDisposition: filename ? `attachment; filename="${filename}"` : undefined,
    });

    return { url, fileRef, filename };
  },
);
