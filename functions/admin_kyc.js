const { onDocumentUpdated } = require('firebase-functions/v2/firestore');
const admin = require('firebase-admin');

exports.onKycStatusChange = onDocumentUpdated('users/{uid}', async (event) => {
  const before = event.data.before.data;
  const after = event.data.after.data;

  if (before.kycStatus === after.kycStatus) return;

  const uid = event.params.uid;

  const statusText =
    after.kycStatus === 'approved'
      ? 'Your KYC has been approved ✅'
      : 'Your KYC has been rejected ❌';

  // خزّن الإشعار
  await admin.firestore().collection('notifications').add({
    userId: uid,
    title: 'KYC Update',
    body: statusText,
    type: 'kyc',
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    isRead: false,
  });

  // FCM
  const userDoc = await admin.firestore().collection('users').doc(uid).get();
  const fcmToken = userDoc.data()?.fcmToken;
  if (!fcmToken) return;

  await admin.messaging().send({
    token: fcmToken,
    notification: {
      // أضف هذا الجزء
      title: 'KYC Update',
      body: statusText,
    },
    webpush: {
      notification: {
        title: 'KYC Update',
        body: statusText,
        icon: '/icons/app_icon.png', // تأكد من مسار الأيقونة
      },
    },
  });
});
