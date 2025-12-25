import 'package:cloud_firestore/cloud_firestore.dart';

class ProposalModel {
  String? id;
  String jobId;
  String userId;
  String? jobOwnerId;
  String proposalText;
  String status; // 'pending', 'approved', 'rejected'
  DateTime createdAt;
  DateTime? updatedAt;

  ProposalModel({
    this.id,
    required this.jobId,
    required this.userId,
    this.jobOwnerId,
    required this.proposalText,
    this.status = 'pending',
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'jobId': jobId,
      'userId': userId,
      'jobOwnerId': jobOwnerId,
      'proposalText': proposalText,
      'status': status,
      'createdAt': createdAt,
      // .toIso8601String(),
      'updatedAt': updatedAt,
      // ?.toIso8601String(),
    };
  }

  factory ProposalModel.fromMap(Map<String, dynamic> data, String id) {
    return ProposalModel(
      id: id,
      jobId: data['jobId'] ?? '',
      userId: data['userId'] ?? '',
      jobOwnerId: data['jobOwnerId'],
      proposalText: data['proposalText'] ?? '',
      status: data['status'] ?? 'pending',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  // factory ProposalModel.fromMap(Map<String, dynamic> data, String id) {
  //   return ProposalModel(
  //     id: id,
  //     jobId: data['jobId'] ?? '',
  //     userId: data['userId'] ?? '',
  //     jobOwnerId: data['jobOwnerId'],
  //     proposalText: data['proposalText'] ?? '',
  //     status: data['status'] ?? 'pending',
  //     createdAt: data['createdAt'] != null
  //         ? DateTime.parse(data['createdAt'])
  //         : DateTime.now(),
  //     updatedAt: data['updatedAt'] != null
  //         ? DateTime.parse(data['updatedAt'])
  //         : null,
  //   );
  // }
}
