const functions = require('firebase-functions');
const admin = require('firebase-admin');
// UPDATED: Destructure the new SDK components
const { Client, Environment } = require('@paypal/paypal-server-sdk');

let _paypalClient = null;
const db = admin.firestore();
const COMPANY_FEE_PERCENT = 0.15;

const { defineString } = require('firebase-functions/params');
// Stripe
const STRIPE_SECRET = defineString('STRIPE_SECRET');

// PayPal
const PAYPAL_CLIENT_ID = defineString('PAYPAL_CLIENT_ID');
const PAYPAL_SECRET = defineString('PAYPAL_SECRET');

// ================== UPDATED: PayPal Client Setup ==================
function getPayPalClient() {
  if (_paypalClient) return _paypalClient;

  const clientId = PAYPAL_CLIENT_ID.value();
  const secret = PAYPAL_SECRET.value();

  if (!clientId || !secret) return null;

  _paypalClient = new Client({
    clientCredentials: {
      clientId,
      clientSecret: secret,
    },
    environment: Environment.Sandbox, // أو Environment.Production للإنتاج
  });
  return _paypalClient;
}

// ======================== Create PayPal Escrow ========================
exports.createPaypalEscrow = functions.https.onCall(async (data, context) => {
  if (!context.auth)
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');

  const { amount, jobId } = data;
  if (!amount || !jobId)
    throw new functions.https.HttpsError('invalid-argument', 'amount and jobId are required');
  if (amount <= 0)
    throw new functions.https.HttpsError('invalid-argument', 'amount must be greater than 0');

  try {
    const client = getPayPalClient();
    if (!client)
      throw new functions.https.HttpsError('failed-precondition', 'PayPal is not configured.');

    // UPDATED: Use client.ordersController.ordersCreate
    const response = await client.ordersController.ordersCreate({
      body: {
        intent: 'AUTHORIZE',
        purchase_units: [
          {
            amount: {
              currency_code: 'USD',
              value: amount.toFixed(2),
            },
            custom_id: jobId,
          },
        ],
        application_context: {
          brand_name: 'We Source You',
          landing_page: 'NO_PREFERENCE',
          user_action: 'PAY_NOW',
        },
      },
      prefer: 'return=representation',
    });

    if (![201, 200].includes(response.statusCode))
      throw new Error(`PayPal order creation failed: ${response.statusCode}`);

    // UPDATED: Access result via .result
    const orderData = response.result;
    const orderId = orderData.id;

    await db.collection('payments').doc(jobId).set(
      {
        amount,
        status: 'pending',
        paymentMethod: 'paypal',
        orderId,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        createdBy: context.auth.uid,
      },
      { merge: true },
    );

    functions.logger.info('PayPal escrow created', { jobId, orderId, amount });

    const approveLink = orderData.links.find((link) => link.rel === 'approve');
    return {
      orderId,
      approvalUrl: approveLink ? approveLink.href : null,
    };
  } catch (error) {
    functions.logger.error('PayPal escrow creation failed', {
      jobId,
      error: error.message,
      stack: error.stack,
    });
    throw new functions.https.HttpsError('internal', `Failed to create escrow: ${error.message}`);
  }
});

// ======================== Capture PayPal Authorization ========================
exports.capturePaypalAuthorization = functions.https.onCall(async (data, context) => {
  if (!context.auth)
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');

  const { authorizationId, jobId } = data;
  if (!authorizationId || !jobId)
    throw new functions.https.HttpsError(
      'invalid-argument',
      'authorizationId and jobId are required',
    );

  try {
    const client = getPayPalClient();
    if (!client)
      throw new functions.https.HttpsError('failed-precondition', 'PayPal is not configured.');

    // UPDATED: Use client.paymentsController.authorizationsCapture
    const response = await client.paymentsController.authorizationsCapture({
      authorizationId: authorizationId,
      body: {}, // Empty body required
    });

    if (![201, 200].includes(response.statusCode))
      throw new Error(`PayPal capture failed: ${response.statusCode}`);

    const captureData = response.result;
    const captureId = captureData.id;

    const paymentRef = db.collection('payments').doc(jobId);
    await paymentRef.update({
      status: 'held',
      captureId,
      authorizationId,
      capturedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    functions.logger.info('PayPal authorization captured', { jobId, authorizationId, captureId });

    return { success: true, captureId };
  } catch (error) {
    functions.logger.error('PayPal capture failed', {
      jobId,
      error: error.message,
      stack: error.stack,
    });
    throw new functions.https.HttpsError(
      'internal',
      `Failed to capture authorization: ${error.message}`,
    );
  }
});

// ======================== Release PayPal Payment ========================
exports.releasePaypalPayment = functions.https.onCall(async (data, context) => {
  if (!context.auth)
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');

  const { jobId } = data;
  if (!jobId) throw new functions.https.HttpsError('invalid-argument', 'jobId is required');

  try {
    const paymentRef = db.collection('payments').doc(jobId);
    const paymentDoc = await paymentRef.get();
    if (!paymentDoc.exists)
      throw new functions.https.HttpsError('not-found', 'Payment document not found');

    const paymentData = paymentDoc.data();
    if (paymentData.status !== 'held')
      throw new functions.https.HttpsError(
        'failed-precondition',
        `Payment not held. Current status: ${paymentData.status}`,
      );
    if (paymentData.disputeStatus === 'open' || paymentData.disputeStatus === 'frozen') {
      throw new functions.https.HttpsError(
        'failed-precondition',
        'Cannot release payment: Payment is in dispute',
      );
    }
    if (!paymentData.captureId)
      throw new functions.https.HttpsError('failed-precondition', 'Payment not captured yet');

    const totalAmount = paymentData.amount;
    const companyFee = totalAmount * COMPANY_FEE_PERCENT;
    const workerAmount = totalAmount - companyFee;

    await paymentRef.update({
      status: 'released',
      companyFee,
      workerAmount,
      releasedAt: admin.firestore.FieldValue.serverTimestamp(),
      releasedBy: context.auth.uid,
    });

    functions.logger.info('PayPal payment released', {
      jobId,
      captureId: paymentData.captureId,
      companyFee,
      workerAmount,
    });

    return { success: true, companyFee, workerAmount };
  } catch (error) {
    functions.logger.error('PayPal payment release failed', {
      jobId,
      error: error.message,
      stack: error.stack,
    });
    if (error instanceof functions.https.HttpsError) throw error;
    throw new functions.https.HttpsError('internal', `Failed to release payment: ${error.message}`);
  }
});
