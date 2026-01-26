// functions/src/createPayPalOrder.js
const { onCall, HttpsError } = require('firebase-functions/v2/https');
const { defineSecret } = require('firebase-functions/params');
const admin = require('firebase-admin');
const fetch = require('node-fetch');
const {
  PAYPAL_BASE_URL_SECRET,
  PAYPAL_CLIENT_ID_SECRET,
  PAYPAL_CLIENT_SECRET_SECRET,
  getBaseUrl,
  getAccessToken,
} = require('./paypalClient');

const db = admin.firestore();

exports.createPayPalOrder = onCall(
  { cors: true, invoker: 'public' ,   secrets: [
                                          PAYPAL_BASE_URL_SECRET,
                                          PAYPAL_CLIENT_ID_SECRET,
                                          PAYPAL_CLIENT_SECRET_SECRET,
                                        ],},
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) throw new HttpsError('unauthenticated', 'Login required');

    const { context, referenceId, returnUrl, cancelUrl } = request.data;
    if (!context || !referenceId || !returnUrl || !cancelUrl) {
      throw new HttpsError('invalid-argument', 'Missing params');
    }

    let amount, currency, payerId;

    if (context === 'jobContract') {
      const snap = await db.collection('contracts').doc(referenceId).get();
      if (!snap.exists) throw new HttpsError('not-found', 'Contract not found');
      const c = snap.data();

      if (c.clientId !== uid) throw new HttpsError('permission-denied');
      if (c.status !== 'paymentPending') throw new HttpsError('failed-precondition');

      amount = Number(c.grossAmount).toFixed(2);
      currency = (c.currency || 'EUR').toUpperCase();
      payerId = uid;
    } else if (context === 'mediaMarket') {
      const snap = await db.collection('media_items').doc(referenceId).get();
      if (!snap.exists) throw new HttpsError('not-found', 'Item not found');
      const item = snap.data();

      if (item.status && item.status !== 'active') throw new HttpsError('failed-precondition', 'Item not available');

      amount = Number(item.price).toFixed(2);
      currency = (item.currency || 'EUR').toUpperCase();
      payerId = uid;
    } else if (context === 'hireMe') {
      const snap = await db.collection('contracts').doc(referenceId).get();
      if (!snap.exists) throw new HttpsError('not-found', 'Contract not found');
      const c = snap.data();

      if (c.clientId !== uid) throw new HttpsError('permission-denied');
      currency = (c.currency || 'EUR').toUpperCase();
      payerId = uid;

      if (c.status === 'paymentPendingInitial') {
        amount = Number(c.initialAmount).toFixed(2);
      } else if (c.status === 'paymentPendingRemaining') {
        amount = Number(c.remainingDue).toFixed(2);
      } else {
        throw new HttpsError('failed-precondition', `Not payable. status=${c.status}`);
      }
} else {
      throw new HttpsError('invalid-argument', 'Unsupported context');
    }

    const accessToken = await getAccessToken();

    const res = await fetch(`${getBaseUrl()}/v2/checkout/orders`, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${accessToken}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        intent: 'CAPTURE',
        purchase_units: [
          {
            amount: { currency_code: currency, value: amount },
            custom_id: referenceId, // backup
          },
        ],
        application_context: { return_url: returnUrl, cancel_url: cancelUrl },
        custom_id: referenceId, // backup
      }),
    });

    const text = await res.text();
    const order = (() => { try { return JSON.parse(text); } catch { return null; } })();

    if (!res.ok || !order?.id) {
      console.error('PayPal create order failed', { status: res.status, body: text });
      throw new HttpsError('internal', 'PayPal create order failed');
    }

    if (!order?.id) {
      console.error('PayPal create order failed', order);
      throw new HttpsError('internal', 'PayPal create order failed');
    }

    await db.collection('payments').doc(order.id).set({
      provider: 'paypal',
      context,
      referenceId,
      payerId,
      amount: Number(amount),
      currency,
      status: 'created',
      processed: false,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    const approveLink = (order.links || []).find((l) => l.rel === 'approve');

    return { orderId: order.id, approveUrl: approveLink?.href };
  }
);
