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

// Map<String, dynamic> toMap() {
//   return {
//     'jobId': jobId,
//     'userId': userId,
//     'jobOwnerId': jobOwnerId,
//     'proposalText': proposalText,
//     'status': status,
//     'createdAt': createdAt,
//     // .toIso8601String(),
//     'updatedAt': updatedAt,
//     // ?.toIso8601String(),
//   };
// }

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
// import 'package:cloud_firestore/cloud_firestore.dart';

// class ProposalModel {
//   final String id;
//   final String jobId;
//   final String userId;
//   final String? jobOwnerId;
//   final String proposalText;
//   final String status;
//   final DateTime createdAt;
//   final DateTime updatedAt;

//   ProposalModel({
//     required this.id,
//     required this.jobId,
//     required this.userId,
//     this.jobOwnerId,
//     required this.proposalText,
//     this.status = 'pending',
//     required this.createdAt,
//     required this.updatedAt,
//   });

//   factory ProposalModel.fromMap(Map<String, dynamic> map, String id) {
//     return ProposalModel(
//       id: id,
//       jobId: map['jobId'] ?? '',
//       userId: map['userId'] ?? '',
//       jobOwnerId: map['jobOwnerId'] ?? '',
//       proposalText: map['proposalText'] ?? '',
//       status: map['status'] ?? 'pending',
//       createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
//       updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'jobId': jobId,
//       'userId': userId,
//       'jobOwnerId': jobOwnerId,
//       'proposalText': proposalText,
//       'status': status,
//       'createdAt': Timestamp.fromDate(createdAt),
//       'updatedAt': Timestamp.fromDate(updatedAt),
//     };
//   }
// }
