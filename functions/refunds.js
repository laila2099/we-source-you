const functions = require('firebase-functions');
const admin = require('firebase-admin');
const Stripe = require('stripe');
// UPDATED: Destructure Client and Environment from the new SDK
const { Client, Environment } = require('@paypal/paypal-server-sdk');

admin.initializeApp(); // تم اضافة هذا السطر لتجنب أي خطأ في db

const db = admin.firestore();
const { defineString } = require('firebase-functions/params');
// Stripe
const STRIPE_SECRET = defineString('STRIPE_SECRET');

// PayPal
const PAYPAL_CLIENT_ID = defineString('PAYPAL_CLIENT_ID');
const PAYPAL_SECRET = defineString('PAYPAL_SECRET');

const stripe = new Stripe(STRIPE_SECRET.value()); // تم تعديل التهيئة لتعمل مع defineString()

// ================== UPDATED: PayPal Client Helper ==================
// دالة مساعدة لضمان تهيئة العميل بأمان وتجنب خطأ الـ undefined
function getPayPalClient() {
  if (!PAYPAL_CLIENT_ID.value() || !PAYPAL_SECRET.value()) {
    throw new Error(
      "PayPal configuration is missing. Run: firebase functions:params:set PAYPAL_CLIENT_ID='...' PAYPAL_SECRET='...'",
    );
  }

  return new Client({
    clientCredentials: {
      clientId: PAYPAL_CLIENT_ID.value(),
      clientSecret: PAYPAL_SECRET.value(),
    },
    // استخدم Environment.Live للإنتاج، و Sandbox للتطوير
    environment: Environment.Sandbox,
  });
}

// Verify admin user
async function verifyAdmin(context) {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  const userDoc = await db.collection('users').doc(context.auth.uid).get();
  const userData = userDoc.data();

  if (!userData || userData.role !== 'admin') {
    throw new functions.https.HttpsError('permission-denied', 'Admin access required');
  }

  return true;
}

// Full refund via Stripe
async function processStripeRefund(paymentDoc, refundAmount, reason) {
  const paymentData = paymentDoc.data();
  const paymentIntentId = paymentData.paymentIntentId;

  if (!paymentIntentId) throw new Error('PaymentIntent ID not found');

  if (paymentData.status === 'released')
    throw new Error('Cannot refund: Payment already released to worker');

  const paymentIntent = await stripe.paymentIntents.retrieve(paymentIntentId);
  if (paymentIntent.status !== 'succeeded')
    throw new Error(`Payment not captured. Current status: ${paymentIntent.status}`);

  const chargeId = paymentIntent.latest_charge;
  if (!chargeId) throw new Error('Charge ID not found');

  const refundParams = {
    charge: chargeId,
    amount: Math.round(refundAmount * 100),
    reason: reason || 'requested_by_customer',
    metadata: {
      jobId: paymentDoc.id,
      refundedBy: 'admin',
    },
  };

  const refund = await stripe.refunds.create(refundParams);
  return {
    refundId: refund.id,
    amount: refund.amount / 100,
    status: refund.status,
  };
}

// ================== UPDATED: Refund via PayPal ==================
async function processPayPalRefund(paymentDoc, refundAmount, reason) {
  const paymentData = paymentDoc.data();
  const captureId = paymentData.captureId;

  if (!captureId) throw new Error('PayPal capture ID not found');
  if (paymentData.status === 'released')
    throw new Error('Cannot refund: Payment already released to worker');

  try {
    const paypalClient = getPayPalClient(); // تهيئة العميل عند الحاجة فقط

    const response = await paypalClient.paymentsController.capturesRefund({
      captureId: captureId,
      body: {
        amount: {
          currency_code: 'USD',
          value: refundAmount.toFixed(2),
        },
        note_to_payer: reason || 'Refund requested by admin',
      },
    });

    if (![201, 200].includes(response.statusCode)) {
      throw new Error(`PayPal refund failed: ${response.statusCode}`);
    }

    const refundData = response.result;

    return {
      refundId: refundData.id,
      amount: parseFloat(refundData.amount.value),
      status: refundData.status,
    };
  } catch (error) {
    throw new Error(`PayPal Refund Error: ${error.message}`);
  }
}

// ========================== Full Refund Function ==========================
exports.processFullRefund = functions.https.onCall(async (data, context) => {
  await verifyAdmin(context);

  const { jobId, reason } = data;
  if (!jobId) throw new functions.https.HttpsError('invalid-argument', 'jobId is required');

  const paymentRef = db.collection('payments').doc(jobId);
  const paymentDoc = await paymentRef.get();
  if (!paymentDoc.exists)
    throw new functions.https.HttpsError('not-found', 'Payment document not found');

  const paymentData = paymentDoc.data();
  if (paymentData.status === 'refunded')
    throw new functions.https.HttpsError('failed-precondition', 'Payment already refunded');
  if (paymentData.status === 'disputed')
    throw new functions.https.HttpsError('failed-precondition', 'Cannot refund payment in dispute');

  const refundAmount = paymentData.amount;
  let refundResult;

  try {
    if (paymentData.paymentMethod === 'stripe' || paymentData.paymentIntentId) {
      refundResult = await processStripeRefund(paymentDoc, refundAmount, reason);
    } else if (paymentData.paymentMethod === 'paypal' || paymentData.captureId) {
      refundResult = await processPayPalRefund(paymentDoc, refundAmount, reason);
    } else {
      throw new Error('Unknown payment method');
    }

    await paymentRef.update({
      status: 'refunded',
      refundStatus: 'completed',
      refundAmount: refundResult.amount,
      refundId: refundResult.refundId,
      refundReason: reason || 'Full refund by admin',
      refundedAt: admin.firestore.FieldValue.serverTimestamp(),
      refundedBy: context.auth.uid,
    });

    return {
      success: true,
      refundId: refundResult.refundId,
      amount: refundResult.amount,
      status: refundResult.status,
    };
  } catch (error) {
    functions.logger.error('Refund processing failed', { jobId, error: error.message });
    await paymentRef.update({ refundStatus: 'failed', refundError: error.message });
    throw new functions.https.HttpsError('internal', `Refund failed: ${error.message}`);
  }
});

// ========================== Partial Refund Function ==========================
exports.processPartialRefund = functions.https.onCall(async (data, context) => {
  await verifyAdmin(context);

  const { jobId, refundAmount, reason } = data;
  if (!jobId || !refundAmount)
    throw new functions.https.HttpsError('invalid-argument', 'jobId and refundAmount are required');

  const paymentRef = db.collection('payments').doc(jobId);
  const paymentDoc = await paymentRef.get();
  if (!paymentDoc.exists)
    throw new functions.https.HttpsError('not-found', 'Payment document not found');

  const paymentData = paymentDoc.data();
  const totalAmount = paymentData.amount;

  if (refundAmount > totalAmount)
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Refund amount cannot exceed payment amount',
    );

  let refundResult;

  try {
    if (paymentData.paymentMethod === 'stripe' || paymentData.paymentIntentId) {
      refundResult = await processStripeRefund(paymentDoc, refundAmount, reason);
    } else if (paymentData.paymentMethod === 'paypal' || paymentData.captureId) {
      refundResult = await processPayPalRefund(paymentDoc, refundAmount, reason);
    } else {
      throw new Error('Unknown payment method');
    }

    const remainingAmount = totalAmount - refundResult.amount;

    await paymentRef.update({
      status: 'partially_refunded',
      refundStatus: 'completed',
      refundAmount: refundResult.amount,
      remainingAmount,
      refundId: refundResult.refundId,
      refundReason: reason || 'Partial refund by admin',
      refundedAt: admin.firestore.FieldValue.serverTimestamp(),
      refundedBy: context.auth.uid,
    });

    return {
      success: true,
      refundId: refundResult.refundId,
      refundAmount: refundResult.amount,
      remainingAmount,
      status: refundResult.status,
    };
  } catch (error) {
    functions.logger.error('Partial refund processing failed', { jobId, error: error.message });
    await paymentRef.update({ refundStatus: 'failed', refundError: error.message });
    throw new functions.https.HttpsError('internal', `Refund failed: ${error.message}`);
  }
});

// ========================== Handle Dispute Function ==========================
exports.handleDispute = functions.https.onCall(async (data, context) => {
  await verifyAdmin(context);

  const { jobId, action, notes } = data;
  if (!jobId || !action)
    throw new functions.https.HttpsError('invalid-argument', 'jobId and action are required');

  const paymentRef = db.collection('payments').doc(jobId);
  const paymentDoc = await paymentRef.get();
  if (!paymentDoc.exists)
    throw new functions.https.HttpsError('not-found', 'Payment document not found');

  const paymentData = paymentDoc.data();

  if (paymentData.disputeStatus !== 'open')
    throw new functions.https.HttpsError('failed-precondition', 'No active dispute found');

  if (paymentData.status !== 'released') {
    await paymentRef.update({
      status: 'disputed',
      disputeStatus: action === 'freeze' ? 'frozen' : paymentData.disputeStatus,
      disputeNotes: notes || '',
      disputeHandledAt: admin.firestore.FieldValue.serverTimestamp(),
      disputeHandledBy: context.auth.uid,
    });
  }

  return { success: true, message: 'Dispute handled successfully' };
});
