// functions/src/paypalWebhook.js
const { onRequest } = require('firebase-functions/v2/https');
const admin = require('firebase-admin');
const fetch = require('node-fetch');
const {
  PAYPAL_BASE_URL_SECRET,
  PAYPAL_CLIENT_ID_SECRET,
  PAYPAL_CLIENT_SECRET_SECRET,
  getBaseUrl,
  getAccessToken,
} = require('./paypalClient');
const { applyPaymentSucceeded } = require('../payment_processor');

const db = admin.firestore();

exports.webhooksPaypalDev = onRequest({ cors: true, invoker: 'public' , secrets: [
                                                                                                                PAYPAL_BASE_URL_SECRET,
                                                                                                                PAYPAL_CLIENT_ID_SECRET,
                                                                                                                PAYPAL_CLIENT_SECRET_SECRET,
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
