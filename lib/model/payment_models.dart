// import 'package:cloud_firestore/cloud_firestore.dart';

// enum PaymentMethod { stripe, paypal }

// enum PaymentStatus {
//   pending,
//   processing,
//   completed,
//   failed,
//   refunded,
//   cancelled
// }

// enum ContractStatus {
//   pending,
//   active,
//   completed,
//   cancelled
// }

// enum HireType { hourly, daily, project }

// class TransactionModel {
//   String? id;
//   String mediaId;
//   String buyerId;
//   double amount;
//   double platformFee;
//   double totalAmount;
//   PaymentMethod paymentMethod;
//   String? transactionId;
//   PaymentStatus paymentStatus;
//   DateTime createdAt;
//   DateTime? completedAt;

//   TransactionModel({
//     this.id,
//     required this.mediaId,
//     required this.buyerId,
//     required this.amount,
//     required this.platformFee,
//     required this.totalAmount,
//     required this.paymentMethod,
//     this.transactionId,
//     this.paymentStatus = PaymentStatus.pending,
//     required this.createdAt,
//     this.completedAt,
//   });

//   Map<String, dynamic> toMap() {
//     return {
//       'mediaId': mediaId,
//       'buyerId': buyerId,
//       'amount': amount,
//       'platformFee': platformFee,
//       'totalAmount': totalAmount,
//       'paymentMethod': paymentMethod.name,
//       'transactionId': transactionId,
//       'paymentStatus': paymentStatus.name,
//       'createdAt': Timestamp.fromDate(createdAt),
//       'completedAt': completedAt != null
//           ? Timestamp.fromDate(completedAt!)
//           : null,
//     };
//   }

//   factory TransactionModel.fromMap(Map<String, dynamic> data, String id) {
//     return TransactionModel(
//       id: id,
//       mediaId: data['mediaId'] ?? '',
//       buyerId: data['buyerId'] ?? '',
//       amount: (data['amount'] ?? 0.0).toDouble(),
//       platformFee: (data['platformFee'] ?? 0.0).toDouble(),
//       totalAmount: (data['totalAmount'] ?? 0.0).toDouble(),
//       paymentMethod: PaymentMethod.values.firstWhere(
//         (e) => e.name == data['paymentMethod'],
//         orElse: () => PaymentMethod.stripe,
//       ),
//       transactionId: data['transactionId'],
//       paymentStatus: PaymentStatus.values.firstWhere(
//         (e) => e.name == data['paymentStatus'],
//         orElse: () => PaymentStatus.pending,
//       ),
//       createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
//       completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
//     );
//   }
// }

// class HiringRecordModel {
//   String? id;
//   String teamId;
//   String clientId;
//   HireType hireType;
//   double rate;
//   double platformFee;
//   double totalAmount;
//   PaymentMethod paymentMethod;
//   String? transactionId;
//   ContractStatus contractStatus;
//   DateTime createdAt;
//   DateTime? startedAt;
//   DateTime? completedAt;

//   HiringRecordModel({
//     this.id,
//     required this.teamId,
//     required this.clientId,
//     required this.hireType,
//     required this.rate,
//     required this.platformFee,
//     required this.totalAmount,
//     required this.paymentMethod,
//     this.transactionId,
//     this.contractStatus = ContractStatus.pending,
//     required this.createdAt,
//     this.startedAt,
//     this.completedAt,
//   });

//   Map<String, dynamic> toMap() {
//     return {
//       'teamId': teamId,
//       'clientId': clientId,
//       'hireType': hireType.name,
//       'rate': rate,
//       'platformFee': platformFee,
//       'totalAmount': totalAmount,
//       'paymentMethod': paymentMethod.name,
//       'transactionId': transactionId,
//       'contractStatus': contractStatus.name,
//       'createdAt': Timestamp.fromDate(createdAt),
//       'startedAt': startedAt != null ? Timestamp.fromDate(startedAt!) : null,
//       'completedAt':
//           completedAt != null ? Timestamp.fromDate(completedAt!) : null,
//     };
//   }

//   factory HiringRecordModel.fromMap(Map<String, dynamic> data, String id) {
//     return HiringRecordModel(
//       id: id,
//       teamId: data['teamId'] ?? '',
//       clientId: data['clientId'] ?? '',
//       hireType: HireType.values.firstWhere(
//         (e) => e.name == data['hireType'],
//         orElse: () => HireType.hourly,
//       ),
//       rate: (data['rate'] ?? 0.0).toDouble(),
//       platformFee: (data['platformFee'] ?? 0.0).toDouble(),
//       totalAmount: (data['totalAmount'] ?? 0.0).toDouble(),
//       paymentMethod: PaymentMethod.values.firstWhere(
//         (e) => e.name == data['paymentMethod'],
//         orElse: () => PaymentMethod.stripe,
//       ),
//       transactionId: data['transactionId'],
//       contractStatus: ContractStatus.values.firstWhere(
//         (e) => e.name == data['contractStatus'],
//         orElse: () => ContractStatus.pending,
//       ),
//       createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
//       startedAt: (data['startedAt'] as Timestamp?)?.toDate(),
//       completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
//     );
//   }
// }

// class ProposalPaymentModel {
//   String? id;
//   String proposalId;
//   String jobId;
//   String teamId;
//   double amount;
//   double platformFee;
//   double totalAmount;
//   PaymentMethod paymentMethod;
//   String? transactionId;
//   PaymentStatus paymentStatus;
//   DateTime createdAt;
//   DateTime? paidAt;

//   ProposalPaymentModel({
//     this.id,
//     required this.proposalId,
//     required this.jobId,
//     required this.teamId,
//     required this.amount,
//     required this.platformFee,
//     required this.totalAmount,
//     required this.paymentMethod,
//     this.transactionId,
//     this.paymentStatus = PaymentStatus.pending,
//     required this.createdAt,
//     this.paidAt,
//   });

//   Map<String, dynamic> toMap() {
//     return {
//       'proposalId': proposalId,
//       'jobId': jobId,
//       'teamId': teamId,
//       'amount': amount,
//       'platformFee': platformFee,
//       'totalAmount': totalAmount,
//       'paymentMethod': paymentMethod.name,
//       'transactionId': transactionId,
//       'paymentStatus': paymentStatus.name,
//       'createdAt': Timestamp.fromDate(createdAt),
//       'paidAt': paidAt != null ? Timestamp.fromDate(paidAt!) : null,
//     };
//   }

//   factory ProposalPaymentModel.fromMap(
//       Map<String, dynamic> data, String id) {
//     return ProposalPaymentModel(
//       id: id,
//       proposalId: data['proposalId'] ?? '',
//       jobId: data['jobId'] ?? '',
//       teamId: data['teamId'] ?? '',
//       amount: (data['amount'] ?? 0.0).toDouble(),
//       platformFee: (data['platformFee'] ?? 0.0).toDouble(),
//       totalAmount: (data['totalAmount'] ?? 0.0).toDouble(),
//       paymentMethod: PaymentMethod.values.firstWhere(
//         (e) => e.name == data['paymentMethod'],
//         orElse: () => PaymentMethod.stripe,
//       ),
//       transactionId: data['transactionId'],
//       paymentStatus: PaymentStatus.values.firstWhere(
//         (e) => e.name == data['paymentStatus'],
//         orElse: () => PaymentStatus.pending,
//       ),
//       createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
//       paidAt: (data['paidAt'] as Timestamp?)?.toDate(),
//     );
//   }
// }

enum PaymentMethod { stripe, paypal }

enum MarketItemType { media, hiring, proposal }

class PaymentResult {
  final bool success;
  final String? message;
  final String? transactionId; // paymentIntentId or orderId

  PaymentResult({required this.success, this.message, this.transactionId});
}

class PaypalOrderResponse {
  final String orderId;
  final String? approvalUrl;

  PaypalOrderResponse({required this.orderId, this.approvalUrl});

  factory PaypalOrderResponse.fromMap(Map<String, dynamic> map) {
    return PaypalOrderResponse(
      orderId: map['orderId'] ?? '',
      approvalUrl: map['approvalUrl'],
    );
  }
}

class StripeEscrowResponse {
  final String clientSecret;
  final String paymentIntentId;

  StripeEscrowResponse({
    required this.clientSecret,
    required this.paymentIntentId,
  });

  factory StripeEscrowResponse.fromMap(Map<String, dynamic> map) {
    return StripeEscrowResponse(
      clientSecret: map['clientSecret'] ?? '',
      paymentIntentId: map['paymentIntentId'] ?? '',
    );
  }
}
