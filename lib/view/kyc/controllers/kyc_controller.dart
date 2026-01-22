// import 'package:cloud_functions/cloud_functions.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:get/get.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:flutter/foundation.dart' show kIsWeb;

// class KycController extends GetxController {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _db = FirebaseFirestore.instance;

//   var isLoading = false.obs;
//   var userStatus = 'none'.obs;

//   @override
//   void onInit() {
//     super.onInit();
//     _listenToUserChanges();
//   }

//   void _listenToUserChanges() {
//     String? uid = _auth.currentUser?.uid;
//     if (uid == null) return;

//     _db.collection('users').doc(uid).snapshots().listen((snapshot) {
//       if (snapshot.exists) {
//         final data = snapshot.data();
//         userStatus.value = data?['kyc']?['status'] ?? 'none';
//       }
//     });
//   }

//   Future<void> startSumsubVerification() async {
//     try {
//       isLoading.value = true;

//       final user = _auth.currentUser;
//       if (user == null) throw Exception('User not logged in');

//       // الحصول على توكن جديد لضمان الصلاحية
//       await user.getIdToken(true);

//       final callable = FirebaseFunctions.instanceFor(
//         region: 'us-central1',
//       ).httpsCallable('createSumsubAccessToken');

//       // طلب التوكن من السيرفر
//       final result = await callable.call({'levelName': 'id-and-liveness'});

//       String token = result.data['token'];

//       if (kIsWeb) {
//         // الرابط المعتمد لفتح واجهة التوثيق مباشرة كمستخدم وليس كمدير
//         // نستخدم l/#/index لضمان فتح الـ SDK
//         final String sumsubUrl =
//             "https://api.sumsub.com/idensic/index.html?accessToken=$token";

//         final Uri url = Uri.parse(sumsubUrl);

//         // استخدام mode: LaunchMode.externalApplication يحل مشكلة الـ CORS في الويب
//         if (await canLaunchUrl(url)) {
//           await launchUrl(url, mode: LaunchMode.externalApplication);
//         } else {
//           throw 'Could not launch $sumsubUrl';
//         }
//       }
//     } catch (e) {
//       Get.snackbar(
//         "KYC Error",
//         e.toString(),
//         snackPosition: SnackPosition.BOTTOM,
//       );
//       print("KYC Error: $e");
//     } finally {
//       isLoading.value = false;
//     }
//   }
// }
import 'dart:js' as js;
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';

class KycController extends GetxController {
  final _auth = FirebaseAuth.instance;
  var isLoading = false.obs;

  Future<void> startKyc() async {
    try {
      isLoading.value = true;

      final user = _auth.currentUser;
      if (user == null) throw 'Not logged in';

      await user.getIdToken(true);

      final callable = FirebaseFunctions.instanceFor(
        region: 'us-central1',
      ).httpsCallable('createSumsubAccessToken');

      final res = await callable.call();
      final token = res.data['token'];

      if (kIsWeb) {
        js.context.callMethod('launchSumsub', [token]);
      }
    } catch (e) {
      Get.snackbar('KYC Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
