import 'package:cloud_firestore/cloud_firestore.dart';

class KycData {
  String status; // 'none', 'pending', 'manual_review', 'approved', 'rejected'
  bool isManual;
  Timestamp? verifiedAt;

  KycData({this.status = 'none', this.isManual = false, this.verifiedAt});

  factory KycData.fromMap(Map<String, dynamic> map) {
    return KycData(
      status: map['status'] ?? 'none',
      isManual: map['manual'] ?? false,
      verifiedAt: map['verifiedAt'],
    );
  }
}

class UserModel {
  String uid;
  String fullName;
  String email;
  String country;
  String role; // 'user', 'admin'
  KycData kyc;

  UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.country,
    required this.role,
    required this.kyc,
  });

  factory UserModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      fullName: data['fullName'] ?? '',
      email: data['email'] ?? '',
      country: data['country'] ?? '',
      role: data['role'] ?? 'user',
      kyc: data['kyc'] != null ? KycData.fromMap(data['kyc']) : KycData(),
    );
  }
}
