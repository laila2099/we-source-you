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
  final uid = FirebaseAuth.instance.currentUser!.uid;

  Future<void> uploadKYC(
    File idFile,
    File selfieFile, [
    File? otherFile,
  ]) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final uid = FirebaseAuth.instance.currentUser!.uid;

      // اقرأ بيانات المستخدم
      final userDoc = await firestore.collection('users').doc(uid).get();
      final userData = userDoc.data()!;

      final String displayName = userData['type'] == 'company'
          ? userData['companyName']
          : userData['fullName'];

      final idRef = storage.ref().child('kyc/$uid/id.jpg');
      final selfieRef = storage.ref().child('kyc/$uid/selfie.jpg');
      final otherRef = storage.ref().child('kyc/$uid/other.jpg');

      await Future.wait([
        idRef.putBlob(idFile),
        selfieRef.putBlob(selfieFile),
        if (otherFile != null) otherRef.putBlob(otherFile),
      ]);

      final idUrl = await idRef.getDownloadURL();
      final selfieUrl = await selfieRef.getDownloadURL();
      final otherUrl = otherFile != null ? await otherRef.getDownloadURL() : '';

      // 🔥 هون المهم
      await firestore.collection('kycUploads').doc(uid).set({
        'uid': uid,
        'type': userData['type'],
        'displayName': displayName,
        'idFileUrl': idUrl,
        'selfieUrl': selfieUrl,
        'otherDocUrl': otherUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await firestore.collection('users').doc(uid).update({
        'kycStatus': 'pending',
      });

      isLoading.value = false;
    } catch (e) {
      errorMessage.value = 'KYC Upload Failed: $e';
      isLoading.value = false;
    }
  }
}
