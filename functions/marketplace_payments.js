const functions = require('firebase-functions');
const admin = require('firebase-admin');
const Stripe = require('stripe');
// UPDATED: Destructure the new SDK components
const { Client, Environment } = require('@paypal/paypal-server-sdk');

const { defineString } = require('firebase-functions/params');

// Stripe
const STRIPE_SECRET = defineString('STRIPE_SECRET');

// PayPal
const PAYPAL_CLIENT_ID = defineString('PAYPAL_CLIENT_ID');
const PAYPAL_SECRET = defineString('PAYPAL_SECRET');

const db = admin.firestore();

const PLATFORM_FEE_PERCENT = 0.15;

// ================== PayPal Client Setup ==================
let _paypalClient = null;
function getPayPalClient() {
  if (_paypalClient) return _paypalClient;

  const clientId = PAYPAL_CLIENT_ID.value();
  const secret = PAYPAL_SECRET.value();

  if (!clientId || !secret) return null;

  // UPDATED: New initialization pattern for @paypal/paypal-server-sdk
  _paypalClient = new Client({
    clientCredentials: {
      clientId: clientId,
      clientSecret: secret,
    },
    // Use Environment.Live for production
    environment: Environment.Sandbox,
  });
  return _paypalClient;
}

// ================== PayPal Order Creation Helper ==================
async function createPayPalOrder(intentType, purchaseUnits) {
  const client = getPayPalClient();
  if (!client) throw new Error('PayPal client not configured');

  // UPDATED: Use the ordersController pattern
  try {
    const response = await client.ordersController.ordersCreate({
      body: {
        intent: intentType, // 'CAPTURE' or 'AUTHORIZE'
        purchase_units: purchaseUnits,
        application_context: {
          brand_name: 'We Source You',
          landing_page: 'NO_PREFERENCE',
          user_action: 'PAY_NOW',
        },
      },
    });

    // In new SDK, data is in response.result
    const orderResult = response.result;
    const approveLink = orderResult.links.find((link) => link.rel === 'approve');

    return {
      orderId: orderResult.id,
      approvalUrl: approveLink ? approveLink.href : null,
    };
  } catch (error) {
    throw new functions.https.HttpsError(
      'internal',
      `PayPal order creation failed: ${error.message}`,
    );
  }
}

// ================== PayPal Capture Helper ==================
async function capturePayPalAuthorization(authorizationId) {
  const client = getPayPalClient();
  if (!client) throw new Error('PayPal client not configured');

  // UPDATED: Use the paymentsController pattern
  try {
    const response = await client.paymentsController.authorizationsCapture({
      authorizationId: authorizationId,
      body: {},
    });

    return {
      captureId: response.result.id,
      status: response.result.status,
    };
  } catch (error) {
    throw new functions.https.HttpsError('internal', `PayPal capture failed: ${error.message}`);
  }
}

// ================== Media PayPal Order ==================
exports.createMediaPayPalOrder = functions.https.onCall(async (data, context) => {
  if (!context.auth)
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  const { mediaId, amount } = data;

  const mediaDoc = await db.collection('media_items').doc(mediaId).get();
  if (!mediaDoc.exists) throw new Error('Media item not found');
  const serverPrice = mediaDoc.data().price || 0;
  if (Math.abs(amount - serverPrice) > 0.01)
    throw new Error(`Price mismatch: Server=${serverPrice}, Client=${amount}`);

  const purchaseUnits = [
    {
      amount: {
        currency_code: 'USD',
        value: (serverPrice * (1 + PLATFORM_FEE_PERCENT)).toFixed(2),
      },
      custom_id: mediaId,
      description: `Media purchase: ${mediaId}`,
    },
  ];

  return await createPayPalOrder('CAPTURE', purchaseUnits);
});

// ================== Hiring PayPal Order ==================
exports.createHiringPayPalOrder = functions.https.onCall(async (data, context) => {
  if (!context.auth)
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  const { teamId, hireType, rate } = data;

  const teamDoc = await db.collection('team').doc(teamId).get();
  if (!teamDoc.exists) throw new Error('Team member not found');

  let serverRate = 0;
  switch (hireType) {
    case 'hourly':
      serverRate = parseFloat((teamDoc.data().hourlyRate || '0').replace(/[^\d.]/g, ''));
      break;
    case 'daily':
      serverRate = parseFloat((teamDoc.data().dailyRate || '0').replace(/[^\d.]/g, ''));
      break;
    case 'project':
      serverRate = parseFloat((teamDoc.data().projectRate || '0').replace(/[^\d.]/g, ''));
      break;
    default:
      throw new Error('Invalid hire type');
  }
  if (Math.abs(rate - serverRate) > 0.01)
    throw new Error(`Rate mismatch: Server=${serverRate}, Client=${rate}`);

  const purchaseUnits = [
    {
      amount: {
        currency_code: 'USD',
        value: (serverRate * (1 + PLATFORM_FEE_PERCENT)).toFixed(2),
      },
      custom_id: `${teamId}_${hireType}`,
      description: `Hiring: ${hireType} rate`,
    },
  ];

  return await createPayPalOrder('AUTHORIZE', purchaseUnits);
});

// ================== Proposal PayPal Order ==================
exports.createProposalPayPalOrder = functions.https.onCall(async (data, context) => {
  if (!context.auth)
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  const { proposalId, jobId, amount } = data;

  const jobDoc = await db.collection('jobs').doc(jobId).get();
  if (!jobDoc.exists) throw new Error('Job not found');

  const serverAmount = jobDoc.data().budget || 0;
  if (Math.abs(amount - serverAmount) > 0.01)
    throw new Error(`Amount mismatch: Server=${serverAmount}, Client=${amount}`);

  const purchaseUnits = [
    {
      amount: {
        currency_code: 'USD',
        value: (serverAmount * (1 + PLATFORM_FEE_PERCENT)).toFixed(2),
      },
      custom_id: jobId,
    },
  ];

  return await createPayPalOrder('AUTHORIZE', purchaseUnits);
});

// ================== Capture PayPal Authorization ==================
exports.capturePayPalPayment = functions.https.onCall(async (data, context) => {
  if (!context.auth)
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  const { orderId } = data;

  const client = getPayPalClient();
  if (!client) throw new Error('PayPal client not configured');

  try {
    // UPDATED: Get order details
    const response = await client.ordersController.ordersGet({ id: orderId });
    const orderResult = response.result;

    const authorization = orderResult.purchase_units[0].payments.authorizations?.[0];
    if (!authorization)
      throw new functions.https.HttpsError(
        'failed-precondition',
        'Authorization not found for this order',
      );

    return await capturePayPalAuthorization(authorization.id);
  } catch (error) {
    throw new functions.https.HttpsError(
      'internal',
      `Failed to process PayPal payment: ${error.message}`,
    );
  }
});
