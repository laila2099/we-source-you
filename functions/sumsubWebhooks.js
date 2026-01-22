const functions = require('firebase-functions');
const admin = require('firebase-admin');
const db = admin.firestore();

exports.sumsubWebhook = functions.https.onRequest(async (req, res) => {
  // Security: In production, verify 'x-payload-digest' header here.

  const body = req.body;
  const externalUserId = body.externalUserId;
  const reviewStatus = body.reviewStatus; // 'completed', 'reviewPending'
  const reviewResult = body.reviewResult; // { reviewAnswer: 'GREEN' | 'RED' }

  if (!externalUserId) return res.status(400).send('No userId');

  let kycStatus = 'pending';
  let verifiedAt = null;

  if (reviewStatus === 'completed') {
    if (reviewResult && reviewResult.reviewAnswer === 'GREEN') {
      kycStatus = 'approved';
      verifiedAt = admin.firestore.FieldValue.serverTimestamp();
    } else if (reviewResult && reviewResult.reviewAnswer === 'RED') {
      kycStatus = 'rejected';
    }
  } else if (reviewStatus === 'reviewPending') {
    // Sumsub needs manual check on their side
    kycStatus = 'pending';
  }

  try {
    await db.collection('users').doc(externalUserId).update({
      'kyc.status': kycStatus,
      'kyc.verifiedAt': verifiedAt,
      'kyc.lastUpdate': admin.firestore.FieldValue.serverTimestamp(),
      'kyc.provider': 'sumsub', // To know this was automated
    });
    res.status(200).send('Webhook processed');
  } catch (error) {
    console.error('Webhook DB Error:', error);
    res.status(500).send('Internal Server Error');
  }
});
