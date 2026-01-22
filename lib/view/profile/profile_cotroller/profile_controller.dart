import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:we_source_you/model/job_post_model.dart';
import 'package:we_source_you/routes/app_routes.dart';

class ProfileController extends GetxController {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Editable state
  var isEditing = false.obs;
  var isLoading = false.obs;
  var individualJob = ''.obs; // الوظيفة الحالية
  var analystSpecialty = ''.obs; // تخصص Analyst لو تم اختياره

  // Account type
  var accountType = "individual".obs;

  // TextEditingControllers
  late TextEditingController fullNameCtrl;
  late TextEditingController emailCtrl;
  late TextEditingController phoneCtrl;

  // Individual fields
  late TextEditingController mediaWorkTypeCtrl; // For adding new type
  late TextEditingController socialLinksCtrl;
  var mediaWorkTypes = <String>[].obs; // List of job types

  // Company fields
  late TextEditingController companyNameCtrl;
  late TextEditingController websiteCtrl;
  late TextEditingController countryCtrl;
  late TextEditingController descriptionCtrl;

  // User's posted jobs
  var postedJobs = <JobPostModel>[].obs;
  var isLoadingJobs = false.obs;

  RxBool available = false.obs;
  @override
  void onInit() {
    super.onInit();

    fullNameCtrl = TextEditingController();
    emailCtrl = TextEditingController();
    phoneCtrl = TextEditingController();

    mediaWorkTypeCtrl = TextEditingController();
    socialLinksCtrl = TextEditingController();

    companyNameCtrl = TextEditingController();
    websiteCtrl = TextEditingController();
    countryCtrl = TextEditingController();
    descriptionCtrl = TextEditingController();
    getProfile();
    fetchUserJobs();
  }

  void goBack() => Get.back();

  Future<void> getProfile() async {
    try {
      isLoading.value = true;

      final doc = await firestore.collection('users').doc(uid).get();
      if (!doc.exists) return;

      final data = doc.data() as Map<String, dynamic>;

      accountType.value = data['accountType'] ?? data['type'] ?? 'individual';
      available.value = data['available'] ?? false;
      if (accountType.value == "individual") {
        fullNameCtrl.text = data["fullName"] ?? "";
        emailCtrl.text = data["email"] ?? "";
        phoneCtrl.text = data["phone"] ?? "";
        countryCtrl.text = data["country"] ?? "";
        analystSpecialty.value = data["analystSpecialty"] ?? '';
        socialLinksCtrl.text = data["socialLinks"] ?? "";

        // نجيب كل الوظائف من الـ array
        List<String> types = [];
        if (data["mediaWorkTypes"] != null) {
          types = List<String>.from(data["mediaWorkTypes"]);
        }

        mediaWorkTypes.value = types;

        // خلي أول عنصر كوظيفة أساسية

        // إذا موجود Analyst كبداية يمكن تعيينه كوظيفة أساسية
        individualJob.value = types.isNotEmpty ? types.first : '';

        // باقي الوظائف بدون أول عنصر
        // mediaWorkTypes.value = types.length > 1 ? types.sublist(1) : [];

        socialLinksCtrl.text = data["socialLinks"] ?? "";
        available.value = data['available'] ?? false; // <-- هذا السطر الجديد
      } else if (accountType.value == "company") {
        available.value = data['available'] ?? false; // <-- هذا السطر الجديد

        companyNameCtrl.text = data["companyName"] ?? "";
        emailCtrl.text = data["email"] ?? "";
        phoneCtrl.text = data["phone"] ?? "";
        countryCtrl.text = data["country"] ?? "";
        websiteCtrl.text = data["website"] ?? "";
        descriptionCtrl.text = data["description"] ?? "";
      }
      available.value = data['available'] ?? false;
    } catch (e) {
      Get.snackbar("Error", "Failed to load profile: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleAvailability(bool val) async {
    try {
      available.value = val;

      // users
      await firestore.collection('users').doc(uid).update({'available': val});

      // team (مهم جداً)
      final teamDoc = firestore.collection('team').doc(uid);
      final exists = await teamDoc.get();

      if (exists.exists) {
        await teamDoc.update({'available': val});
      }

      Get.snackbar("Success", "Availability updated");
    } catch (e) {
      Get.snackbar("Error", "Failed to update availability: $e");
    }
  }

  Future<void> fetchUserJobs() async {
    try {
      isLoadingJobs.value = true;

      final snapshot = await firestore
          .collection('jobs')
          .where('userId', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .get();

      postedJobs.value = snapshot.docs.map((doc) {
        try {
          final data = doc.data();
          final job = JobPostModel.fromMap(data);
          job.id = doc.id;
          return job;
        } catch (e) {
          Get.snackbar("Error", "Failed to load job: $e");
          // Return a default job to prevent crash
          final defaultJob = JobPostModel();
          defaultJob.id = doc.id;
          return defaultJob;
        }
      }).toList();
    } catch (e) {
      Get.snackbar("Error", "Failed to load jobs: $e");
    } finally {
      isLoadingJobs.value = false;
    }
  }

  void addMediaWorkType() {
    final type = mediaWorkTypeCtrl.text.trim();
    if (type.isNotEmpty && !mediaWorkTypes.contains(type)) {
      mediaWorkTypes.add(type); // يضاف مباشرة للـ array
      mediaWorkTypeCtrl.clear();
    }

    // إذا الوظيفة الأساسية مش موجودة ضمن القائمة نضيفها
    if (individualJob.value.isNotEmpty &&
        !mediaWorkTypes.contains(individualJob.value)) {
      mediaWorkTypes.insert(0, individualJob.value); // خليها أول عنصر
    }
  }

  void removeMediaWorkType(String type) {
    mediaWorkTypes.remove(type);
  }

  Future<void> saveProfile() async {
    try {
      isLoading.value = true;

      // دمج individualJob مع mediaWorkTypes بدون تكرار
      List<String> allJobs = mediaWorkTypes.toList();
      if (individualJob.value.isNotEmpty &&
          !allJobs.contains(individualJob.value)) {
        allJobs.insert(0, individualJob.value);
      }

      Map<String, dynamic> updateData = {
        "email": emailCtrl.text,
        "phone": phoneCtrl.text,
        "country": countryCtrl.text,
        "mediaWorkTypes": allJobs, // كل الوظائف
        "analystSpecialty": analystSpecialty.value,
        "socialLinks": socialLinksCtrl.text,
        "fullName": fullNameCtrl.text,
      };

      await firestore.collection('users').doc(uid).update(updateData);

      // تحديث team collection لو موجودة
      try {
        final teamDoc = await firestore.collection('team').doc(uid).get();
        if (teamDoc.exists) {
          Map<String, dynamic> teamData = {
            "title": allJobs.isNotEmpty ? allJobs.first : "",
            "specialties": allJobs,
          };
          await firestore.collection('team').doc(uid).update(teamData);
        }
      } catch (_) {}

      Get.snackbar("Success", "Profile updated successfully!");
      isEditing.value = false;
    } catch (e) {
      Get.snackbar("Error", "Failed to save profile: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void navigateToJob(JobPostModel job) {
    Get.toNamed(AppRoutes.applyJob, arguments: job);
  }

  Future<void> updateField(String key, dynamic value) async {
    try {
      await firestore.collection('users').doc(uid).update({key: value});
    } catch (e) {
      Get.snackbar("Error", "Failed to update $key");
    }
  }
}
