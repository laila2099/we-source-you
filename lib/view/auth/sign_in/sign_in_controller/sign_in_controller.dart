import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_storage/get_storage.dart';
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

      print("Signed in successfully");

      User? user = cred.user;
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
      await userDoc.set({
        'uid': user.uid,
        'email': user.email,
        'emailVerified': true,
        'lastLogin': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (Get.isRegistered<AuthController>()) {
        await Get.find<AuthController>().refreshAuthState();
      }

      Get.back(result: true);
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } catch (e) {
      _showError("Error", "An unexpected error occurred.");
      debugPrint("SignInController error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void _handleAuthError(FirebaseAuthException e) {
    String message = "Sign in failed.";
    if (e.code == 'user-not-found')
      message = "No account found for this email.";
    if (e.code == 'wrong-password') message = "Incorrect password.";
    if (e.code == 'invalid-email') message = "Invalid email address.";
    if (e.code == 'user-disabled') message = "This account is disabled.";
    if (e.code == 'too-many-requests')
      message = "Too many failed attempts. Try later.";
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
}
