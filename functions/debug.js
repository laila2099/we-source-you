const { onCall } = require('firebase-functions/v2/https');

exports.ping = onCall(async () => {
  return { ok: true };
});
