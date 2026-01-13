const functions = require('firebase-functions');
const admin = require('firebase-admin');
const Stripe = require('stripe');
// UPDATED: Destructure the new SDK components
const { Client, Environment } = require('@paypal/paypal-server-sdk');

const db = admin.firestore();
const { defineString } = require('firebase-functions/params');
// Stripe
const STRIPE_SECRET = defineString('STRIPE_SECRET');

// PayPal
const PAYPAL_CLIENT_ID = defineString('PAYPAL_CLIENT_ID');
const PAYPAL_SECRET = defineString('PAYPAL_SECRET');

// ================== UPDATED: PayPal Client Setup ==================
// Initialize the Client with the new method
const paypalClient = new Client({
  clientCredentials: {
    clientId: PAYPAL_CLIENT_ID.value(),
    clientSecret: PAYPAL_SECRET.value(),
  },
  // Use Environment.Sandbox or Environment.Production
  environment: Environment.Sandbox,
});

// ========================== releaseMediaPayment ==========================
exports.releaseMediaPayment = functions.https.onCall(async (data, context) => {
  if (!context.auth)
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');

  const { transactionId, paymentMethod } = data;
  if (!transactionId)
    throw new functions.https.HttpsError('invalid-argument', 'transactionId is required');

  try {
    const transactionQuery = await db
      .collection('transactions')
      .where('transactionId', '==', transactionId)
      .limit(1)
      .get();

    if (transactionQuery.empty)
      throw new functions.https.HttpsError('not-found', 'Transaction not found');

    const transactionDoc = transactionQuery.docs[0];
    const transactionData = transactionDoc.data();

    if (transactionData.buyerId !== context.auth.uid && context.auth.token.role !== 'admin') {
      throw new functions.https.HttpsError('permission-denied', 'Not authorized');
    }

    let captureId;

    if (paymentMethod === 'stripe') {
      const paymentIntent = await stripe.paymentIntents.capture(transactionId);
      if (paymentIntent.status !== 'succeeded')
        throw new Error(`Capture failed: ${paymentIntent.status}`);
      captureId = paymentIntent.id;
    } else if (paymentMethod === 'paypal') {
      // UPDATED: Use ordersController.ordersGet
      const orderResponse = await paypalClient.ordersController.ordersGet({ id: transactionId });

      if (orderResponse.statusCode !== 200) throw new Error('Failed to get PayPal order');

      // Access result via .result
      const authorizationId = orderResponse.result.purchase_units[0].payments.authorizations[0].id;

      // UPDATED: Use paymentsController.authorizationsCapture
      const captureResponse = await paypalClient.paymentsController.authorizationsCapture({
        authorizationId: authorizationId,
        body: {}, // Empty body required
      });

      if (![201, 200].includes(captureResponse.statusCode))
        throw new Error(`PayPal capture failed: ${captureResponse.statusCode}`);

      captureId = captureResponse.result.id;
    } else {
      throw new Error('Invalid payment method');
    }

    await transactionDoc.ref.update({
      paymentStatus: 'completed',
      completedAt: admin.firestore.FieldValue.serverTimestamp(),
      captureId,
    });

    functions.logger.info('Media payment released', { transactionId, captureId });
    return { success: true, captureId };
  } catch (error) {
    functions.logger.error('Failed to release media payment', {
      error: error.message,
      transactionId,
    });
    throw new functions.https.HttpsError('internal', `Failed to release payment: ${error.message}`);
  }
});

// ========================== releaseHiringPayment ==========================
exports.releaseHiringPayment = functions.https.onCall(async (data, context) => {
  if (!context.auth)
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');

  const { hiringId, transactionId, paymentMethod } = data;
  if (!hiringId || !transactionId)
    throw new functions.https.HttpsError(
      'invalid-argument',
      'hiringId and transactionId are required',
    );

  try {
    const hiringDoc = await db.collection('hiring_records').doc(hiringId).get();
    if (!hiringDoc.exists)
      throw new functions.https.HttpsError('not-found', 'Hiring record not found');

    const hiringData = hiringDoc.data();
    if (hiringData.clientId !== context.auth.uid && context.auth.token.role !== 'admin') {
      throw new functions.https.HttpsError('permission-denied', 'Not authorized');
    }

    let captureId;

    if (paymentMethod === 'stripe') {
      const paymentIntent = await stripe.paymentIntents.capture(transactionId);
      captureId = paymentIntent.id;
    } else if (paymentMethod === 'paypal') {
      // UPDATED: Get Order
      const orderResponse = await paypalClient.ordersController.ordersGet({ id: transactionId });

      const authorizationId = orderResponse.result.purchase_units[0].payments.authorizations[0].id;

      // UPDATED: Capture Authorization
      const captureResponse = await paypalClient.paymentsController.authorizationsCapture({
        authorizationId: authorizationId,
        body: {},
      });

      captureId = captureResponse.result.id;
    }

    await hiringDoc.ref.update({
      contractStatus: 'active',
      startedAt: admin.firestore.FieldValue.serverTimestamp(),
      captureId,
    });

    return { success: true, captureId };
  } catch (error) {
    functions.logger.error('Failed to release hiring payment', { error: error.message });
    throw new functions.https.HttpsError('internal', `Failed to release payment: ${error.message}`);
  }
});

// ========================== releaseProposalPayment ==========================
exports.releaseProposalPayment = functions.https.onCall(async (data, context) => {
  if (!context.auth)
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');

  const { paymentId, transactionId, paymentMethod } = data;
  if (!paymentId || !transactionId)
    throw new functions.https.HttpsError(
      'invalid-argument',
      'paymentId and transactionId are required',
    );

  try {
    const paymentDoc = await db.collection('proposal_payments').doc(paymentId).get();
    if (!paymentDoc.exists) throw new functions.https.HttpsError('not-found', 'Payment not found');

    let captureId;

    if (paymentMethod === 'stripe') {
      const paymentIntent = await stripe.paymentIntents.capture(transactionId);
      captureId = paymentIntent.id;
    } else if (paymentMethod === 'paypal') {
      // UPDATED: Get Order
      const orderResponse = await paypalClient.ordersController.ordersGet({ id: transactionId });

      const authorizationId = orderResponse.result.purchase_units[0].payments.authorizations[0].id;

      // UPDATED: Capture Authorization
      const captureResponse = await paypalClient.paymentsController.authorizationsCapture({
        authorizationId: authorizationId,
        body: {},
      });

      captureId = captureResponse.result.id;
    }

    await paymentDoc.ref.update({
      paymentStatus: 'completed',
      paidAt: admin.firestore.FieldValue.serverTimestamp(),
      captureId,
    });

    return { success: true, captureId };
  } catch (error) {
    functions.logger.error('Failed to release proposal payment', { error: error.message });
    throw new functions.https.HttpsError('internal', `Failed to release payment: ${error.message}`);
  }
});
