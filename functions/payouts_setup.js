const { defineSecret } = require('firebase-functions/params');
const { onCall, HttpsError } = require('firebase-functions/v2/https');
const admin = require('firebase-admin');
const db = admin.firestore();

const STRIPE_SECRET_KEY = defineSecret('STRIPE_SECRET_KEY');
const STRIPE_WEBHOOK_SECRET = defineSecret('STRIPE_WEBHOOK_SECRET');

function requireAuth(request) {
  const uid = request.auth?.uid;
  if (!uid) throw new HttpsError('unauthenticated', 'Login required');
  return uid;
}
function assertString(v, name) {
  if (!v || typeof v !== 'string') throw new HttpsError('invalid-argument', `${name} is required`);
}

exports.setPayoutProfilePayPal = onCall({ cors: true, invoker: 'public' }, async (request) => {
  const uid = requireAuth(request);
  const { email } = request.data || {};
  assertString(email, 'email');

  const clean = email.trim();
  if (!clean.includes('@')) {
    throw new HttpsError('invalid-argument', 'Invalid email');
  }

  const userRef = db.collection('users').doc(uid);

  await userRef.set(
    {
      payoutDefault: 'paypal',
      payoutProfile: {
        paypal: {
          enabled: true,
          provider: 'paypal',
          paypalEmail: clean,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
      },
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    },
    { merge: true },
  );

  return { ok: true };
});

const Stripe = require('stripe');

function getStripe() {
  const key = STRIPE_SECRET_KEY.value();
  assertString(key, 'STRIPE_SECRET_KEY');

  return new Stripe(key, { apiVersion: '2024-06-20' });
}

exports.createStripeAccountLink = onCall(
  { cors: true, invoker: 'public', secrets: [STRIPE_SECRET_KEY] },
  async (request) => {
    const uid = requireAuth(request);
    const { returnUrl, refreshUrl } = request.data || {};
    assertString(returnUrl, 'returnUrl');
    assertString(refreshUrl, 'refreshUrl');

    const stripe = getStripe();
    const userRef = db.collection('users').doc(uid);

    const userSnap = await userRef.get();
    const u = userSnap.exists ? userSnap.data() || {} : {};
    const payoutProfile = u.payoutProfile || {};
    const stripeProfile = payoutProfile.stripe || {};
    let accountId = stripeProfile.stripeConnectAccountId || null;

    // create account if missing
    if (!accountId) {
      const account = await stripe.accounts.create({
        type: 'express',
        metadata: { uid },
      });
      accountId = account.id;

      await userRef.set(
        {
          payoutDefault: 'stripe',
          payoutProfile: {
            stripe: {
              enabled: true,
              provider: 'stripe',
              stripeConnectAccountId: accountId,
              updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            },
          },
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
    } else {
      // ensure it's enabled + set default
      await userRef.set(
        {
          payoutDefault: 'stripe',
          [`payoutProfile.stripe.enabled`]: true,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
    }

    const link = await stripe.accountLinks.create({
      account: accountId,
      refresh_url: refreshUrl,
      return_url: returnUrl,
      type: 'account_onboarding',
    });

    return { ok: true, url: link.url, accountId };
  },
);
