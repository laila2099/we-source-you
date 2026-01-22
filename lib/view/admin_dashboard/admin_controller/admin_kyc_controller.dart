import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:we_source_you/model/user_model.dart';

class AdminKycController extends GetxController {
  var pendingUsers = <UserModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    bindPendingUsers();
  }

  void bindPendingUsers() {
    // Listen to users who are under manual_review
    FirebaseFirestore.instance
        .collection('users')
        .where('kyc.status', isEqualTo: 'manual_review')
        .snapshots()
        .listen((snapshot) {
          pendingUsers.value = snapshot.docs
              .map((doc) => UserModel.fromDocument(doc))
              .toList();
        });
  }

  Future<void> reviewUser(String uid, String decision) async {
    try {
      isLoading.value = true;
      Get.snackbar("Processing", "Updating user status...");

      HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
        'adminReviewKyc',
      ); // matches exports.adminReviewKyc in index.js
      await callable.call({
        'targetUserId': uid,
        'decision': decision, // 'approve' or 'reject'
      });

      Get.snackbar("Success", "User $decision successfully");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
