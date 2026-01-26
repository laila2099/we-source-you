import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:we_source_you/routes/app_routes.dart';

class SignUpController extends GetxController {
  var accountType = 'individual'.obs;
  var email = ''.obs;
  var phone = ''.obs;
  var country = ''.obs;
  var password = ''.obs;
  var agreedToTerms = false.obs;

  var companyName = ''.obs;
  var website = ''.obs;
  var socialLinks = <String, String>{}.obs;

  var fullName = ''.obs;
  var mediaWorkTypes = <String>[].obs;
  var individualJob = ''.obs;
  var analystSpecialty = ''.obs;

  var isLoading = false.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void setAccountType(String? value) {
    if (value != null) accountType.value = value;
  }

  void goSignIn() => Get.toNamed(AppRoutes.signin);
  void goBack() => Get.back();
  void gosignIn() => Get.toNamed(AppRoutes.signin);

  Future<void> createAccount() async {
    if (!agreedToTerms.value) {
      _showError('Error', 'You must agree to the Terms & Privacy.');
      return;
    }

    try {
      isLoading.value = true;
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: email.value.trim(),
            password: password.value.trim(),
          );
      final user = userCredential.user;
      if (user == null) throw Exception('User creation failed');

      // بيانات المستخدم
      Map<String, dynamic> userData = {
        'uid': user.uid,
        'email': email.value.trim(),
        'phone': phone.value.trim(),
        'country': country.value.trim(),
        'type': accountType.value,
        'createdAt': FieldValue.serverTimestamp(),
      };

      if (accountType.value == 'company') {
        userData.addAll({
          'companyName': companyName.value.trim(),
          'website': website.value.trim(),
        });
      } else {
        userData.addAll({
          'fullName': fullName.value.trim(),
          'mediaWorkTypes': mediaWorkTypes.toList(),
          'analystSpecialty': analystSpecialty.value.trim(),
          'socialLinks': Map<String, dynamic>.from(socialLinks),
        });
      }

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userData, SetOptions(merge: true));

      // إضافة مباشرة إلى فريق Team
      Map<String, dynamic> teamData = {
        'name': accountType.value == 'company'
            ? companyName.value.trim()
            : fullName.value.trim(),
        'title': mediaWorkTypes.isNotEmpty ? mediaWorkTypes.first : '',

        'country': country.value.trim(), // ✅ جديد
        'location': ' ${country.value.trim()}',
        'rating': 0,
        'reviews': 0,
        'specialties': mediaWorkTypes.toList(),

        'projects': '0',
        'clients': '0',
        'years': '0',
        'hourlyRate': '0.00/hr',
        'dailyRate': '0.00/day',
        'projectRate': '0.00',
        'type': accountType.value,
        'createdAt': FieldValue.serverTimestamp(), // مهم للـ ordering
      };

      await _firestore.collection('team').doc(user.uid).set(teamData);

      await user.sendEmailVerification();
      await _auth.signOut();

      Get.snackbar(
        'Verify email',
        'Check your inbox for the verification link.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );

      Get.offNamed(AppRoutes.signin);
    } catch (e) {
      _showError('Sign up failed', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void _showError(String title, String msg) {
    Get.snackbar(
      title,
      msg,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}
