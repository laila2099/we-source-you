import 'package:cloud_firestore/cloud_firestore.dart';

class ProposalModel {
  final String id;
  String jobId;
  String userId;
  String? jobOwnerId;
  String proposalText;
  String status; // 'pending', 'approved', 'rejected'
  DateTime createdAt;
  DateTime? updatedAt;
  String? amount;

  ProposalModel({
    required this.id,
    required this.jobId,
    required this.userId,
    this.jobOwnerId,
    required this.proposalText,
    this.status = 'pending',
    required this.createdAt,
    this.updatedAt,
    this.amount,
  });

  Map<String, dynamic> toMap() {
    return {
      'jobId': jobId,
      'userId': userId,
      'jobOwnerId': jobOwnerId,
      'proposalText': proposalText,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  factory ProposalModel.fromMap(Map<String, dynamic> data, String id) {
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.parse(value);
      return DateTime.now();
    }

    return ProposalModel(
      id: id,
      jobId: data['jobId'] ?? '',
      userId: data['userId'] ?? '',
      jobOwnerId: data['jobOwnerId'],
      proposalText: data['proposalText'] ?? '',
      status: data['status'] ?? 'pending',
      createdAt: parseDate(data['createdAt']),
      updatedAt: parseDate(data['updatedAt']),
    );
  }
}
