// // lib/kyc/models/kyc_status_model.dart
// class KycStatusModel {
//   final String status; // none | pending | approved | rejected
//   final bool manual;

//   KycStatusModel({required this.status, required this.manual});

//   factory KycStatusModel.fromJson(Map<String, dynamic>? json) {
//     if (json == null) {
//       return KycStatusModel(status: 'none', manual: false);
//     }

//     return KycStatusModel(
//       status: json['status'] ?? 'none',
//       manual: json['manual'] ?? false,
//     );
//   }

//   Map<String, dynamic> toJson() => {'status': status, 'manual': manual};
// }
