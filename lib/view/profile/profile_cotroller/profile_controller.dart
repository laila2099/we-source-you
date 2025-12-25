// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class ProfileController extends GetxController {
//   final uid = FirebaseAuth.instance.currentUser!.uid;
//   final FirebaseFirestore firestore = FirebaseFirestore.instance;

//   // Editable state
//   var isEditing = false.obs;
//   var isLoading = false.obs;

//   // TextEditingControllers
//   late TextEditingController firstNameCtrl;
//   late TextEditingController lastNameCtrl;
//   late TextEditingController emailCtrl;
//   late TextEditingController phoneCtrl;
//   late TextEditingController cityCtrl;

//   @override
//   void onInit() {
//     super.onInit();
//     firstNameCtrl = TextEditingController();
//     lastNameCtrl = TextEditingController();
//     emailCtrl = TextEditingController();
//     phoneCtrl = TextEditingController();
//     cityCtrl = TextEditingController();

//     getProfile();
//   }

//   void goBack() => Get.back();

//   Future<void> getProfile() async {
//     try {
//       isLoading.value = true;

//       final doc = await firestore.collection('users').doc(uid).get();
//       if (!doc.exists) return;

//       final data = doc.data() as Map<String, dynamic>;

//       firstNameCtrl.text = data["firstName"] ?? "";
//       lastNameCtrl.text = data["lastName"] ?? "";
//       emailCtrl.text = data["email"] ?? "";
//       phoneCtrl.text = data["phone"] ?? "";
//       cityCtrl.text = data["city"] ?? "";
//     } catch (e) {
//       Get.snackbar("Error", "Failed to load profile: $e");
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   Future<void> saveProfile() async {
//     try {
//       isLoading.value = true;

//       await firestore.collection('users').doc(uid).update({
//         "firstName": firstNameCtrl.text,
//         "lastName": lastNameCtrl.text,
//         "email": emailCtrl.text,
//         "phone": phoneCtrl.text,
//         "city": cityCtrl.text,
//       });

//       Get.snackbar("Success", "Profile updated successfully!");
//       isEditing.value = false;
//     } catch (e) {
//       Get.snackbar("Error", "Failed to save profile: $e");
//     } finally {
//       isLoading.value = false;
//     }
//   }
// }
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

  // Account type
  var accountType = "individual".obs; // "company" or "individual"

  // TextEditingControllers
  late TextEditingController firstNameCtrl;
  late TextEditingController lastNameCtrl;
  late TextEditingController emailCtrl;
  late TextEditingController phoneCtrl;
  late TextEditingController cityCtrl;

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

  @override
  void onInit() {
    super.onInit();

    firstNameCtrl = TextEditingController();
    lastNameCtrl = TextEditingController();
    emailCtrl = TextEditingController();
    phoneCtrl = TextEditingController();
    cityCtrl = TextEditingController();

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

      if (accountType.value == "individual") {
        firstNameCtrl.text = data["firstName"] ?? "";
        lastNameCtrl.text = data["lastName"] ?? "";
        emailCtrl.text = data["email"] ?? "";
        phoneCtrl.text = data["phone"] ?? "";
        cityCtrl.text = data["city"] ?? "";
        
        // Handle mediaWorkType as list or string
        if (data["mediaWorkTypes"] != null) {
          mediaWorkTypes.value = List<String>.from(data["mediaWorkTypes"]);
        } else if (data["mediaWorkType"] != null) {
          mediaWorkTypes.value = [data["mediaWorkType"]];
        }
        
        socialLinksCtrl.text = data["socialLinks"] ?? "";
      } else if (accountType.value == "company") {
        companyNameCtrl.text = data["companyName"] ?? "";
        emailCtrl.text = data["email"] ?? "";
        phoneCtrl.text = data["phone"] ?? "";
        cityCtrl.text = data["city"] ?? "";
        countryCtrl.text = data["country"] ?? "";
        websiteCtrl.text = data["website"] ?? "";
        descriptionCtrl.text = data["description"] ?? "";
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to load profile: $e");
    } finally {
      isLoading.value = false;
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
    if (mediaWorkTypeCtrl.text.trim().isNotEmpty) {
      final type = mediaWorkTypeCtrl.text.trim();
      if (!mediaWorkTypes.contains(type)) {
        mediaWorkTypes.add(type);
        mediaWorkTypeCtrl.clear();
      }
    }
  }

  void removeMediaWorkType(String type) {
    mediaWorkTypes.remove(type);
  }

  Future<void> saveProfile() async {
    try {
      isLoading.value = true;

      Map<String, dynamic> updateData = {
        "email": emailCtrl.text,
        "phone": phoneCtrl.text,
        "city": cityCtrl.text,
      };

      if (accountType.value == "individual") {
        updateData.addAll({
          "firstName": firstNameCtrl.text,
          "lastName": lastNameCtrl.text,
          "mediaWorkTypes": mediaWorkTypes.toList(), // Save as list
          "socialLinks": socialLinksCtrl.text,
        });
      } else if (accountType.value == "company") {
        updateData.addAll({
          "companyName": companyNameCtrl.text,
          "website": websiteCtrl.text,
          "country": countryCtrl.text,
          "description": descriptionCtrl.text,
        });
      }

      await firestore.collection('users').doc(uid).update(updateData);

      // Also update team collection if exists
      try {
        final teamDoc = await firestore.collection('team').doc(uid).get();
        if (teamDoc.exists) {
          Map<String, dynamic> teamData = {};
          if (accountType.value == "individual") {
            teamData = {
              "name": "${firstNameCtrl.text} ${lastNameCtrl.text}".trim(),
              "title": mediaWorkTypes.isNotEmpty ? mediaWorkTypes.first : "",
              "specialties": mediaWorkTypes.toList(),
            };
          } else {
            teamData = {
              "name": companyNameCtrl.text,
              "title": "Company",
            };
          }
          await firestore.collection('team').doc(uid).update(teamData);
        }
      } catch (e) {
        // Team update is optional
      }

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
}
