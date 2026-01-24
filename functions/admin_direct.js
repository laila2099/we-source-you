// admin_direct.js
const admin = require('firebase-admin');
const serviceAccount = require('./we-source-you-firebase-adminsdk-fbsvc-142c265028.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

// حطي UID المستخدم اللي بدك تخليه Admin
const uid = '32nssG0XAiWcGDXw69TBWAoman43';

admin
  .auth()
  .setCustomUserClaims(uid, { admin: true })
  .then(() => {
    console.log(`✅ Admin claim set for UID: ${uid}`);
    process.exit(0);
  })
  .catch((error) => {
    console.error('❌ Error setting admin claim:', error);
    process.exit(1);
  });
