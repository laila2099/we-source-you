import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  String? id;
  String userId;
  String type;
  String title;
  String message;
  String? jobId;
  String? proposalId;
  bool isRead;
  DateTime createdAt;

  NotificationModel({
    this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.jobId,
    this.proposalId,
    this.isRead = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'type': type,
      'title': title,
      'message': message,
      'jobId': jobId,
      'proposalId': proposalId,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> data, String id) {
    return NotificationModel(
      id: id,
      userId: data['userId'] ?? '',
      type: data['type'] ?? '',
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      jobId: data['jobId'],
      proposalId: data['proposalId'],
      isRead: data['isRead'] ?? false,
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'])
          : DateTime.now(),
    );
  }
}
