// functions/src/payouts.js
require('dotenv').config({ path: '.env.we-source-you' });

const { onCall, HttpsError } = require('firebase-functions/v2/https');
const admin = require('firebase-admin');
const Stripe = require('stripe');

const db = admin.firestore();

// ========= Helpers =========
function requireAuth(request) {
  const uid = request.auth?.uid;
  if (!uid) throw new HttpsError('unauthenticated', 'Login required');
  return uid;
}
function assertString(v, name) {
  if (!v || typeof v !== 'string') throw new HttpsError('invalid-argument', `${name} is required`);
}
function toCents(amount) {
  const n = Number(amount);
  if (!Number.isFinite(n) || n <= 0) return null;
  return Math.round(n * 100);
}

// ========= Stripe =========
function getStripe() {
  const key = process.env.STRIPE_SECRET_KEY;
  if (!key) throw new Error('Missing STRIPE_SECRET_KEY');
  return new Stripe(key, { apiVersion: '2024-06-20' });
}

// ========= PayPal =========
// لازم تحطي هدول بالـ .env.we-source-you
// PAYPAL_CLIENT_ID=...
// PAYPAL_CLIENT_SECRET=...
// PAYPAL_BASE_URL=https://api-m.sandbox.paypal.com  (sandbox) OR https://api-m.paypal.com (live)
async function getPayPalAccessToken() {
  const base = process.env.PAYPAL_BASE_URL;
  const cid = process.env.PAYPAL_CLIENT_ID;
  const sec = process.env.PAYPAL_CLIENT_SECRET;
  if (!base || !cid || !sec) throw new Error('Missing PayPal env vars');

  const auth = Buffer.from(`${cid}:${sec}`).toString('base64');

  const res = await fetch(`${base}/v1/oauth2/token`, {
    method: 'POST',
    headers: {
      Authorization: `Basic ${auth}`,
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: 'grant_type=client_credentials',
  });

  if (!res.ok) {
    const t = await res.text();
    throw new Error(`PayPal token error: ${res.status} ${t}`);
  }
  const json = await res.json();
  return json.access_token;
}

async function paypalCreatePayout({ receiverEmail, amount, currency, note, senderItemId }) {
  const base = process.env.PAYPAL_BASE_URL;
  const token = await getPayPalAccessToken();

  const body = {
    sender_batch_header: {
      sender_batch_id: `batch_${Date.now()}`,
      email_subject: 'You have a payout!',
    },
    items: [
      {
        recipient_type: 'EMAIL',
        amount: { value: String(amount.toFixed(2)), currency },
        receiver: receiverEmail,
        note: note || 'Payout from platform',
        sender_item_id: senderItemId || `item_${Date.now()}`,
      },
    ],
  };

  const res = await fetch(`${base}/v1/payments/payouts`, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${token}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(body),
  });

  const text = await res.text();
  if (!res.ok) throw new Error(`PayPal payout error: ${res.status} ${text}`);

  return JSON.parse(text);
}

// ========= sendPayout =========
exports.sendPayout = onCall({ cors: true, invoker: 'public' }, async (request) => {
  const uid = requireAuth(request);
  const { payoutId } = request.data;
  assertString(payoutId, 'payoutId');

  const payoutRef = db.collection('payouts').doc(payoutId);

  // نقرأ payout ونعمل lock عبر Transaction
  const result = await db.runTransaction(async (tx) => {
    const snap = await tx.get(payoutRef);
    if (!snap.exists) throw new HttpsError('not-found', 'Payout not found');

    const p = snap.data();

    // صلاحية MVP: الفريلانسر فقط (وبعدين support/admin)
    if (p.freelancerId !== uid) throw new HttpsError('permission-denied', 'Not allowed');

    if (p.status === 'sent' || p.status === 'sent_mock') {
      return { already: true, provider: p.payoutProvider, ref: p.providerPayoutRef || null };
    }

    if (p.status !== 'queued') {
      throw new HttpsError('failed-precondition', `Not queued. status=${p.status}`);
    }

    if (!p.payoutProvider || !p.destination) {
      throw new HttpsError('failed-precondition', 'Missing payoutProvider/destination');
    }

    // نعلّم payout "processing" قبل ما نطلع من transaction
    tx.update(payoutRef, {
      status: 'processing',
      processingAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return { already: false, payout: p };
  });

  if (result.already) {
    return { ok: true, alreadySent: true, provider: result.provider, providerPayoutRef: result.ref };
  }

  const p = result.payout;

  try {
    // ===== Stripe Connect Transfer =====
    if (p.payoutProvider === 'stripe') {
      const stripe = getStripe();

      const acct = p.destination?.stripeConnectAccountId;
      if (!acct) throw new HttpsError('failed-precondition', 'Missing stripeConnectAccountId');

      const currency = (p.currency || 'EUR').toLowerCase();
      const cents = toCents(p.freelancerNet ?? p.amount ?? p.grossAmount);
      if (!cents) throw new HttpsError('failed-precondition', 'Invalid payout amount');

      // Transfer من رصيد المنصة -> للـ connected account
      // (الـ payout من الـ connected account للبنك بيصير حسب schedule)
      const transfer = await stripe.transfers.create({
        amount: cents,
        currency,
        destination: acct,
        metadata: {
          payoutId,
          contractId: p.contractId || '',
        },
      });

      await payoutRef.set(
        {
          status: 'sent',
          sentAt: admin.firestore.FieldValue.serverTimestamp(),
          providerPayoutRef: transfer.id,
          providerResponse: { type: 'stripe_transfer' },
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true }
      );

      return { ok: true, provider: 'stripe', providerPayoutRef: transfer.id };
    }

    // ===== PayPal Payouts =====
    if (p.payoutProvider === 'paypal') {
      const email = p.destination?.paypalPayoutEmail;
      if (!email) throw new HttpsError('failed-precondition', 'Missing paypalPayoutEmail');

      const currency = (p.currency || 'EUR').toUpperCase();
      const amount = Number(p.freelancerNet ?? p.amount ?? p.grossAmount);
      if (!Number.isFinite(amount) || amount <= 0) throw new HttpsError('failed-precondition', 'Invalid payout amount');

      const resp = await paypalCreatePayout({
        receiverEmail: email,
        amount,
        currency,
        note: `Payout for contract ${p.contractId || ''}`,
        senderItemId: payoutId,
      });

      // PayPal بيرجع batch id / payout batch id
      const batchId = resp?.batch_header?.payout_batch_id || null;

      await payoutRef.set(
        {
          status: 'sent',
          sentAt: admin.firestore.FieldValue.serverTimestamp(),
          providerPayoutRef: batchId,
          providerResponse: { type: 'paypal_payout', raw: resp },
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true }
      );

      return { ok: true, provider: 'paypal', providerPayoutRef: batchId };
    }

    throw new HttpsError('failed-precondition', `Unsupported payoutProvider=${p.payoutProvider}`);
  } catch (e) {
    console.error('sendPayout error', e);

    // رجّعي الحالة queued + سجلي error
    await payoutRef.set(
      {
        status: 'queued',
        lastError: String(e?.message || e),
        lastErrorAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true }
    );

    throw new HttpsError('internal', 'sendPayout failed');
  }
});
