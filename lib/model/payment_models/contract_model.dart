import '../../core/payments/contract_status.dart';

class ContractModel {
  final String id;
  final String clientId;
  final String freelancerId;

  final double grossAmount;
  final double platformFee;
  final double freelancerNet;
  final String currency;

  final ContractStatus status;

  final DateTime? fundedAt;
  final DateTime? submittedAt;
  final DateTime? clientApprovedAt;
  final DateTime? freelancerApprovedAt;
  final DateTime? paidOutAt;

  final DateTime? disputeDeadline;
  final DateTime? downloadDeadline;

  final String conversationId;

  ContractModel({
    required this.id,
    required this.clientId,
    required this.freelancerId,
    required this.grossAmount,
    required this.platformFee,
    required this.freelancerNet,
    required this.currency,
    required this.status,
    required this.conversationId,
    this.fundedAt,
    this.submittedAt,
    this.clientApprovedAt,
    this.freelancerApprovedAt,
    this.paidOutAt,
    this.disputeDeadline,
    this.downloadDeadline,
  });

  factory ContractModel.fromJson(String id, Map<String, dynamic> json) {
    return ContractModel(
      id: id,
      clientId: json['clientId'],
      freelancerId: json['freelancerId'],
      grossAmount: (json['grossAmount'] as num).toDouble(),
      platformFee: (json['platformFee'] as num).toDouble(),
      freelancerNet: (json['freelancerNet'] as num).toDouble(),
      currency: json['currency'],
      status: ContractStatus.values.byName(json['status']),
      conversationId: json['conversationId'],
      fundedAt: json['fundedAt']?.toDate(),
      submittedAt: json['submittedAt']?.toDate(),
      clientApprovedAt: json['clientApprovedAt']?.toDate(),
      freelancerApprovedAt: json['freelancerApprovedAt']?.toDate(),
      paidOutAt: json['paidOutAt']?.toDate(),
      disputeDeadline: json['disputeDeadline']?.toDate(),
      downloadDeadline: json['downloadDeadline']?.toDate(),
    );
  }
}
