const { defineSecret } = require('firebase-functions/params');
const fetch = require('node-fetch');

// ✅ Firebase Secrets
const PAYPAL_BASE_URL_SECRET  = defineSecret('PAYPAL_BASE_URL_SECRET'); // sandbox / live
const PAYPAL_CLIENT_ID_SECRET = defineSecret('PAYPAL_CLIENT_ID_SECRET');
const PAYPAL_CLIENT_SECRET_SECRET = defineSecret('PAYPAL_CLIENT_SECRET_SECRET');

function assertString(v, name) {
  if (!v || typeof v !== 'string') {
    throw new Error(`Missing ${name}`);
  }
}

function getBaseUrl() {
  const mode = PAYPAL_BASE_URL_SECRET.value(); // 'sandbox' or 'live'
  assertString(mode, 'PAYPAL_BASE_URL_SECRET');

  return mode;
}

async function getAccessToken() {
  const clientId = PAYPAL_CLIENT_ID_SECRET.value();
  const clientSecret = PAYPAL_CLIENT_SECRET_SECRET.value();

  assertString(clientId, 'PAYPAL_CLIENT_ID_SECRET');
  assertString(clientSecret, 'PAYPAL_CLIENT_SECRET_SECRET');

  const auth = Buffer
    .from(`${clientId}:${clientSecret}`)
    .toString('base64');

  const res = await fetch(`${getBaseUrl()}/v1/oauth2/token`, {
    method: 'POST',
    headers: {
      Authorization: `Basic ${auth}`,
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: 'grant_type=client_credentials',
  });

  if (!res.ok) {
    const t = await res.text();
    throw new Error(`PayPal token error: ${t}`);
  }

  const data = await res.json();
  return data.access_token;
}

module.exports = {
PAYPAL_BASE_URL_SECRET,
  PAYPAL_CLIENT_ID_SECRET,
  PAYPAL_CLIENT_SECRET_SECRET,
  getAccessToken,
  getBaseUrl,
};
