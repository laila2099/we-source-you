// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:we_source_you/model/payment_models.dart';

// class PaymentRepository {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   // Save media transaction
//   Future<String> saveMediaTransaction(TransactionModel transaction) async {
//     final docRef = await _firestore
//         .collection('transactions')
//         .add(transaction.toMap());
//     return docRef.id;
//   }

//   // Save hiring record
//   Future<String> saveHiringRecord(HiringRecordModel hiring) async {
//     final docRef = await _firestore
//         .collection('hiring_records')
//         .add(hiring.toMap());
//     return docRef.id;
//   }

//   // Save proposal payment
//   Future<String> saveProposalPayment(ProposalPaymentModel payment) async {
//     final docRef = await _firestore
//         .collection('proposal_payments')
//         .add(payment.toMap());
//     return docRef.id;
//   }

//   // Update transaction status
//   Future<void> updateTransactionStatus(
//     String transactionId,
//     PaymentStatus status,
//     String? paymentIntentId,
//   ) async {
//     final updates = <String, dynamic>{
//       'paymentStatus': status.name,
//       if (paymentIntentId != null) 'transactionId': paymentIntentId,
//       if (status == PaymentStatus.completed)
//         'completedAt': FieldValue.serverTimestamp(),
//     };

//     await _firestore
//         .collection('transactions')
//         .doc(transactionId)
//         .update(updates);
//   }

//   // Update hiring record status
//   Future<void> updateHiringStatus(
//     String hiringId,
//     ContractStatus status,
//     String? transactionId,
//   ) async {
//     final updates = <String, dynamic>{
//       'contractStatus': status.name,
//       if (transactionId != null) 'transactionId': transactionId,
//       if (status == ContractStatus.active)
//         'startedAt': FieldValue.serverTimestamp(),
//       if (status == ContractStatus.completed)
//         'completedAt': FieldValue.serverTimestamp(),
//     };

//     await _firestore
//         .collection('hiring_records')
//         .doc(hiringId)
//         .update(updates);
//   }

//   // Update proposal payment status
//   Future<void> updateProposalPaymentStatus(
//     String paymentId,
//     PaymentStatus status,
//     String? transactionId,
//   ) async {
//     final updates = <String, dynamic>{
//       'paymentStatus': status.name,
//       if (transactionId != null) 'transactionId': transactionId,
//       if (status == PaymentStatus.completed)
//         'paidAt': FieldValue.serverTimestamp(),
//     };

//     await _firestore
//         .collection('proposal_payments')
//         .doc(paymentId)
//         .update(updates);
//   }

//   // Get user transactions
//   Stream<List<TransactionModel>> getUserTransactions(String userId) {
//     return _firestore
//         .collection('transactions')
//         .where('buyerId', isEqualTo: userId)
//         .orderBy('createdAt', descending: true)
//         .snapshots()
//         .map((snapshot) => snapshot.docs
//             .map((doc) => TransactionModel.fromMap(doc.data(), doc.id))
//             .toList());
//   }

//   // Get user hiring records
//   Stream<List<HiringRecordModel>> getUserHiringRecords(String userId) {
//     return _firestore
//         .collection('hiring_records')
//         .where('clientId', isEqualTo: userId)
//         .orderBy('createdAt', descending: true)
//         .snapshots()
//         .map((snapshot) => snapshot.docs
//             .map((doc) => HiringRecordModel.fromMap(doc.data(), doc.id))
//             .toList());
//   }

//   // Save payment method for reuse
//   Future<void> savePaymentMethod(String userId, String paymentMethodId, PaymentMethod method) async {
//     await _firestore.collection('users').doc(userId).update({
//       'savedPaymentMethod': {
//         'id': paymentMethodId,
//         'method': method.name,
//         'savedAt': FieldValue.serverTimestamp(),
//       },
//     });
//   }

//   // Get saved payment method
//   Future<Map<String, dynamic>?> getSavedPaymentMethod(String userId) async {
//     final userDoc = await _firestore.collection('users').doc(userId).get();
//     if (!userDoc.exists) return null;

//     final data = userDoc.data();
//     return data?['savedPaymentMethod'] as Map<String, dynamic>?;
//   }
// }
