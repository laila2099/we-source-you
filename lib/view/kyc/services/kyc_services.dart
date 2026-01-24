// import 'dart:html';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class KYCService {
//   final FirebaseStorage storage = FirebaseStorage.instance;
//   final FirebaseFirestore firestore = FirebaseFirestore.instance;

//   Future<void> uploadKYC({
//     required String uid,
//     required File idFile,
//     required File selfieFile,
//     File? otherFile,
//   }) async {
//     try {
//       // رفع الملفات على Firebase Storage
//       final idRef = storage.ref('kyc/$uid/id.jpg');
//       final selfieRef = storage.ref('kyc/$uid/selfie.jpg');
//       final otherRef = otherFile != null
//           ? storage.ref('kyc/$uid/otherDoc.jpg')
//           : null;

//       await idRef.putBlob(idFile);
//       await selfieRef.putBlob(selfieFile);
//       if (otherFile != null) await otherRef!.putBlob(otherFile);

//       // الحصول على روابط التحميل
//       final idUrl = await idRef.getDownloadURL();
//       final selfieUrl = await selfieRef.getDownloadURL();
//       final otherUrl = otherFile != null
//           ? await otherRef!.getDownloadURL()
//           : '';

//       // حفظ الروابط في Firestore
//       await firestore.collection('kycUploads').doc(uid).set({
//         'idFileUrl': idUrl,
//         'selfieUrl': selfieUrl,
//         'otherDocUrl': otherUrl,
//       });

//       // تحديث حالة KYC للمستخدم
//       await firestore.collection('users').doc(uid).update({
//         'kycStatus': 'pending',
//       });
//     } catch (e) {
//       throw Exception('KYC Upload Failed: $e');
//     }
//   }
// }
