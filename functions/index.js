const admin = require('firebase-admin');
admin.initializeApp();

// Stripe Functions
exports.createStripeEscrow = require('./stripe').createStripeEscrow;
exports.releaseStripePayment = require('./stripe').releaseStripePayment;

// PayPal Functions
exports.createPaypalEscrow = require('./paypal').createPaypalEscrow;
exports.capturePaypalAuthorization = require('./paypal').capturePaypalAuthorization;
exports.releasePaypalPayment = require('./paypal').releasePaypalPayment;

// Webhook Handlers
exports.stripeWebhook = require('./webhooks').stripeWebhook;
exports.paypalWebhook = require('./webhooks').paypalWebhook;

// Refund & Dispute Functions
exports.processFullRefund = require('./refunds').processFullRefund;
exports.processPartialRefund = require('./refunds').processPartialRefund;
exports.handleDispute = require('./refunds').handleDispute;

// Payout Functions
exports.processAutoPayout = require('./payouts').processAutoPayout;
exports.autoPayoutAfterDisputePeriod = require('./payouts').autoPayoutAfterDisputePeriod;

// Marketplace Payment Functions
exports.createMediaPaymentIntent = require('./marketplace_payments').createMediaPaymentIntent;
exports.createHiringPaymentIntent = require('./marketplace_payments').createHiringPaymentIntent;
exports.createProposalPaymentIntent = require('./marketplace_payments').createProposalPaymentIntent;
exports.createMediaPayPalOrder = require('./marketplace_payments').createMediaPayPalOrder;
exports.createHiringPayPalOrder = require('./marketplace_payments').createHiringPayPalOrder;
exports.createProposalPayPalOrder = require('./marketplace_payments').createProposalPayPalOrder;
exports.capturePayPalPayment = require('./marketplace_payments').capturePayPalPayment;

// Release payment functions (after work completion)
exports.releaseMediaPayment = require('./release_marketplace_payments').releaseMediaPayment;
exports.releaseHiringPayment = require('./release_marketplace_payments').releaseHiringPayment;
exports.releaseProposalPayment = require('./release_marketplace_payments').releaseProposalPayment;

// KYC
exports.createSumsubAccessToken = require('./sumsub').createSumsubAccessToken;
exports.sumsubWebhook = require('./sumsubWebhooks').sumsubWebhook;

// Admin Manual KYC Function
exports.adminReviewKyc = require('./admin_kyc').adminReviewKyc;
