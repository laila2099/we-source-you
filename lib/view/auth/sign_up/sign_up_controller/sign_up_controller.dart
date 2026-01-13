// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:we_source_you/routes/app_routes.dart';

// class SignUpController extends GetxController {
//   // Account Type
//   var accountType = 'individual'.obs;
//   // individual | company

//   // shared fields
//   var email = ''.obs;
//   var phone = ''.obs;
//   var country = ''.obs;
//   var city = ''.obs;
//   var password = ''.obs;
//   var agreedToTerms = false.obs;

//   // company fields
//   var companyName = ''.obs;
//   var website = ''.obs;

//   // individual fields
//   var fullName = ''.obs;
//   var mediaWorkType = ''.obs;
//   var socialLinks = ''.obs;
//   // individual job selection
//   var individualJob = ''.obs;

//   // analyst specialization
//   var analystSpecialty = ''.obs;

//   var isLoading = false.obs;

//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   void setAccountType(String? value) {
//     if (value != null) {
//       accountType.value = value;
//     }
//   }

// void gosignIn() => Get.toNamed(AppRoutes.signin);

//   Future<void> createAccount() async {
//     if (!agreedToTerms.value) {
//       _showError("Error", "You must agree to the Terms & Privacy.");
//       return;
//     }

//     try {
//       isLoading.value = true;

//       UserCredential userCredential = await _auth
//           .createUserWithEmailAndPassword(
//             email: email.value.trim(),
//             password: password.value.trim(),
//           );

//       final user = userCredential.user;
//       if (user == null) throw Exception("User creation failed");

//       Map<String, dynamic> userData = {
//         "uid": user.uid,
//         "email": email.value.trim(),
//         "phone": phone.value.trim(),
//         "country": country.value.trim(),
//         "city": city.value.trim(),
//         "type": accountType.value,
//         "createdAt": FieldValue.serverTimestamp(),
//       };

//       if (accountType.value == 'company') {
//         userData.addAll({
//           "companyName": companyName.value.trim(),
//           "website": website.value.trim(),
//         });
//       } else {
//         userData.addAll({
//           "fullName": fullName.value.trim(),
//           "mediaWorkType": individualJob.value.trim(),
//           "analystSpecialty": analystSpecialty.value.trim(),
//           "socialLinks": socialLinks.value.trim(),
//           "type": accountType.value,
//         });
//       }

//       await _firestore.collection('users').doc(user.uid).set(userData);

//       await user.sendEmailVerification();
//       await _auth.signOut();

//       Get.snackbar(
//         "Verify email",
//         "Check your inbox for the verification link.",
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.orange,
//         colorText: Colors.white,
//       );

//       Get.offNamed(AppRoutes.signin);
//     } catch (e) {
//       _showError("Sign up failed", e.toString());
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   void _showVerificationSnackbar(User user) {
//     Get.snackbar(
//       "Verify Email",
//       "A verification email has been sent. Check SPAM folder if not received.",
//       snackPosition: SnackPosition.BOTTOM,
//       backgroundColor: Colors.orange,
//       colorText: Colors.white,
//       mainButton: TextButton(
//         onPressed: () async {
//           try {
//             await user.sendEmailVerification();
//             Get.snackbar(
//               "Email Sent",
//               "Verification email has been resent.",
//               snackPosition: SnackPosition.BOTTOM,
//               backgroundColor: Colors.green,
//               colorText: Colors.white,
//             );
//           } catch (e) {
//             Get.snackbar(
//               "Error",
//               "Could not resend verification email.",
//               snackPosition: SnackPosition.BOTTOM,
//               backgroundColor: Colors.red,
//               colorText: Colors.white,
//             );
//           }
//         },
//         child: const Text(
//           "Resend",
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//       ),
//       duration: const Duration(seconds: 10),
//     );
//   }

//   void _showError(String title, String msg) {
//     Get.snackbar(
//       title,
//       msg,
//       snackPosition: SnackPosition.BOTTOM,
//       backgroundColor: Colors.red,
//       colorText: Colors.white,
//     );
//   }

// void goBack() => Get.back();
//   void goSignIn() => Get.toNamed(AppRoutes.signin);
// }
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
  var city = ''.obs;
  var password = ''.obs;
  var agreedToTerms = false.obs;

  var companyName = ''.obs;
  var website = ''.obs;

  var fullName = ''.obs;
  var mediaWorkType = ''.obs;
  var socialLinks = ''.obs;
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
        'city': city.value.trim(),
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
          'mediaWorkType': individualJob.value.trim(),
          'analystSpecialty': analystSpecialty.value.trim(),
          'socialLinks': socialLinks.value.trim(),
        });
      }

      await _firestore.collection('users').doc(user.uid).set(userData);

      // إضافة مباشرة إلى فريق Team
      Map<String, dynamic> teamData = {
        'name': accountType.value == 'company'
            ? companyName.value.trim()
            : fullName.value.trim(),
        'title': accountType.value == 'company'
            ? 'Company'
            : individualJob.value.trim(),
        'country': country.value.trim(), // ✅ جديد
        'city': city.value.trim(),
        'location': '${city.value.trim()}, ${country.value.trim()}',
        'rating': 0,
        'reviews': 0,
        'specialties': accountType.value == 'company'
            ? ['Company']
            : [individualJob.value.trim()],
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
