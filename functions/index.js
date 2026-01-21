const admin = require('firebase-admin');
admin.initializeApp();
//
//exports.acceptProposal = require('./proposals').acceptProposal;
//
//exports.createPaymentIntent = require('./payments').createPaymentIntent;
//exports.stripeWebhook = require('./payments').stripeWebhook;
//exports.ping = require('./debug').ping;
//
//exports.createCheckoutSession = require('./payments').createCheckoutSession;
//exports.createPayPalOrder =
//  require('./paypal/createPayPalOrder').createPayPalOrder;
//
//exports.paypalWebhook =
//  require('./paypal/paypalWebhook').paypalWebhook;
//

exports.ping = require('./debug').ping;

exports.createPaymentIntent = require('./payments').createPaymentIntent;
exports.createCheckoutSession = require('./payments').createCheckoutSession;
exports.stripeWebhook = require('./payments').stripeWebhook;

exports.createPayPalOrder = require('./paypal/createPayPalOrder').createPayPalOrder;
exports.paypalWebhook = require('./paypal/paypalWebhook').paypalWebhook;

exports.acceptProposal = require('./proposals').acceptProposal;

exports.submitDelivery = require('./contracts').submitDelivery;
exports.approveDelivery = require('./contracts').approveDelivery;
exports.confirmClose = require('./contracts').confirmClose;
exports.releasePayout = require('./contracts').releasePayout;


exports.getDownloadUrl = require('./downloads').getDownloadUrl;


