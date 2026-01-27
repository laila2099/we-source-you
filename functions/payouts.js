// functions/src/payouts.js
const { defineString, defineSecret } = require('firebase-functions/params');

const PAYPAL_BASE_URL_SECRET  = defineSecret('PAYPAL_BASE_URL_SECRET'); // sandbox/live
const PAYPAL_CLIENT_ID_SECRET = defineSecret('PAYPAL_CLIENT_ID_SECRET');
const PAYPAL_CLIENT_SECRET_SECRET = defineSecret('PAYPAL_CLIENT_SECRET_SECRET');



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

async function getPayPalAccessToken() {
  const base = PAYPAL_BASE_URL_SECRET.value();
  const cid = PAYPAL_CLIENT_ID_SECRET.value();
  const sec = PAYPAL_CLIENT_SECRET_SECRET.value();

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

function toSenderItemId(payoutId) {
    return (`p_${payoutId}`).slice(0, 63);
  }

async function paypalCreatePayout({ receiverEmail, amount, currency, note, senderItemId }) {
const base = PAYPAL_BASE_URL_SECRET.value();
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
        sender_item_id: (toSenderItemId(senderItemId) || `item_${Date.now()}`),
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
exports.sendPayout = onCall({ cors: true, invoker: 'public', secrets: [PAYPAL_BASE_URL_SECRET, PAYPAL_CLIENT_ID_SECRET, PAYPAL_CLIENT_SECRET_SECRET] }, async (request) => {
  const uid = requireAuth(request);
  const { payoutId } = request.data;
  assertString(payoutId, 'payoutId');

  const payoutRef = db.collection('payouts').doc(payoutId);

  // نقرأ payout ونعمل lock عبر Transaction
  const result = await db.runTransaction(async (tx) => {
    const snap = await tx.get(payoutRef);
    if (!snap.exists) throw new HttpsError('not-found', 'Payout not found');

    const p = snap.data();

//    const ownerId = p.freelancerId || p.sellerId;
//    if (ownerId !== uid) throw new HttpsError('permission-denied', 'Not allowed');


    if (p.status === 'sent' || p.status === 'sent_mock') {
      return { already: true, provider: p.payoutProvider, ref: p.providerPayoutRef || null };
    }

    if (p.status !== 'queued') {
      throw new HttpsError('failed-precondition', `Not queued. status=${p.status}`);
    }

    if (!p.payoutProvider || !p.destination) {
      throw new HttpsError('failed-precondition', 'Missing payoutProvider/destination');
    }
    if (p.context === 'mediaMarket') {
      if (!p.purchaseId) {
        throw new HttpsError('failed-precondition', 'Missing purchaseId on payout');
      }

      const purRef = db.collection('purchases').doc(p.purchaseId);
      const purSnap = await tx.get(purRef);
      if (!purSnap.exists) throw new HttpsError('failed-precondition', 'Purchase not found');

      const pur = purSnap.data();

      // لازم تكون purchase paid + payoutStatus queued
      if (pur.status !== 'paid') {
        throw new HttpsError('failed-precondition', `Purchase not paid. status=${pur.status}`);
      }
      if (pur.payoutStatus !== 'queued' && p.status !== 'queued') {
        throw new HttpsError('failed-precondition', `Purchase payout not queued. payoutStatus=${pur.payoutStatus}`);
      }

    }  else {
    // ✅ verify contract is paidOut before sending payout
    if (!p.contractId) {
      throw new HttpsError('failed-precondition', 'Missing contractId on payout');
    }

    const cSnap = await tx.get(db.collection('contracts').doc(p.contractId));
    if (!cSnap.exists) throw new HttpsError('failed-precondition', 'Contract not found for payout');

    const c = cSnap.data();
    // ✅ verify contract is ready for payout before sending
    if (c.status !== 'payoutQueued') {
      throw new HttpsError('failed-precondition', `Contract not payoutQueued. status=${c.status}`);
    }}



    // نعلّم payout "processing" قبل ما نطلع من transaction
    tx.update(payoutRef, {
      status: 'processing',
      processingAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // 🔒 اقفلي العقد فورًا لحتى ينشال زر Send payout
    if (p.contractId) {
      const contractRef = db.collection('contracts').doc(p.contractId);

      tx.update(contractRef, {
        status: 'payoutProcessing',
        payoutProcessingAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }


    return { already: false, payout: p };
  });

  if (result.already) {
    return { ok: true, alreadySent: true, provider: result.provider, providerPayoutRef: result.ref };
  }

  const p = result.payout;
  const contractRef = p.contractId ? db.collection('contracts').doc(p.contractId) : null;
  const purchaseRef = p.purchaseId ? db.collection('purchases').doc(p.purchaseId) : null;


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

      const paidOutAt = admin.firestore.FieldValue.serverTimestamp();

      const disputeDeadline = admin.firestore.Timestamp.fromDate(
        new Date(Date.now() + 14 * 24 * 60 * 60 * 1000)
      );
      const downloadDeadline = admin.firestore.Timestamp.fromDate(
        new Date(Date.now() + 90 * 24 * 60 * 60 * 1000)
      );

      if (p.context === 'mediaMarket') {
        await purchaseRef.set({
          payoutStatus: 'sent',
          payoutSentAt: admin.firestore.FieldValue.serverTimestamp(),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        }, { merge: true });
      } else {
        await contractRef.set({
          status: 'paidOut',
          paidOutAt: admin.firestore.FieldValue.serverTimestamp(),
          disputeDeadline,
          downloadDeadline,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        }, { merge: true });
      }


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

      const paidOutAt = admin.firestore.FieldValue.serverTimestamp();

      const disputeDeadline = admin.firestore.Timestamp.fromDate(
        new Date(Date.now() + 14 * 24 * 60 * 60 * 1000)
      );
      const downloadDeadline = admin.firestore.Timestamp.fromDate(
        new Date(Date.now() + 90 * 24 * 60 * 60 * 1000)
      );

      if (p.context === 'mediaMarket') {
              await purchaseRef.set({
                payoutStatus: 'sent',
                payoutSentAt: admin.firestore.FieldValue.serverTimestamp(),
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
              }, { merge: true });
            } else {

      await contractRef.set(
        {
          status: 'paidOut',
          paidOutAt,
          disputeDeadline,
          downloadDeadline,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true }
      );
}

      return { ok: true, provider: 'paypal', providerPayoutRef: batchId };
    }

    throw new HttpsError('failed-precondition', `Unsupported payoutProvider=${p.payoutProvider}`);
  } catch (e) {
    console.error('sendPayout error', e);

    await payoutRef.set(
      {
        status: 'failed',
        lastError: String(e?.message || e),
        lastErrorAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true }
    );

  if (contractRef) {
      await contractRef.set(
        {
          status: 'payoutQueued',
          payoutRetryAt: admin.firestore.FieldValue.serverTimestamp(),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true }
      );
    }

    throw new HttpsError('internal', 'sendPayout failed');
  }
});

exports.getPayoutSettings = onCall({ cors: true, invoker: 'public' }, async (request) => {
  const uid = requireAuth(request);

  const snap = await db.collection('users').doc(uid).get();
  const u = snap.exists ? (snap.data() || {}) : {};

  const profiles = u.payoutProfile || {};

  const payoutDefault = u.payoutDefault || null;

  return {
    ok: true,
    payoutDefault,
    payoutProfile: profiles,
  };
});

exports.setDefaultPayoutProvider = onCall({ cors: true, invoker: 'public' }, async (request) => {
  const uid = requireAuth(request);
  const { provider } = request.data || {};
  assertString(provider, 'provider');

  if (provider !== 'paypal' && provider !== 'stripe') {
    throw new HttpsError('invalid-argument', 'provider must be paypal|stripe');
  }

  const userRef = db.collection('users').doc(uid);

  await db.runTransaction(async (tx) => {
    const snap = await tx.get(userRef);
    const u = snap.exists ? (snap.data() || {}) : {};

    const profiles = u.payoutProfile || {};

    const hasPaypal =
      !!profiles.paypal?.enabled && !!profiles.paypal?.paypalEmail;

    const hasStripe =
      !!profiles.stripe?.enabled && !!profiles.stripe?.stripeConnectAccountId
      || (legacy?.provider === 'stripe' && !!legacy.stripeConnectAccountId);

    if (provider === 'paypal' && !hasPaypal) {
      throw new HttpsError('failed-precondition', 'PayPal payout not setup');
    }
    if (provider === 'stripe' && !hasStripe) {
      throw new HttpsError('failed-precondition', 'Stripe payout not setup');
    }
    if (provider === 'stripe') {
        theOther = 'paypal';
      } else {
        theOther = 'stripe';
      }


    tx.set(userRef, {
      payoutDefault: provider,
      payoutProfile:{
        [provider]: {
          enabled: true,
          provider,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        [theOther]: {
          enabled: false,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
      },

      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });
  });

  return { ok: true };
});



const { onDocumentUpdated, onDocumentCreated } =
  require('firebase-functions/v2/firestore');



exports.autoSendPayoutOnQueuedCreated = onDocumentCreated(
  {
    document: 'payouts/{payoutId}',
    region: 'us-central1',
    secrets: [PAYPAL_BASE_URL_SECRET, PAYPAL_CLIENT_ID_SECRET, PAYPAL_CLIENT_SECRET_SECRET],
  },
  async (event) => {
    const p = event.data?.data() || null;
    if (!p) return;

    if (p.context !== 'mediaMarket') return;
    if (p.status !== 'queued') return;

    if (!p.payoutProvider || !p.destination) return;

    console.log('autoSendPayoutOnQueuedCreated fired', event.params.payoutId);

    try {
      await sendPayoutInternal(event.params.payoutId);
    } catch (e) {
      console.error('autoSendPayoutOnQueuedCreated failed', e);
    }
  }
);



function isRetryablePayPalError(lastError) {
  const s = (lastError || '').toString();

  // ✅ أخطاء مؤقتة (ممكن تزبط مع إعادة المحاولة)
  if (s.includes('"name":"INTERNAL_SERVER_ERROR"')) return true;
  if (s.includes('"name":"SERVICE_UNAVAILABLE"')) return true;
  if (s.includes('"name":"RATE_LIMIT_REACHED"')) return true;
  if (s.includes('ECONNRESET') || s.includes('ETIMEDOUT') || s.includes('socket')) return true;
  if (s.includes('500') || s.includes('502') || s.includes('503') || s.includes('504')) return true;

  // ❌ أخطاء دائمة (لا تعيدي عليها)
  if (s.includes('invalid_client')) return false; // 401 credentials
  if (s.includes('"name":"VALIDATION_ERROR"')) return false; // 400 bad request

  // افتراضيًا: اعتبريه غير قابل للإعادة (أكثر أمانًا)
  return false;
}

function computeNextRetryMs(retryCount) {
  // backoff: 1m, 5m, 15m, 60m (تقريبًا)
  const table = [60_000, 5 * 60_000, 15 * 60_000, 60 * 60_000];
  return table[Math.min(retryCount, table.length - 1)];
}

exports.autoRetryPayoutOnFailedUpdated = onDocumentUpdated(
  {
    document: 'payouts/{payoutId}',
    region: 'us-central1',
    secrets: [PAYPAL_BASE_URL_SECRET, PAYPAL_CLIENT_ID_SECRET, PAYPAL_CLIENT_SECRET_SECRET],
  },
  async (event) => {
    const payoutId = event.params.payoutId;
    const before = event.data?.before?.data() || null;
    const after  = event.data?.after?.data() || null;
    if (!after) return;

    // شغّليها فقط ضمن سياقك
    if (after.context !== 'mediaMarket') return;
    if (!after.payoutProvider || !after.destination) return;

    // 🔥 فقط عند الانتقال إلى failed (مش أي update)
    if (before?.status === 'failed') return;
    if (after.status !== 'failed') return;

    // Retry guards
    const retryCount = Number(after.retryCount || 0);
    const maxRetries = Number(after.maxRetries || 4);
    const lastError = String(after.lastError || '');

    if (lastError.includes('invalid_client')) return;
    if (lastError.includes('VALIDATION_ERROR')) return;

    if (retryCount >= maxRetries) {
      console.log('Max retries reached, keeping failed', payoutId, { retryCount, maxRetries });
      return;
    }

    // nextRetryAt gate (إذا ما بدك، فيكي تشيليه ويصير retry مباشرة)
    const now = Date.now();
    const nextRetryAt = after.nextRetryAt?.toMillis?.() ?? 0;

    // 1) جهزي doc للمحاولة الجديدة (queued + nextRetryAt جديد)
    // IMPORTANT: نعمل update قبل الإرسال لتجنب تكرارات لو صار trigger مرتين
    const delayMs = computeNextRetryMs(retryCount);
    const newNextRetryAt = admin.firestore.Timestamp.fromMillis(now + delayMs);

        await event.data.after.ref.set({
          status: 'queued',
          retryCount: retryCount + 1,
          nextRetryAt: admin.firestore.Timestamp.fromMillis(Date.now() + delayMs),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        }, { merge: true });

    // 2) ابعتي payout (التريغر الآخر تبع queued updated رح يلتقطه)
    // إذا ما عندك queued-updated trigger، نادِ sendPayoutInternal هون مباشرة:
     await sendPayoutInternal(payoutId);

    console.log('Retry scheduled by switching to queued', payoutId, {
      retryCount: retryCount + 1,
      nextRetryAt: newNextRetryAt.toDate().toISOString(),
    });
  }
);


async function sendPayoutInternal(payoutId) {
  const payoutRef = db.collection('payouts').doc(payoutId);

  // lock payout -> processing
  const result = await db.runTransaction(async (tx) => {
    const snap = await tx.get(payoutRef);
    if (!snap.exists) throw new Error('Payout not found');

    const p = snap.data();

    if (p.status === 'sent' || p.status === 'sent_mock') {
      return { already: true, payout: p };
    }
    if (p.status !== 'queued') {
      return { already: true, payout: p }; // ما نعمل شي
    }

    if (!p.payoutProvider || !p.destination) {
      throw new Error('Missing payoutProvider/destination');
    }

    tx.update(payoutRef, {
      status: 'processing',
      processingAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return { already: false, payout: p };
  });

  if (result.already) return { ok: true, alreadySent: true };

  const p = result.payout;

  try {
    // ===== Stripe =====
    if (p.payoutProvider === 'stripe') {
      const stripe = getStripe();
      const acct = p.destination?.stripeConnectAccountId;
      if (!acct) throw new Error('Missing stripeConnectAccountId');

      const currency = (p.currency || 'EUR').toLowerCase();
      const cents = toCents(p.freelancerNet ?? p.amount ?? p.grossAmount);
      if (!cents) throw new Error('Invalid payout amount');

      const transfer = await stripe.transfers.create({
        amount: cents,
        currency,
        destination: acct,
        metadata: {
          payoutId,
          contractId: p.contractId || '',
          purchaseId: p.purchaseId || '',
          context: p.context || '',
        },
      });

      await payoutRef.set({
        status: 'sent',
        sentAt: admin.firestore.FieldValue.serverTimestamp(),
        providerPayoutRef: transfer.id,
        providerResponse: { type: 'stripe_transfer' },
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      }, { merge: true });

      // تحديث المرجع حسب السياق
      await markReferencePaidOutOrSent(p);

      return { ok: true, provider: 'stripe', providerPayoutRef: transfer.id };
    }

    // ===== PayPal =====
    if (p.payoutProvider === 'paypal') {
      const email = p.destination?.paypalPayoutEmail;
      if (!email) throw new Error('Missing paypalPayoutEmail');

      const currency = (p.currency || 'EUR').toUpperCase();
      const amount = Number(p.freelancerNet ?? p.amount ?? p.grossAmount);
      if (!Number.isFinite(amount) || amount <= 0) throw new Error('Invalid payout amount');

      const resp = await paypalCreatePayout({
        receiverEmail: email,
        amount,
        currency,
        note: `Payout for ${p.context || ''} ${p.contractId || p.purchaseId || ''}`,
        senderItemId: payoutId,
      });

      const batchId = resp?.batch_header?.payout_batch_id || null;

      await payoutRef.set({
        status: 'sent',
        sentAt: admin.firestore.FieldValue.serverTimestamp(),
        providerPayoutRef: batchId,
        providerResponse: { type: 'paypal_payout', raw: resp },
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      }, { merge: true });

      await markReferencePaidOutOrSent(p);

      return { ok: true, provider: 'paypal', providerPayoutRef: batchId };
    }

    throw new Error(`Unsupported payoutProvider=${p.payoutProvider}`);
  } catch (e) {
    console.error('sendPayoutInternal error', e);

   await payoutRef.set({
     status: 'failed',
     lastError: String(e?.message || e),
     lastErrorAt: admin.firestore.FieldValue.serverTimestamp(),
     retryCount: admin.firestore.FieldValue.increment(1),
     maxRetries: 4,
     nextRetryAt: admin.firestore.Timestamp.fromMillis(Date.now() + 60_000),

     updatedAt: admin.firestore.FieldValue.serverTimestamp(),
   }, { merge: true });


    throw e;
  }
}

async function markReferencePaidOutOrSent(p) {
  if (p.context === 'mediaMarket') {
    if (!p.purchaseId) return;

    await db.collection('purchases').doc(p.purchaseId).set({
      payoutStatus: 'sent',
      payoutSentAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });

    return;
  }


  if (p.contractId) {
    const paidOutAt = admin.firestore.FieldValue.serverTimestamp();
    const disputeDeadline = admin.firestore.Timestamp.fromDate(
      new Date(Date.now() + 14 * 24 * 60 * 60 * 1000)
    );
    const downloadDeadline = admin.firestore.Timestamp.fromDate(
      new Date(Date.now() + 90 * 24 * 60 * 60 * 1000)
    );

    await db.collection('contracts').doc(p.contractId).set({
      status: 'paidOut',
      paidOutAt,
      disputeDeadline,
      downloadDeadline,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });
  }
}



