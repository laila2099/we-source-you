// functions/src/payments.js
require('dotenv').config({ path: '.env.we-source-you' });

const { onCall, onRequest, HttpsError } = require('firebase-functions/v2/https');
const admin = require('firebase-admin');
const Stripe = require('stripe');
const { applyPaymentSucceeded } = require('./payment_processor');

const db = admin.firestore();

const STRIPE_SECRET_KEY = process.env.STRIPE_SECRET_KEY;
const STRIPE_WEBHOOK_SECRET = process.env.STRIPE_WEBHOOK_SECRET;

function assertString(v, name) {
  if (!v || typeof v !== 'string') {
    throw new HttpsError('invalid-argument', `${name} is required`);
  }
}

function getStripe() {
  if (!STRIPE_SECRET_KEY) throw new Error('Missing STRIPE_SECRET_KEY');
  return new Stripe(STRIPE_SECRET_KEY, { apiVersion: '2024-06-20' });
}

exports.createPaymentIntent = onCall(
  { cors: true, invoker: 'public' },
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) throw new HttpsError('unauthenticated', 'Login required');

    const { provider, context, referenceId } = request.data;
    assertString(provider, 'provider');
    assertString(context, 'context');
    assertString(referenceId, 'referenceId');

    if (provider !== 'stripe') {
      throw new HttpsError('invalid-argument', 'Only stripe is supported for now');
    }

    const stripe = getStripe();

    let amount = null; // cents
    let currency = null;
    let payerId = null;

    if (context === 'jobContract') {
      const snap = await db.collection('contracts').doc(referenceId).get();
      if (!snap.exists) throw new HttpsError('not-found', 'Contract not found');
      const c = snap.data();

      if (c.clientId !== uid) throw new HttpsError('permission-denied', 'Only client can pay');
      if (c.status !== 'paymentPending') throw new HttpsError('failed-precondition', 'Not payable');

      currency = (c.currency || 'EUR').toLowerCase();
      amount = Math.round(Number(c.grossAmount) * 100);
      payerId = c.clientId;
    } else if (context === 'mediaMarket') {
      const snap = await db.collection('media_items').doc(referenceId).get();
      if (!snap.exists) throw new HttpsError('not-found', 'Item not found');
      const item = snap.data();

      if (item.status && item.status !== 'active') throw new HttpsError('failed-precondition', 'Item not available');

      currency = (item.currency || 'EUR').toLowerCase();
      amount = Math.round(Number(item.price) * 100);
      payerId = uid;
    }else if (context === 'hireMe') {
       const snap = await db.collection('contracts').doc(referenceId).get();
       if (!snap.exists) throw new HttpsError('not-found', 'Contract not found');
       const c = snap.data();

       if (c.clientId !== uid) throw new HttpsError('permission-denied', 'Only client can pay');

       currency = (c.currency || 'EUR').toLowerCase();

       // ✅ amount depends on stage/status
       if (c.status === 'paymentPendingInitial') {
         amount = Math.round(Number(c.initialAmount) * 100);
       } else if (c.status === 'paymentPendingRemaining') {
         amount = Math.round(Number(c.remainingDue) * 100);
       } else {
         throw new HttpsError('failed-precondition', `Not payable. status=${c.status}`);
       }

       payerId = c.clientId;
} else {
      throw new HttpsError('invalid-argument', 'Unsupported context');
    }

    if (!amount || amount < 50) throw new HttpsError('failed-precondition', 'Invalid amount');

    const pi = await stripe.paymentIntents.create({
      amount,
      currency,
      automatic_payment_methods: { enabled: true },
      metadata: { provider: 'stripe', context, referenceId, payerId },
    });

    await db.collection('payments').doc(pi.id).set({
      provider: 'stripe',
      context,
      referenceId,
      payerId,
      amount: amount / 100,
      currency: currency.toUpperCase(),
      status: pi.status,
      processed: false,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return { paymentIntentId: pi.id, clientSecret: pi.client_secret };
  }
);

exports.createCheckoutSession = onCall(
  { cors: true, invoker: 'public' },
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) throw new HttpsError('unauthenticated', 'Login required');

    const { context, referenceId, successUrl, cancelUrl } = request.data;
    assertString(context, 'context');
    assertString(referenceId, 'referenceId');
    assertString(successUrl, 'successUrl');
    assertString(cancelUrl, 'cancelUrl');

    const stripe = getStripe();

    let amountCents = null;
    let currency = null;
    let payerId = null;

    if (context === 'jobContract') {
      const snap = await db.collection('contracts').doc(referenceId).get();
      if (!snap.exists) throw new HttpsError('not-found', 'Contract not found');
      const c = snap.data();

      if (c.clientId !== uid) throw new HttpsError('permission-denied', 'Only client can pay');
      if (c.status !== 'paymentPending') throw new HttpsError('failed-precondition', 'Not payable');

      currency = (c.currency || 'EUR').toLowerCase();
      amountCents = Math.round(Number(c.grossAmount) * 100);
      payerId = c.clientId;
    } else if (context === 'mediaMarket') {
      const snap = await db.collection('media_items').doc(referenceId).get();
      if (!snap.exists) throw new HttpsError('not-found', 'Item not found');
      const item = snap.data();

      if (item.status && item.status !== 'active') throw new HttpsError('failed-precondition', 'Item not available');

      currency = (item.currency || 'EUR').toLowerCase();
      amountCents = Math.round(Number(item.price) * 100);
      payerId = uid;
    } else if (context === 'hireMe') {
      const snap = await db.collection('contracts').doc(referenceId).get();
      if (!snap.exists) throw new HttpsError('not-found', 'Contract not found');
      const c = snap.data();

      if (c.clientId !== uid) throw new HttpsError('permission-denied', 'Only client can pay');

      currency = (c.currency || 'EUR').toLowerCase();

      // ✅ amount depends on contract status
      if (c.status === 'paymentPendingInitial') {
        amountCents = Math.round(Number(c.initialAmount) * 100);
      } else if (c.status === 'paymentPendingRemaining') {
        amountCents = Math.round(Number(c.remainingDue) * 100);
      } else {
        throw new HttpsError('failed-precondition', `Not payable. status=${c.status}`);
      }

      payerId = c.clientId;
} else {
      throw new HttpsError('invalid-argument', 'Unsupported context');
    }

    if (!amountCents || amountCents < 50) throw new HttpsError('failed-precondition', 'Invalid amount');

    const session = await stripe.checkout.sessions.create({
      mode: 'payment',
      success_url: successUrl,
      cancel_url: cancelUrl,
      line_items: [
        {
          quantity: 1,
          price_data: {
            currency,
            unit_amount: amountCents,
            product_data: {
              name: context === 'jobContract' ? 'Job Contract Payment'
                      : context === 'hireMe' ? 'HireMe Payment'
                      : 'Media Item',
            },
          },
        },
      ],
      metadata: { context, referenceId, payerId },
      payment_intent_data: { metadata: { context, referenceId, payerId } },
    });

    await db.collection('checkout_sessions').doc(session.id).set({
      context,
      referenceId,
      payerId,
      amount: amountCents / 100,
      currency: currency.toUpperCase(),
      status: 'created',
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return { url: session.url, sessionId: session.id };
  }
);

// ✅ Webhook public + idempotent + موحد
exports.webhooksStripeDev  = onRequest(
{ cors: true, invoker: 'public' }
,
  async (req, res) => {
    const stripe = getStripe();

    if (!STRIPE_WEBHOOK_SECRET) return res.status(500).send('Missing webhook secret');

    let event;
    console.log('CT', req.headers['content-type']);
    console.log('rawBuffer?', Buffer.isBuffer(req.body), 'len=', req.body?.length);
    console.log('rawBody?', req.rawBody ? (Buffer.isBuffer(req.rawBody) ? 'buffer' : typeof req.rawBody) : 'none');

    try {
      const sig = req.headers['stripe-signature'];
      event = stripe.webhooks.constructEvent(req.rawBody, sig, STRIPE_WEBHOOK_SECRET);
    } catch (err) {
      console.error('Bad signature', err.message);
      return res.status(400).send('Bad signature');
    }

    try {
      // Web checkout source-of-truth
      if (event.type === 'checkout.session.completed') {

        const session = event.data.object;
//        const context = session?.metadata?.context;
//        const referenceId = session?.metadata?.referenceId;
//        const payerId = session?.metadata?.payerId;

        const sSnap = await db.collection('checkout_sessions').doc(session.id).get();
        const s = sSnap.exists ? sSnap.data() : null;

        const context = s?.context || session?.metadata?.context;
        const referenceId = s?.referenceId || session?.metadata?.referenceId;
        const payerId = s?.payerId || session?.metadata?.payerId;


        await applyPaymentSucceeded({
          provider: 'stripe',
          context,
          referenceId,
          paymentId: session.id,
          payerId,
          amount: session.amount_total ? session.amount_total / 100 : null,
          currency: session.currency ? session.currency.toUpperCase() : null,
        });

        return res.status(200).send('ok');
      }

      // Mobile payment sheet fallback
      if (event.type === 'payment_intent.succeeded') {
        const pi = event.data.object;
        const context = pi?.metadata?.context;
        const referenceId = pi?.metadata?.referenceId;
        const payerId = pi?.metadata?.payerId;

        await applyPaymentSucceeded({
          provider: 'stripe',
          context,
          referenceId,
          paymentId: pi.id,
          payerId,
          amount: pi.amount ? pi.amount / 100 : null,
          currency: pi.currency ? pi.currency.toUpperCase() : null,
        });

        return res.status(200).send('ok');
      }
    } catch (e) {
      console.error('stripeWebhook error', e);
      return res.status(500).send(e?.message || 'error');
    }


    return res.status(200).send('ignored');
  }
);
