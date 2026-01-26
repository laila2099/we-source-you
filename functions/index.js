const admin = require('firebase-admin');
admin.initializeApp();

exports.ping = require('./debug').ping;

exports.createPaymentIntent = require('./payments').createPaymentIntent;
exports.createCheckoutSession = require('./payments').createCheckoutSession;
exports.webhooksStripeDev = require('./payments').webhooksStripeDev;

exports.createPayPalOrder = require('./paypal/createPayPalOrder').createPayPalOrder;
exports.webhooksPaypalDev = require('./paypal/paypalWebhook').webhooksPaypalDev;

exports.acceptProposal = require('./proposals').acceptProposal;



exports.getDownloadUrl = require('./downloads').getDownloadUrl;
exports.getDeliveryDownloadUrlByConversation = require('./downloads').getDeliveryDownloadUrlByConversation;


exports.submitDeliveryByConversation = require('./contracts').submitDeliveryByConversation;
exports.approveDeliveryByConversation = require('./contracts').approveDeliveryByConversation;
exports.confirmCloseByConversation = require('./contracts').confirmCloseByConversation;
exports.openDisputeByConversation = require('./contracts').openDisputeByConversation;
exports.releasePayout = require('./contracts').releasePayout;

//exports.autoApproveSubmitted = require('./contracts').autoApproveSubmitted;
//exports.autoPayoutAfterClientApprove = require('./contracts').autoPayoutAfterClientApprove;
exports.rejectDeliveryByConversation = require('./contracts').rejectDeliveryByConversation;


exports.submitDisputeMessageByConversation =
  require('./disputes').submitDisputeMessageByConversation;

exports.getDisputeAttachmentUrlByConversation =
  require('./disputes').getDisputeAttachmentUrlByConversation;


exports.createHireMeContract = require('./hireme').createHireMeContract;
exports.sendHireOfferByConversation = require('./hireme').sendHireOfferByConversation;
exports.acceptHireOfferPrepareRemainingPayment = require('./hireme').acceptHireOfferPrepareRemainingPayment;
exports.cancelHireNoAgreementByConversation = require('./hireme').cancelHireNoAgreementByConversation;
exports.rejectHireOfferByConversation =
  require('./hireme').rejectHireOfferByConversation;


exports.setPayoutProfilePayPal =
    require('./payouts_setup').setPayoutProfilePayPal;

exports.createStripeAccountLink =
    require('./payouts_setup').createStripeAccountLink;

exports.sendPayout =
    require('./payouts').sendPayout;
exports.getPayoutSettings = require('./payouts').getPayoutSettings;
exports.setDefaultPayoutProvider = require('./payouts').setDefaultPayoutProvider;
exports.autoSendPayoutOnQueuedCreated = require('./payouts').autoSendPayoutOnQueuedCreated;
exports.autoRetryPayoutOnFailedUpdated = require('./payouts').autoRetryPayoutOnFailedUpdated;




// KYC
exports.createSumsubAccessToken = require('./sumsub').createSumsubAccessToken;
exports.sumsubWebhook = require('./sumsubWebhooks').sumsubWebhook;

// Admin Manual KYC Function
exports.adminReviewKyc = require('./admin_kyc').adminReviewKyc;
