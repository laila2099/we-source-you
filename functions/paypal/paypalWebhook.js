// functions/src/paypalWebhook.js
const { onRequest } = require('firebase-functions/v2/https');
const { defineSecret } = require('firebase-functions/params');
const admin = require('firebase-admin');
const fetch = require('node-fetch');
const db = admin.firestore();
const {
  PAYPAL_BASE_URL_SECRET,
  PAYPAL_CLIENT_ID_SECRET,
  PAYPAL_CLIENT_SECRET_SECRET,
  getBaseUrl,
  getAccessToken,
} = require('./paypalClient');
const { applyPaymentSucceeded } = require('../payment_processor');
const PAYPAL_WEBHOOK_ID_SECRET = defineSecret('PAYPAL_WEBHOOK_ID_SECRET');

async function verifyPaypalWebhook(req, event, accessToken) {
  const headers = req.headers;

  const body = {
    auth_algo: headers['paypal-auth-algo'],
    cert_url: headers['paypal-cert-url'],
    transmission_id: headers['paypal-transmission-id'],
    transmission_sig: headers['paypal-transmission-sig'],
    transmission_time: headers['paypal-transmission-time'],
    webhook_id: PAYPAL_WEBHOOK_ID_SECRET.value(),
    webhook_event: event,
  };

  // إذا أي هيدر ناقص، اعتبريه فشل
  for (const k of [
    'auth_algo','cert_url','transmission_id','transmission_sig','transmission_time'
  ]) {
    if (!body[k]) return false;
  }

  const r = await fetch(`${getBaseUrl()}/v1/notifications/verify-webhook-signature`, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${accessToken}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(body),
  });

  const out = await r.json().catch(() => ({}));
  return r.ok && out?.verification_status === 'SUCCESS';
}



exports.webhooksPaypalDev = onRequest({ cors: true, invoker: 'public' , secrets: [
                                                                                                                PAYPAL_BASE_URL_SECRET,
                                                                                                                PAYPAL_CLIENT_ID_SECRET,
                                                                                                                PAYPAL_CLIENT_SECRET_SECRET,
                                                                                                                PAYPAL_WEBHOOK_ID_SECRET,
                                                                                                              ],}, async (req, res) => {
  let event;
  try {
    event = typeof req.body === 'object'
      ? req.body
      : JSON.parse(req.rawBody?.toString?.() || '{}');
  } catch (e) {
    console.error('paypalWebhook: bad json', e);
    return res.sendStatus(200);
  }

  const type = event?.event_type;
  const orderId = event?.resource?.id;

  console.log('paypalWebhook received', { type, orderId });

  if (type !== 'CHECKOUT.ORDER.APPROVED' || !orderId) return res.sendStatus(200);

  const paymentRef = db.collection('payments').doc(orderId);
  const snap = await paymentRef.get();

  if (!snap.exists) {
    console.warn('paypalWebhook: payment doc missing', orderId);
    return res.sendStatus(200);
  }

  const payment = snap.data();
  if (payment.processed === true) {
    console.log('paypalWebhook: already processed', orderId);
    return res.sendStatus(200);
  }

  try {
    const accessToken = await getAccessToken();

    const ok = await verifyPaypalWebhook(req, event, accessToken);
      if (!ok) {
        console.warn('paypalWebhook: signature verification failed');
        return res.sendStatus(200);
      }

    const capRes = await fetch(`${getBaseUrl()}/v2/checkout/orders/${orderId}/capture`, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${accessToken}`,
        'Content-Type': 'application/json',
      },
    });

    const captured = await capRes.json();

    if (!capRes.ok) {
      console.error('PayPal capture failed', { status: capRes.status, captured });
      return res.sendStatus(200);
    }

    const pu = captured?.purchase_units?.[0];
    const cap = pu?.payments?.captures?.[0];

    const amount = cap?.amount?.value ? Number(cap.amount.value) : payment.amount;
    const currency = cap?.amount?.currency_code || payment.currency;

    console.log('paypal captured', { orderId, amount, currency });

    await applyPaymentSucceeded({
      provider: 'paypal',
      context: payment.context,
      referenceId: payment.referenceId,
      paymentId: orderId,
      payerId: payment.payerId,
      amount,
      currency,
    });

    console.log('paypal applyPaymentSucceeded OK', orderId);
    return res.sendStatus(200);
  } catch (e) {
    console.error('paypalWebhook error', e);
    return res.sendStatus(200);
  }
});
