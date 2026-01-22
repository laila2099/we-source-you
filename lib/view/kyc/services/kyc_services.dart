// // lib/kyc/services/kyc_service.dart
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class KycService {
//   final _firestore = FirebaseFirestore.instance;
//   final _auth = FirebaseAuth.instance;

//   static const blockedCountries = ['SY', 'IR', 'KP'];

//   Future<String> getUserCountry() async {
//     final uid = _auth.currentUser!.uid;
//     final doc = await _firestore.collection('users').doc(uid).get();
//     return (doc.data()?['country'] ?? '').toString().toUpperCase();
//   }

//   bool isBlockedCountry(String country) {
//     return blockedCountries.contains(country);
//   }

//   Future<void> createManualKycRequest(Map<String, String> filesUrls) async {
//     final uid = _auth.currentUser!.uid;

//     await _firestore.collection('manual_kyc').doc(uid).set({
//       'uid': uid,
//       'files': filesUrls,
//       'status': 'pending',
//       'createdAt': FieldValue.serverTimestamp(),
//     });

//     await updateUserKyc(status: 'pending', manual: true);
//   }

//   Future<void> updateUserKyc({
//     required String status,
//     required bool manual,
//   }) async {
//     final uid = _auth.currentUser!.uid;
//     await _firestore.collection('users').doc(uid).update({
//       'kyc': {'status': status, 'manual': manual},
//     });
//   }
// }
