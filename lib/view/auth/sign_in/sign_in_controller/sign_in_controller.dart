import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:html' as html;
import 'package:we_source_you/routes/app_routes.dart';
import 'package:we_source_you/view/auth/auth_controller/auth_controller.dart';

class SignInController extends GetxController {
  var email = ''.obs;
  var password = ''.obs;
  var rememberMe = false.obs;
  var isLoading = false.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final box = GetStorage();

  void toggleRememberMe(bool value) => rememberMe.value = value;

  /// 🔹 احصل على FCM Token واحفظه في Firestore
  Future<void> _saveFcmToken(String uid) async {
    try {
      // اطلب إذن الإشعارات
      final permission = await html.Notification.requestPermission();
      if (permission != 'granted') {
        print("User denied notifications");
        return;
      }

      // احصل على FCM token للويب
      final token = await FirebaseMessaging.instance.getToken(
        vapidKey:
            "BAkcxszqZjCdh_kEzt1b1HIy1_lvDzZNcHATZ6408maUvgr8GxTdHrBqcIvTf8Y0PfUQGTYL14RYSzaUnIoLmPQ",
      );

      print("FCM Token: $token"); // ✅ اطبع للتأكد

      if (token != null && token.isNotEmpty) {
        await _firestore.collection('users').doc(uid).update({
          'fcmToken': token,
        });
        //SetOptions(merge: true)

        print("FCM token saved for user $uid");
      } else {
        print("FCM token is null or empty");
      }
    } catch (e) {
      print("Failed to save FCM token: $e");
    }
  }

  Future<void> signIn() async {
    final emailTrimmed = email.value.trim();
    final passwordTrimmed = password.value.trim();

    if (emailTrimmed.isEmpty || passwordTrimmed.isEmpty) {
      _showError("Error", "Email and password are required.");
      return;
    }

    if (passwordTrimmed.length < 6) {
      _showError("Error", "Password must be at least 6 characters.");
      return;
    }

    try {
      isLoading.value = true;
      await box.write('rememberMe', rememberMe.value);

      final UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: emailTrimmed,
        password: passwordTrimmed,
      );

      final User? user = cred.user;
      if (user == null) throw Exception("Sign in failed");

      if (!user.emailVerified) {
        await _auth.signOut();
        _showError(
          "Email not verified",
          "Please verify your email first.",
          isWarning: true,
        );
        return;
      }

      final userDoc = _firestore.collection('users').doc(user.uid);

      try {
        final docSnapshot = await userDoc.get();

        if (docSnapshot.exists) {
          await userDoc.update({
            'lastLogin': FieldValue.serverTimestamp(),
            'emailVerified': true,
          });
        } else {
          await userDoc.set({
            'uid': user.uid,
            'email': user.email,
            'emailVerified': true,
            'lastLogin': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
      } catch (firestoreError) {
        debugPrint("Firestore error: $firestoreError");
        _showError("Firestore Error", firestoreError.toString());
        return;
      }

      // 🔹 احفظ FCM Token بعد التأكد من إنشاء المستند
      await _saveFcmToken(user.uid);

      if (Get.isRegistered<AuthController>()) {
        await Get.find<AuthController>().refreshAuthState();
      }

      Get.back(result: true);
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } catch (e, st) {
      debugPrint("Unexpected error: $e\n$st");
      _showError("Error", "An unexpected error occurred: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void _handleAuthError(FirebaseAuthException e) {
    String message = "Sign in failed.";
    switch (e.code) {
      case 'user-not-found':
        message = "No account found for this email.";
        break;
      case 'wrong-password':
        message = "Incorrect password.";
        break;
      case 'invalid-email':
        message = "Invalid email address.";
        break;
      case 'user-disabled':
        message = "This account is disabled.";
        break;
      case 'too-many-requests':
        message = "Too many failed attempts. Try later.";
        break;
    }
    _showError("Sign In Failed", message);
  }

  void _showError(String title, String msg, {bool isWarning = false}) {
    Get.snackbar(
      title,
      msg,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isWarning ? Colors.orange : Colors.red,
      colorText: Colors.white,
    );
  }

  void goBack() => Get.back();
  void goSignUp() => Get.toNamed(AppRoutes.signup);

  Future<void> resetPassword() async {
    if (email.value.isEmpty || !GetUtils.isEmail(email.value)) {
      Get.snackbar(
        "خطأ",
        "يرجى إدخال بريد إلكتروني صحيح أولاً",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: email.value.trim(),
      );

      Get.snackbar(
        "تم الإرسال",
        "تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } catch (e) {
      Get.snackbar("خطأ", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
