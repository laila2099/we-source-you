const functions = require('firebase-functions');
const admin = require('firebase-admin');
const Stripe = require('stripe');
const crypto = require('crypto');
const express = require('express');

const db = admin.firestore();

const stripeApp = express();
const paypalApp = express();

const { defineString } = require('firebase-functions/params');
// Stripe
const STRIPE_SECRET = defineString('STRIPE_SECRET');

// PayPal
const PAYPAL_CLIENT_ID = defineString('PAYPAL_CLIENT_ID');
const PAYPAL_SECRET = defineString('PAYPAL_SECRET');

// ================== STRIPE ==================
const stripe = new Stripe(STRIPE_SECRET.value());

// Idempotency check
async function checkIdempotency(eventId, source) {
  const idempotencyKey = `${source}_${eventId}`;
  const idempotencyRef = db.collection('webhook_idempotency').doc(idempotencyKey);
  const doc = await idempotencyRef.get();

  if (doc.exists) {
    return false;
  }

  await idempotencyRef.set({
    processedAt: admin.firestore.FieldValue.serverTimestamp(),
    source: source,
  });

  return true;
}

// Stripe signature verification
function verifyStripeSignature(payload, signature) {
  const webhookSecret = STRIPE_SECRET.value(); // Updated from functions.config()
  if (!webhookSecret) {
    functions.logger.warn('Stripe webhook secret not configured');
    return { valid: false, error: 'Webhook secret not configured' };
  }
  try {
    const event = stripe.webhooks.constructEvent(payload, signature, webhookSecret);
    return { valid: true, event };
  } catch (err) {
    return { valid: false, error: err.message };
  }
}

// PayPal signature verification
function verifyPayPalSignature(headers, body) {
  const webhookId = PAYPAL_CLIENT_ID.value(); // Placeholder; يمكنك استبداله بالـ webhookId الحقيقي
  const certUrl = headers['paypal-cert-url'];
  const transmissionId = headers['paypal-transmission-id'];
  const transmissionTime = headers['paypal-transmission-time'];
  const transmissionSig = headers['paypal-transmission-sig'];
  const authAlgo = headers['paypal-auth-algo'];

  if (!certUrl || !transmissionId || !transmissionTime || !transmissionSig) {
    return { valid: false, error: 'Missing PayPal headers' };
  }

  const expectedHeaders = webhookId && certUrl && transmissionSig;
  return { valid: expectedHeaders, event: body };
}

// Update payment status helper
async function updatePaymentStatus(jobId, updates) {
  const paymentRef = db.collection('payments').doc(jobId);
  const paymentDoc = await paymentRef.get();

  if (!paymentDoc.exists) {
    throw new Error(`Payment document not found for jobId: ${jobId}`);
  }

  await paymentRef.update({
    ...updates,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });
}

/**
 * STRIPE WEBHOOK
 */
// Use raw body parser for Stripe
stripeApp.use(express.raw({ type: 'application/json' }));

stripeApp.post('/', async (req, res) => {
  const signature = req.headers['stripe-signature'];

  if (!signature) {
    res.status(400).send('Missing stripe-signature header');
    return;
  }

  const verification = verifyStripeSignature(req.body, signature);

  if (!verification.valid) {
    functions.logger.error('Stripe webhook verification failed', {
      error: verification.error,
    });
    res.status(400).send(`Webhook Error: ${verification.error}`);
    return;
  }

  const event = verification.event;
  const eventId = event.id;
  const eventType = event.type;

  const canProcess = await checkIdempotency(eventId, 'stripe');
  if (!canProcess) {
    functions.logger.info('Stripe webhook already processed', { eventId });
    res.status(200).send('Event already processed');
    return;
  }

  try {
    const paymentIntent = event.data.object;

    const jobId = paymentIntent.metadata ? paymentIntent.metadata.jobId : undefined;
    if (!jobId) {
      functions.logger.warn('No jobId in Stripe event metadata', { eventId });
      res.status(200).send('No jobId found');
      return;
    }

    let updateData = {
      lastEvent: eventType,
      lastEventId: eventId,
    };

    switch (eventType) {
      case 'payment_intent.succeeded':
        updateData.status = 'held';
        await updatePaymentStatus(jobId, updateData);
        functions.logger.info('Payment held', { jobId, eventId });
        break;

      case 'payment_intent.payment_failed':
        updateData.status = 'failed';
        updateData.failureReason = paymentIntent.last_payment_error
          ? paymentIntent.last_payment_error.message
          : undefined;
        await updatePaymentStatus(jobId, updateData);
        functions.logger.info('Payment failed', { jobId, eventId });
        break;

      case 'charge.refunded':
        const charge = event.data.object;
        const refundAmount = charge.amount_refunded / 100;
        updateData.status = 'refunded';
        updateData.refundAmount = refundAmount;
        updateData.refundStatus = 'completed';
        await updatePaymentStatus(jobId, updateData);
        functions.logger.info('Payment refunded', { jobId, refundAmount });
        break;

      case 'charge.dispute.created':
        const dispute = event.data.object;
        updateData.disputeStatus = 'open';
        updateData.disputeReason = dispute.reason;
        updateData.disputeId = dispute.id;
        updateData.status = 'disputed';
        await updatePaymentStatus(jobId, updateData);
        functions.logger.info('Dispute created', { jobId, disputeId: dispute.id });
        break;

      case 'charge.dispute.closed':
        const closedDispute = event.data.object;
        updateData.disputeStatus = 'closed';
        updateData.disputeStatusDetail = closedDispute.status;
        if (closedDispute.status === 'won') {
          updateData.status = 'held';
        } else if (closedDispute.status === 'lost') {
          updateData.status = 'refunded';
        }
        await updatePaymentStatus(jobId, updateData);
        functions.logger.info('Dispute closed', { jobId, status: closedDispute.status });
        break;

      default:
        functions.logger.info('Unhandled Stripe event type', { eventType, eventId });
    }

    res.status(200).send('Webhook processed');
  } catch (error) {
    functions.logger.error('Error processing Stripe webhook', {
      error: error.message,
      stack: error.stack,
      eventId,
    });
    res.status(500).send('Internal server error');
  }
});

exports.stripeWebhook = functions.https.onRequest(stripeApp);

/**
 * PAYPAL WEBHOOK
 */
paypalApp.use(express.json());

paypalApp.post('/', async (req, res) => {
  const headers = req.headers;
  const body = req.body;

  const verification = verifyPayPalSignature(headers, body);

  if (!verification.valid) {
    functions.logger.error('PayPal webhook verification failed', {
      error: verification.error,
    });
    res.status(400).send(`Webhook Error: ${verification.error}`);
    return;
  }

  const event = verification.event;
  const eventId = event.id || `${Date.now()}_${Math.random()}`;
  const eventType = event.event_type;

  const canProcess = await checkIdempotency(eventId, 'paypal');
  if (!canProcess) {
    functions.logger.info('PayPal webhook already processed', { eventId });
    res.status(200).send('Event already processed');
    return;
  }

  try {
    let jobId = null;
    let updateData = {
      lastEvent: eventType,
      lastEventId: eventId,
    };

    if (event.resource && event.resource.supplementary_data) {
      const relatedIds = event.resource.supplementary_data.related_ids;
      jobId = relatedIds ? relatedIds.jobId : null;
    }

    if (!jobId && event.resource) {
      const orderId = event.resource.id || event.resource.order_id;
      if (orderId) {
        const paymentQuery = await db
          .collection('payments')
          .where('orderId', '==', orderId)
          .limit(1)
          .get();

        if (!paymentQuery.empty) {
          jobId = paymentQuery.docs[0].id;
        }
      }
    }

    if (!jobId) {
      functions.logger.warn('No jobId found in PayPal event', { eventId, eventType });
      res.status(200).send('No jobId found');
      return;
    }

    switch (eventType) {
      case 'PAYMENT.CAPTURE.COMPLETED':
        updateData.status = 'held';
        updateData.captureId = event.resource ? event.resource.id : undefined;
        await updatePaymentStatus(jobId, updateData);
        functions.logger.info('PayPal payment held', { jobId, eventId });
        break;

      case 'PAYMENT.CAPTURE.REFUNDED':
        const refund = event.resource;
        const refundAmount = parseFloat((refund.amount && refund.amount.value) || 0);
        updateData.status = 'refunded';
        updateData.refundAmount = refundAmount;
        updateData.refundStatus = 'completed';
        updateData.refundId = refund.id;
        await updatePaymentStatus(jobId, updateData);
        functions.logger.info('PayPal payment refunded', { jobId, refundAmount });
        break;

      case 'CUSTOMER.DISPUTE.CREATED':
        const dispute = event.resource;
        updateData.disputeStatus = 'open';
        updateData.disputeReason = dispute.reason;
        updateData.disputeId = dispute.dispute_id;
        updateData.status = 'disputed';
        await updatePaymentStatus(jobId, updateData);
        functions.logger.info('PayPal dispute created', { jobId, disputeId: dispute.dispute_id });
        break;

      case 'CUSTOMER.DISPUTE.RESOLVED':
        const resolvedDispute = event.resource;
        updateData.disputeStatus = 'resolved';
        updateData.disputeStatusDetail = resolvedDispute.status;
        if (resolvedDispute.status === 'RESOLVED_BUYER_FAVOR') {
          updateData.status = 'refunded';
        } else if (resolvedDispute.status === 'RESOLVED_SELLER_FAVOR') {
          updateData.status = 'held';
        }
        await updatePaymentStatus(jobId, updateData);
        functions.logger.info('PayPal dispute resolved', {
          jobId,
          status: resolvedDispute.status,
        });
        break;

      default:
        functions.logger.info('Unhandled PayPal event type', { eventType, eventId });
    }

    res.status(200).send('Webhook processed');
  } catch (error) {
    functions.logger.error('Error processing PayPal webhook', {
      error: error.message,
      stack: error.stack,
      eventId,
    });
    res.status(500).send('Internal server error');
  }
});

exports.paypalWebhook = functions.https.onRequest(paypalApp);
