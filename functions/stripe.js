const functions = require('firebase-functions');
const admin = require('firebase-admin');
const Stripe = require('stripe');

const db = admin.firestore();
const COMPANY_FEE_PERCENT = 0.15;

const { defineString } = require('firebase-functions/params');
// Stripe
const STRIPE_SECRET = defineString('STRIPE_SECRET');

// PayPal
const PAYPAL_CLIENT_ID = defineString('PAYPAL_CLIENT_ID');
const PAYPAL_SECRET = defineString('PAYPAL_SECRET');

// ================== STRIPE ==================
const stripe = new Stripe(STRIPE_SECRET.value()); // بدل functions.config()

exports.createStripeEscrow = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  const { amount, jobId } = data;

  if (!amount || !jobId) {
    throw new functions.https.HttpsError('invalid-argument', 'amount and jobId are required');
  }

  if (amount <= 0) {
    throw new functions.https.HttpsError('invalid-argument', 'amount must be greater than 0');
  }

  try {
    const intent = await stripe.paymentIntents.create({
      amount: Math.round(amount * 100),
      currency: 'usd',
      capture_method: 'manual',
      metadata: {
        jobId: jobId,
        userId: context.auth.uid,
      },
    });

    await db.collection('payments').doc(jobId).set(
      {
        amount: amount,
        status: 'pending',
        paymentMethod: 'stripe',
        paymentIntentId: intent.id,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        createdBy: context.auth.uid,
      },
      { merge: true },
    );

    functions.logger.info('Stripe escrow created', {
      jobId,
      paymentIntentId: intent.id,
      amount,
    });

    return {
      clientSecret: intent.client_secret,
      paymentIntentId: intent.id,
    };
  } catch (error) {
    functions.logger.error('Stripe escrow creation failed', {
      jobId,
      error: error.message,
      stack: error.stack,
    });
    throw new functions.https.HttpsError('internal', `Failed to create escrow: ${error.message}`);
  }
});

exports.releaseStripePayment = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  const { jobId } = data;

  if (!jobId) {
    throw new functions.https.HttpsError('invalid-argument', 'jobId is required');
  }

  try {
    const paymentRef = db.collection('payments').doc(jobId);
    const paymentDoc = await paymentRef.get();

    if (!paymentDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Payment document not found');
    }

    const paymentData = paymentDoc.data();

    // Verify payment is held
    if (paymentData.status !== 'held') {
      throw new functions.https.HttpsError(
        'failed-precondition',
        `Payment not held. Current status: 
          ${paymentData.status}`,
      );
    }

    // Check for disputes
    if (paymentData.disputeStatus === 'open' || paymentData.disputeStatus === 'frozen') {
      throw new functions.https.HttpsError(
        'failed-precondition',
        'Cannot release payment: Payment is in dispute',
      );
    }

    const paymentIntentId = paymentData.paymentIntentId;
    if (!paymentIntentId) {
      throw new functions.https.HttpsError('failed-precondition', 'PaymentIntent ID not found');
    }

    // Capture the payment
    const capturedIntent = await stripe.paymentIntents.capture(paymentIntentId);

    if (capturedIntent.status !== 'succeeded') {
      throw new Error(`Payment capture failed. Status: 
        ${capturedIntent.status}`);
    }

    const totalAmount = paymentData.amount;
    const companyFee = totalAmount * COMPANY_FEE_PERCENT;
    const workerAmount = totalAmount - companyFee;

    // Update payment document
    await paymentRef.update({
      status: 'released',
      companyFee: companyFee,
      workerAmount: workerAmount,
      releasedAt: admin.firestore.FieldValue.serverTimestamp(),
      releasedBy: context.auth.uid,
      captureId: capturedIntent.latest_charge,
    });

    functions.logger.info('Stripe payment released', {
      jobId,
      paymentIntentId,
      companyFee,
      workerAmount,
    });

    return {
      success: true,
      companyFee: companyFee,
      workerAmount: workerAmount,
    };
  } catch (error) {
    functions.logger.error('Stripe payment release failed', {
      jobId,
      error: error.message,
      stack: error.stack,
    });

    if (error instanceof functions.https.HttpsError) {
      throw error;
    }

    throw new functions.https.HttpsError(
      'internal',
      `Failed to release payment: 
        ${error.message}`,
    );
  }
});
