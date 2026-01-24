// functions/src/disputes.js
const { onCall, HttpsError } = require('firebase-functions/v2/https');
const admin = require('firebase-admin');

const db = admin.firestore();
const bucket = admin.storage().bucket();

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

function isObject(v) {
  return v && typeof v === 'object' && !Array.isArray(v);
}

// ✅ submit dispute message (text + attachments)
exports.submitDisputeMessageByConversation = onCall(
  { cors: true, invoker: 'public' },
  async (request) => {
    const uid = requireAuth(request);

    const { conversationId, text, attachments } = request.data || {};
    assertString(conversationId, 'conversationId');

    const msgText = (typeof text === 'string') ? text.trim() : '';
    const files = Array.isArray(attachments) ? attachments : [];

    if (!msgText && files.length === 0) {
      throw new HttpsError('invalid-argument', 'Provide text or attachments');
    }

    // Validate attachments shape quickly
    for (const a of files) {
      if (!isObject(a)) throw new HttpsError('invalid-argument', 'attachments must be objects');
      if (typeof a.fileRef !== 'string' || !a.fileRef.trim()) {
        throw new HttpsError('invalid-argument', 'Each attachment must have fileRef');
      }
      if (typeof a.name !== 'string' || !a.name.trim()) {
        throw new HttpsError('invalid-argument', 'Each attachment must have name');
      }
      // optional: size
      if (a.size != null && !Number.isFinite(Number(a.size))) {
        throw new HttpsError('invalid-argument', 'attachment.size must be a number');
      }
    }

    await db.runTransaction(async (tx) => {
      const convRef = db.collection('conversations').doc(conversationId);
      const convSnap = await tx.get(convRef);
      if (!convSnap.exists) throw new HttpsError('not-found', 'Conversation not found');

      const conv = convSnap.data();

      const participants = Array.isArray(conv.participants) ? conv.participants : [];
      if (!participants.includes(uid)) {
        throw new HttpsError('permission-denied', 'Not a participant');
      }

      const status = (conv.status || 'open').toString();
      if (status !== 'disputeOpen') {
        throw new HttpsError('failed-precondition', `Conversation not in dispute_open. status=${status}`);
      }

      // ✅ security: attachments must belong to this conversation folder
      // we expect: disputes/{conversationId}/...
      for (const a of files) {
        const ref = a.fileRef.trim();
        if (!ref.startsWith(`disputes/${conversationId}/`)) {
          throw new HttpsError('permission-denied', 'attachment fileRef not allowed for this conversation');
        }
      }

      const msgRef = convRef.collection('messages').doc();

      tx.set(msgRef, {
        type: 'dispute',
        senderId: uid,
        text: msgText || null,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        meta: {
          attachments: files.map((a) => ({
            name: a.name.trim(),
            fileRef: a.fileRef.trim(),
            size: a.size != null ? Number(a.size) : null,
          })),
        },
      });

      // unread update
      const otherUid = participants.find((p) => p !== uid) || null;
      const unread = (conv.unread && typeof conv.unread === 'object') ? conv.unread : {};
      const otherUnread = otherUid ? Number(unread[otherUid] ?? 0) : 0;

      const lastText = files.length > 0
        ? '📎 Dispute evidence'
        : (msgText ? '⚠️ Dispute message' : '⚠️ Dispute update');

      const patch = {
        lastMessageAt: admin.firestore.FieldValue.serverTimestamp(),
        lastMessageText: lastText,
        lastMessageSenderId: uid,
        [`unread.${uid}`]: 0,
      };

      if (otherUid) patch[`unread.${otherUid}`] = otherUnread + 1;

      tx.set(convRef, patch, { merge: true });
    });

    return { ok: true };
  }
);


// ✅ signed url for dispute attachment (download)
exports.getDisputeAttachmentUrlByConversation = onCall(
  { cors: true, invoker: 'public' },
  async (request) => {
    const uid = requireAuth(request);

    const { conversationId, fileRef, filename } = request.data || {};
    assertString(conversationId, 'conversationId');
    assertString(fileRef, 'fileRef');

    const convSnap = await db.collection('conversations').doc(conversationId).get();
    if (!convSnap.exists) throw new HttpsError('not-found', 'Conversation not found');

    const conv = convSnap.data();
    const participants = Array.isArray(conv.participants) ? conv.participants : [];
    if (!participants.includes(uid)) {
      // لاحقاً: support role
      throw new HttpsError('permission-denied', 'Not a participant');
    }

    const status = (conv.status || 'open').toString();
    if (status !== 'disputeOpen') {
      throw new HttpsError('failed-precondition', 'Not in dispute');
    }

    // ✅ must be inside disputes/{conversationId}/
    if (!fileRef.startsWith(`disputes/${conversationId}/`)) {
      throw new HttpsError('permission-denied', 'fileRef not allowed');
    }

    const safeName = (typeof filename === 'string' && filename.trim())
      ? filename.trim()
      : 'evidence';

    const [url] = await bucket.file(fileRef).getSignedUrl({
      version: 'v4',
      action: 'read',
      expires: Date.now() + 10 * 60 * 1000,
      responseDisposition: `attachment; filename="${safeName}"`,
    });

    return { url };
  }
);
