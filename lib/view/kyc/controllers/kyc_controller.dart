// import 'dart:html';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:get/get.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class KYCController extends GetxController {
//   var isLoading = false.obs;
//   var errorMessage = ''.obs;

//   final FirebaseFirestore firestore = FirebaseFirestore.instance;
//   final FirebaseStorage storage = FirebaseStorage.instance;
//   final uid = FirebaseAuth.instance.currentUser!.uid;

//   Future<void> uploadKYC(
//     File idFile,
//     File selfieFile, [
//     File? otherFile,
//   ]) async {
//     try {
//       isLoading.value = true;
//       errorMessage.value = '';

//       final uid = FirebaseAuth.instance.currentUser!.uid;

//       // اقرأ بيانات المستخدم
//       final userDoc = await firestore.collection('users').doc(uid).get();
//       final userData = userDoc.data()!;

//       final String displayName = userData['type'] == 'company'
//           ? userData['companyName']
//           : userData['fullName'];

//       final idRef = storage.ref().child('kyc/$uid/id.jpg');
//       final selfieRef = storage.ref().child('kyc/$uid/selfie.jpg');
//       final otherRef = storage.ref().child('kyc/$uid/other.jpg');

//       await Future.wait([
//         idRef.putBlob(idFile),
//         selfieRef.putBlob(selfieFile),
//         if (otherFile != null) otherRef.putBlob(otherFile),
//       ]);

//       final idUrl = await idRef.getDownloadURL();
//       final selfieUrl = await selfieRef.getDownloadURL();
//       final otherUrl = otherFile != null ? await otherRef.getDownloadURL() : '';

//       // 🔥 هون المهم
//       await firestore.collection('kycUploads').doc(uid).set({
//         'uid': uid,
//         'type': userData['type'],
//         'displayName': displayName,
//         'idFileUrl': idUrl,
//         'selfieUrl': selfieUrl,
//         'otherDocUrl': otherUrl,
//         'createdAt': FieldValue.serverTimestamp(),
//       });

//       await firestore.collection('users').doc(uid).update({
//         'kycStatus': 'pending',
//       });

//       isLoading.value = false;
//     } catch (e) {
//       errorMessage.value = 'KYC Upload Failed: $e';
//       isLoading.value = false;
//     }
//   }
// }
// kyc_controller.dart
// kyc_controller.dart
// import 'dart:html';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:get/get.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class KYCController extends GetxController {
//   var isLoading = false.obs;
//   var errorMessage = ''.obs;

//   // ✅ For previews
// var idPreview = ''.obs;
// var selfiePreview = ''.obs;
// var otherPreview = ''.obs;

//   final FirebaseFirestore firestore = FirebaseFirestore.instance;
//   final FirebaseStorage storage = FirebaseStorage.instance;
//   final uid = FirebaseAuth.instance.currentUser!.uid;

//   Future<void> uploadKYC(
//     File idFile,
//     File selfieFile, [
//     File? otherFile,
//   ]) async {
//     try {
//       isLoading.value = true;
//       errorMessage.value = '';

//       final userDoc = await firestore.collection('users').doc(uid).get();
//       final userData = userDoc.data()!;

//       final String displayName = userData['type'] == 'company'
//           ? userData['companyName']
//           : userData['fullName'];

//       final idRef = storage.ref().child('kyc/$uid/id.jpg');
//       final selfieRef = storage.ref().child('kyc/$uid/selfie.jpg');
//       final otherRef = storage.ref().child('kyc/$uid/other.jpg');

//       await Future.wait([
//         idRef.putBlob(idFile),
//         selfieRef.putBlob(selfieFile),
//         if (otherFile != null) otherRef.putBlob(otherFile),
//       ]);

//       final idUrl = await idRef.getDownloadURL();
//       final selfieUrl = await selfieRef.getDownloadURL();
//       final otherUrl = otherFile != null ? await otherRef.getDownloadURL() : '';

//       await firestore.collection('kycUploads').doc(uid).set({
//         'uid': uid,
//         'type': userData['type'],
//         'displayName': displayName,
//         'idFileUrl': idUrl,
//         'selfieUrl': selfieUrl,
//         'otherDocUrl': otherUrl,
//         'createdAt': FieldValue.serverTimestamp(),
//       });

//       await firestore.collection('users').doc(uid).update({
//         'kycStatus': 'pending',
//       });

//       isLoading.value = false;
//     } catch (e) {
//       errorMessage.value = 'KYC Upload Failed: $e';
//       isLoading.value = false;
//     }
//   }
// }
import 'dart:html';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class KYCController extends GetxController {
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  var idPreview = ''.obs;
  var selfiePreview = ''.obs;
  var otherPreview = ''.obs;

  /// =============================
  /// Upload KYC
  /// =============================
  Future<void> uploadKYC(
    File idFile,
    File selfieFile, [
    File? otherFile,
  ]) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      errorMessage.value = 'User not logged in';
      return;
    }

    final uid = user.uid;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final userRef = firestore.collection('users').doc(uid);
      final userDoc = await userRef.get();
      if (!userDoc.exists) throw Exception('User data not found');

      final userData = userDoc.data()!;

      // 🔹 Storage refs with timestamp to avoid overwriting
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final idRef = storage.ref('kyc/$uid/id_$timestamp.jpg');
      final selfieRef = storage.ref('kyc/$uid/selfie_$timestamp.jpg');
      final otherRef = otherFile != null
          ? storage.ref('kyc/$uid/other_$timestamp.jpg')
          : null;

      // 🔹 Upload all files concurrently
      await Future.wait([
        idRef.putBlob(idFile),
        selfieRef.putBlob(selfieFile),
        if (otherFile != null) otherRef!.putBlob(otherFile),
      ]);

      // 🔹 Get download URLs
      final idUrl = await idRef.getDownloadURL();
      final selfieUrl = await selfieRef.getDownloadURL();
      final otherUrl = otherFile != null
          ? await otherRef!.getDownloadURL()
          : '';

      // 🔹 Update Firestore user doc
      await userRef.update({
        'kycStatus': 'pending',
        'kyc': {
          'idFileUrl': idUrl,
          'selfieUrl': selfieUrl,
          'otherDocUrl': otherUrl,
          'submittedAt': FieldValue.serverTimestamp(),
        },
      });

      // 🔹 Send notification to admin
      await firestore.collection('notifications').add({
        'userId': uid,
        'type': 'kyc_submitted',
        'displayName': userData['type'] == 'company'
            ? userData['companyName'] ?? 'Unknown Company'
            : userData['fullName'] ?? 'Unknown User',
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
      });
    } catch (e) {
      errorMessage.value = 'KYC Upload Failed: $e';
    } finally {
      isLoading.value = false;
    }
  }
}
