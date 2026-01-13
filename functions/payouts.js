const functions = require('firebase-functions');
const admin = require('firebase-admin');
const Stripe = require('stripe');
// UPDATED: Destructure the new SDK components
const { Client, Environment } = require('@paypal/paypal-server-sdk');

const db = admin.firestore();

const COMPANY_FEE_PERCENT = 0.15; // 15%
const { defineString } = require('firebase-functions/params');
// Stripe
const STRIPE_SECRET = defineString('STRIPE_SECRET');

// PayPal
const PAYPAL_CLIENT_ID = defineString('PAYPAL_CLIENT_ID');
const PAYPAL_SECRET = defineString('PAYPAL_SECRET');

const stripe = new Stripe(STRIPE_SECRET.value()); // موحد مع defineString()

// ======================== PayPal Client Setup ========================
let _paypalClient = null;
function getPayPalClient() {
  if (_paypalClient) return _paypalClient;

  if (!PAYPAL_CLIENT_ID.value() || !PAYPAL_SECRET.value()) {
    throw new Error(
      "PayPal configuration is missing. Run: firebase functions:params:set PAYPAL_CLIENT_ID='...' PAYPAL_SECRET='...'",
    );
  }

  // UPDATED: New initialization pattern for @paypal/paypal-server-sdk
  _paypalClient = new Client({
    clientCredentials: {
      clientId: PAYPAL_CLIENT_ID.value(),
      clientSecret: PAYPAL_SECRET.value(),
    },
    // Use Environment.Production for live
    environment: Environment.Sandbox,
  });
  return _paypalClient;
}

// ======================== Stripe Payout ========================
async function processStripePayout(paymentData, workerStripeAccountId) {
  if (!workerStripeAccountId) throw new Error('Worker Stripe account ID not found');

  const totalAmount = paymentData.amount;
  const companyFee = totalAmount * COMPANY_FEE_PERCENT;
  const workerAmount = totalAmount - companyFee;

  const transfer = await stripe.transfers.create({
    amount: Math.round(workerAmount * 100),
    currency: 'usd',
    destination: workerStripeAccountId,
    metadata: {
      jobId: paymentData.jobId,
      companyFee: companyFee.toFixed(2),
    },
  });

  return {
    transferId: transfer.id,
    workerAmount,
    companyFee,
    status: transfer.status,
  };
}

// ======================== PayPal Payout ========================
async function processPayPalPayout(paymentData, workerPayPalEmail) {
  if (!workerPayPalEmail) throw new Error('Worker PayPal email not found');

  const client = getPayPalClient();
  if (!client) throw new Error('PayPal client not configured');

  const totalAmount = paymentData.amount;
  const companyFee = totalAmount * COMPANY_FEE_PERCENT;
  const workerAmount = totalAmount - companyFee;

  // UPDATED: Use the new payoutsController pattern
  try {
    const response = await client.payoutsController.payoutsPost({
      body: {
        sender_batch_header: {
          sender_batch_id: `PAYOUT_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
          email_subject: 'Payment from We Source You',
          email_message: 'You have received a payment for your completed work.',
        },
        items: [
          {
            recipient_type: 'EMAIL',
            amount: {
              value: workerAmount.toFixed(2),
              currency: 'USD',
            },
            receiver: workerPayPalEmail,
            note: `Payment for job: ${paymentData.jobId}`,
            sender_item_id: paymentData.jobId,
          },
        ],
      },
    });

    // In the new SDK, response.result contains the data
    const payoutResult = response.result;

    return {
      payoutId: payoutResult.batch_header.payout_batch_id,
      workerAmount,
      companyFee,
      status: payoutResult.batch_header.batch_status,
    };
  } catch (error) {
    throw new Error(`PayPal payout failed: ${error.message}`);
  }
}

// ======================== Auto Payout Function ========================
exports.processAutoPayout = functions.https.onCall(async (data, context) => {
  if (!context.auth)
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');

  const { jobId } = data;
  if (!jobId) throw new functions.https.HttpsError('invalid-argument', 'jobId is required');

  const paymentRef = db.collection('payments').doc(jobId);
  const paymentDoc = await paymentRef.get();
  if (!paymentDoc.exists)
    throw new functions.https.HttpsError('not-found', 'Payment document not found');

  const paymentData = paymentDoc.data();

  const payoutRef = db.collection('payouts').doc(jobId);
  const payoutDoc = await payoutRef.get();
  if (payoutDoc.exists && payoutDoc.data().payoutStatus === 'completed') {
    throw new functions.https.HttpsError('failed-precondition', 'Payout already completed');
  }

  if (paymentData.status !== 'released') {
    throw new functions.https.HttpsError(
      'failed-precondition',
      `Payment not released. Current status: ${paymentData.status}`,
    );
  }

  if (paymentData.disputeStatus === 'open' || paymentData.disputeStatus === 'frozen') {
    throw new functions.https.HttpsError(
      'failed-precondition',
      'Cannot payout: Payment is in dispute',
    );
  }

  const jobDoc = await db.collection('jobs').doc(jobId).get();
  if (!jobDoc.exists) throw new functions.https.HttpsError('not-found', 'Job document not found');

  const jobData = jobDoc.data();
  const workerId = jobData.workerId || jobData.acceptedBy;
  if (!workerId) throw new functions.https.HttpsError('not-found', 'Worker ID not found in job');

  const workerDoc = await db.collection('users').doc(workerId).get();
  if (!workerDoc.exists)
    throw new functions.https.HttpsError('not-found', 'Worker document not found');

  const workerData = workerDoc.data();
  const workerStripeAccountId = workerData.stripeAccountId;
  const workerPayPalEmail = workerData.paypalEmail;

  if (!workerStripeAccountId && !workerPayPalEmail) {
    throw new functions.https.HttpsError(
      'failed-precondition',
      'Worker payment method not configured',
    );
  }

  let payoutResult;

  try {
    if (paymentData.paymentMethod === 'stripe' || paymentData.paymentIntentId) {
      if (!workerStripeAccountId) throw new Error('Worker Stripe account not configured');
      payoutResult = await processStripePayout(paymentData, workerStripeAccountId);
    } else if (paymentData.paymentMethod === 'paypal' || paymentData.captureId) {
      if (!workerPayPalEmail) throw new Error('Worker PayPal email not configured');
      payoutResult = await processPayPalPayout(paymentData, workerPayPalEmail);
    } else {
      throw new Error('Unknown payment method');
    }

    await payoutRef.set(
      {
        jobId,
        workerId,
        workerAmount: payoutResult.workerAmount,
        companyFee: payoutResult.companyFee,
        payoutStatus: 'completed',
        payoutId: payoutResult.payoutId || payoutResult.transferId,
        paymentMethod: paymentData.paymentMethod,
        completedAt: admin.firestore.FieldValue.serverTimestamp(),
        processedBy: context.auth.uid,
      },
      { merge: true },
    );

    await paymentRef.update({
      payoutStatus: 'completed',
      payoutId: payoutResult.payoutId || payoutResult.transferId,
      payoutCompletedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    functions.logger.info('Auto payout processed', {
      jobId,
      workerId,
      payoutId: payoutResult.payoutId || payoutResult.transferId,
      workerAmount: payoutResult.workerAmount,
      companyFee: payoutResult.companyFee,
    });

    return {
      success: true,
      payoutId: payoutResult.payoutId || payoutResult.transferId,
      workerAmount: payoutResult.workerAmount,
      companyFee: payoutResult.companyFee,
      status: payoutResult.status,
    };
  } catch (error) {
    functions.logger.error('Auto payout processing failed', {
      jobId,
      error: error.message,
      stack: error.stack,
    });
    await payoutRef.set(
      {
        jobId,
        workerId,
        payoutStatus: 'failed',
        payoutError: error.message,
        failedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
    throw new functions.https.HttpsError('internal', `Payout failed: ${error.message}`);
  }
});
