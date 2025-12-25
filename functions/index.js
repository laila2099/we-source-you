// /**
//  * Import function triggers from their respective submodules:
//  *
//  * const {onCall} = require("firebase-functions/v2/https");
//  * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
//  *
//  * See a full list of supported triggers at https://firebase.google.com/docs/functions
//  */

// const {setGlobalOptions} = require("firebase-functions");
// const {onRequest} = require("firebase-functions/https");
// const logger = require("firebase-functions/logger");

// // For cost control, you can set the maximum number of containers that can be
// // running at the same time. This helps mitigate the impact of unexpected
// // traffic spikes by instead downgrading performance. This limit is a
// // per-function limit. You can override the limit for each function using the
// // `maxInstances` option in the function's options, e.g.
// // `onRequest({ maxInstances: 5 }, (req, res) => { ... })`.
// // NOTE: setGlobalOptions does not apply to functions using the v1 API. V1
// // functions should each use functions.runWith({ maxInstances: 10 }) instead.
// // In the v1 API, each function can only serve one request per container, so
// // this will be the maximum concurrent request count.
// setGlobalOptions({ maxInstances: 10 });

// // Create and deploy your first functions
// // https://firebase.google.com/docs/functions/get-started

// // exports.helloWorld = onRequest((request, response) => {
// //   logger.info("Hello logs!", {structuredData: true});
// //   response.send("Hello from Firebase!");
// // });
const functions = require("firebase-functions");
const admin = require("firebase-admin");
const fetch = require("node-fetch");

admin.initializeApp();

const SUMSUB_API_URL = "https://api.sumsub.com";
const functions = require("firebase-functions");
const SUMSUB_SECRET_KEY = functions.config().sumsub.key;
const SUMSUB_APP_ID = functions.config().sumsub.appid;


exports.generateKycToken = functions.https.onCall(async (data, context) => {
  const externalUserId = context.auth.uid; // UID من Firebase Auth
  const role = "applicant"; // ثابت عادة

  // توليد JWT token لـ Sumsub
  const response = await fetch(`${SUMSUB_API_URL}/resources/applicants`, {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${SUMSUB_SECRET_KEY}`,
      "Content-Type": "application/json"
    },
    body: JSON.stringify({
      externalUserId: externalUserId,
      firstName: data.firstName,
      lastName: data.lastName,
      email: data.email
    })
  });

  const json = await response.json();

  // Sumsub يرجع applicantId
  const applicantId = json.id;

  // توليد access token
  const tokenResponse = await fetch(`${SUMSUB_API_URL}/resources/accessTokens`, {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${SUMSUB_SECRET_KEY}`,
      "Content-Type": "application/json"
    },
    body: JSON.stringify({
      userId: applicantId,
      ttlInSecs: 3600 // صلاحية ساعة واحدة
    })
  });

  const tokenJson = await tokenResponse.json();
  return { token: tokenJson.token };
});
