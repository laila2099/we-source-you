// const { onCall, HttpsError } = require('firebase-functions/v2/https');
// const logger = require('firebase-functions/logger');
// const crypto = require('crypto');
// const axios = require('axios');
// const admin = require('firebase-admin');

// const db = admin.firestore();

// exports.createSumsubAccessToken = onCall(
//   {
//     region: 'us-central1',
//     secrets: ['SUMSUB_APP_TOKEN', 'SUMSUB_SECRET_KEY'],
//   },
//   async (request) => {
//     if (!request.auth) {
//       throw new HttpsError('unauthenticated', 'User must be logged in');
//     }

//     const uid = request.auth.uid;
//     const LEVEL_NAME = 'id-and-liveness';
//     const ttlInSecs = 600;
//     const BASE_URL = 'https://api.sumsub.com';

//     const APP_TOKEN = process.env.SUMSUB_APP_TOKEN;
//     const SECRET = process.env.SUMSUB_SECRET_KEY;

//     try {
//       // 🔹 1. هل المستخدم عنده applicant قبل؟
//       const userRef = db.collection('users').doc(uid);
//       const userSnap = await userRef.get();

//       let applicantId = userSnap.exists ? userSnap.data()?.kyc?.applicantId : null;

//       // 🔹 2. إنشاء Applicant إذا مش موجود
//       if (!applicantId) {
//         const path = '/resources/applicants';
//         const ts = Math.floor(Date.now() / 1000);

//         const signature = crypto
//           .createHmac('sha256', SECRET)
//           .update(ts + 'POST' + path)
//           .digest('hex');

//         const res = await axios.post(
//           `${BASE_URL}${path}`,
//           {
//             externalUserId: uid,
//             levelName: LEVEL_NAME,
//           },
//           {
//             headers: {
//               'X-App-Token': APP_TOKEN,
//               'X-App-Access-Sig': signature,
//               'X-App-Access-Ts': ts,
//               'Content-Type': 'application/json',
//             },
//           },
//         );

//         applicantId = res.data.id;

//         await userRef.set(
//           {
//             kyc: {
//               applicantId,
//               status: 'pending',
//             },
//           },
//           { merge: true },
//         );
//       }

//       // 🔹 3. إنشاء Access Token
//       const tokenPath = '/resources/accessTokens';
//       const tokenTs = Math.floor(Date.now() / 1000);

//       const tokenSig = crypto
//         .createHmac('sha256', SECRET)
//         .update(tokenTs + 'POST' + tokenPath)
//         .digest('hex');

//       const tokenRes = await axios.post(
//         `${BASE_URL}${tokenPath}`,
//         {
//           userId: applicantId, // 🔥 مهم جدًا
//           levelName: LEVEL_NAME,
//           ttlInSecs,
//         },
//         {
//           headers: {
//             'X-App-Token': APP_TOKEN,
//             'X-App-Access-Sig': tokenSig,
//             'X-App-Access-Ts': tokenTs,
//             'Content-Type': 'application/json',
//           },
//         },
//       );

//       return {
//         token: tokenRes.data.token,
//       };
//     } catch (e) {
//       logger.error('Sumsub Error', e);
//       throw new HttpsError('internal', e.response?.data?.description || e.message);
//     }
//   },
// );
const { onCall, HttpsError } = require('firebase-functions/v2/https');
const crypto = require('crypto');
const axios = require('axios');
const admin = require('firebase-admin');

const db = admin.firestore();

exports.createSumsubAccessToken = onCall(
  {
    region: 'us-central1',
    secrets: ['SUMSUB_APP_TOKEN', 'SUMSUB_SECRET_KEY'],
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'Login required');
    }

    const uid = request.auth.uid;
    const LEVEL_NAME = 'id-and-liveness';
    const BASE_URL = 'https://api.sumsub.com';
    const APP_TOKEN = process.env.SUMSUB_APP_TOKEN;
    const SECRET = process.env.SUMSUB_SECRET_KEY;

    try {
      const userRef = db.collection('users').doc(uid);
      const userSnap = await userRef.get();

      let applicantId = userSnap.data()?.kyc?.applicantId;

      // 🔹 Create applicant if not exists
      if (!applicantId) {
        const path = '/resources/applicants';
        const ts = Math.floor(Date.now() / 1000);

        const sig = crypto
          .createHmac('sha256', SECRET)
          .update(ts + 'POST' + path)
          .digest('hex');

        const res = await axios.post(
          BASE_URL + path,
          {
            externalUserId: uid,
            levelName: LEVEL_NAME,
          },
          {
            headers: {
              'X-App-Token': APP_TOKEN,
              'X-App-Access-Sig': sig,
              'X-App-Access-Ts': ts,
              'Content-Type': 'application/json',
            },
          },
        );

        applicantId = res.data.id;

        await userRef.set({ kyc: { applicantId, status: 'pending' } }, { merge: true });
      }

      // 🔹 Create access token (CORRECT WAY)
      const tokenPath = '/resources/accessTokens';
      const tokenTs = Math.floor(Date.now() / 1000);

      const tokenSig = crypto
        .createHmac('sha256', SECRET)
        .update(tokenTs + 'POST' + tokenPath)
        .digest('hex');

      const tokenRes = await axios.post(
        BASE_URL + tokenPath,
        {
          userId: applicantId, // ✅ MUST be applicantId
          levelName: LEVEL_NAME,
          ttlInSecs: 600,
        },
        {
          headers: {
            'X-App-Token': APP_TOKEN,
            'X-App-Access-Sig': tokenSig,
            'X-App-Access-Ts': tokenTs,
            'Content-Type': 'application/json',
          },
        },
      );

      return { token: tokenRes.data.token };
    } catch (e) {
      console.error(e.response?.data || e.message);
      throw new HttpsError('internal', e.response?.data?.description || e.message);
    }
  },
);
