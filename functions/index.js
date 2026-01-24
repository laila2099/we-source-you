const admin = require('firebase-admin');
admin.initializeApp();

// Admin Manual KYC Function
exports.onKycStatusChange = require('./admin_kyc').onKycStatusChange;
exports.setAdminClaim = require('./admin').setAdminClaim;
