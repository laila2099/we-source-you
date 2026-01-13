import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:we_source_you/model/job_post_model.dart';

// class JobPostController extends GetxController {
//   // Current Step Index (0 to 5)
//   var currentStep = 0.obs;
//   var isSubmitting = false.obs;

//   // --- Step 1: Basics ---
//   final titleController = TextEditingController();
//   final descController = TextEditingController();
//   var experienceLevel = 'Entry Level'.obs;
//   var jobType = 'Freelance'.obs;
//   var numPositions = 1.obs;

//   // --- Step 2: Details ---
//   final minSalaryController = TextEditingController();
//   final maxSalaryController = TextEditingController();
//   var currency = 'USD - US Dollar'.obs;
//   var salaryPeriod = 'Monthly'.obs;
//   final projectDetailsController = TextEditingController();
//   var startDate = Rxn<DateTime>();
//   var endDate = Rxn<DateTime>();
//   var deadline = Rxn<DateTime>();

//   // --- Step 3: Requirements ---
//   var hasCamera = false.obs;
//   var hasAudio = false.obs;
//   var canTravel = false.obs;
//   var portfolioRequired = false.obs;
//   final contactNameController = TextEditingController();
//   final contactEmailController = TextEditingController();
//   final contactPhoneController = TextEditingController();
//   var contactMethod = 'Email'.obs;

//   // --- Step 4: Skills & Lists ---
//   // We use simple strings to add to lists for this demo
//   final skillInputController = TextEditingController();
//   var skillsList = <String>[].obs;

//   final langInputController = TextEditingController();
//   var langList = <String>[].obs;

//   final workTypeController = TextEditingController();
//   var workTypeList = <String>[].obs;

//   final locationController = TextEditingController();
//   var locationList = <String>[].obs;
//   var jobLocationType = 'Remote'.obs; // default value

//   // --- Step 5: Additional Info ---
//   final benefitsController =
//       TextEditingController(); // Comma sep logic or chips
//   final tagsController = TextEditingController();
//   final categoriesController = TextEditingController();
//   final additionalInfoController = TextEditingController();
//   var isUrgent = false.obs;
//   var isFeatured = false.obs;

//   // --- Navigation Methods ---
//   void nextStep() {
//     switch (currentStep.value) {
//       case 0: // Step 1: Basics
//         if (titleController.text.isEmpty) {
//           Get.snackbar(
//             "Required Fields Missing",
//             "Please fill Title",
//             backgroundColor: Colors.red,
//             colorText: Colors.white,
//           );
//           return;
//         }
//         break;

//       case 1: // Step 2: Details
//         if (minSalaryController.text.isEmpty ||
//             maxSalaryController.text.isEmpty ||
//             projectDetailsController.text.isEmpty) {
//           Get.snackbar(
//             "Required Fields Missing",
//             "Please fill Salary range and Project Details",
//             backgroundColor: Colors.red,
//             colorText: Colors.white,
//           );
//           return;
//         }
//         break;

//       case 2: // Step 3: Requirements
//         if (contactNameController.text.isEmpty ||
//             contactEmailController.text.isEmpty) {
//           Get.snackbar(
//             "Required Fields Missing",
//             "Please fill Contact Name and Contact Email",
//             backgroundColor: Colors.red,
//             colorText: Colors.white,
//           );
//           return;
//         }
//         break;

//       case 3: // Step 4: Skills & Languages
//         if (skillsList.isEmpty) {
//           Get.snackbar(
//             "Required Fields Missing",
//             "Please add at least one skill",
//             backgroundColor: Colors.red,
//             colorText: Colors.white,
//           );
//           return;
//         }
//         break;

//       case 4: // Step 5: Additional Info
//         // إذا لديك حقول مطلوبة هنا يمكن التحقق منها
//         break;
//     }

//     if (currentStep.value < 5) currentStep.value++;
//   }

//   void prevStep() {
//     if (currentStep.value > 0) {
//       currentStep.value--;
//     }
//   }

//   void goToStep(int step) {
//     currentStep.value = step;
//   }

//   // --- List Helpers ---
//   void addItemToList(TextEditingController controller, RxList<String> list) {
//     if (controller.text.isNotEmpty) {
//       list.add(controller.text);
//       controller.clear();
//     }
//   }

//   void removeItem(RxList<String> list, String item) {
//     list.remove(item);
//   }

//   // --- Firebase Submission ---
//   Future<void> submitJob() async {
//     isSubmitting.value = true;
//     try {
//       final normalizedJobType = _canonicalJobType(jobType.value);

//       final jobData = JobPostModel(
//         title: titleController.text,
//         description: descController.text,
//         experienceLevel: experienceLevel.value,
//         jobType: normalizedJobType,
//         numPositions: numPositions.value,
//         minSalary: double.tryParse(minSalaryController.text),
//         maxSalary: double.tryParse(maxSalaryController.text),
//         currency: currency.value,
//         period: salaryPeriod.value,
//         projectDetails: projectDetailsController.text,
//         startDate: startDate.value,
//         endDate: endDate.value,
//         deadline: deadline.value,
//         hasCamera: hasCamera.value,
//         hasAudio: hasAudio.value,
//         canTravel: canTravel.value,
//         portfolioRequired: portfolioRequired.value,
//         contactName: contactNameController.text,
//         contactEmail: contactEmailController.text,
//         contactPhone: contactPhoneController.text,
//         contactMethod: contactMethod.value,
//         skills: skillsList,
//         languages: langList,
//         mediaTypes: workTypeList,
//         jobLocationType: jobLocationType.value,
//         // For Step 5 comma separated inputs
//         benefits: benefitsController.text
//             .split(',')
//             .where((e) => e.isNotEmpty)
//             .toList(),
//         tags: tagsController.text
//             .split(',')
//             .where((e) => e.isNotEmpty)
//             .toList(),
//         categories: categoriesController.text
//             .split(',')
//             .where((e) => e.isNotEmpty)
//             .toList(),
//         additionalInfo: additionalInfoController.text,
//         isUrgent: isUrgent.value,
//         isFeatured: isFeatured.value,
//       );

//       final user = FirebaseAuth.instance.currentUser;
//       final jobMap = jobData.toMap();
//       jobMap['userId'] = user?.uid ?? '';

//       await FirebaseFirestore.instance.collection('jobs').add(jobMap);

//       Get.snackbar(
//         "Success",
//         "Job posted successfully!",
//         backgroundColor: Colors.green,
//         colorText: Colors.white,
//       );

//       // Reset or Navigate away
//     } catch (e) {
//       Get.snackbar(
//         "Error",
//         e.toString(),
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     } finally {
//       isSubmitting.value = false;
//     }
//   }

//   String _canonicalJobType(String value) {
//     // Convert "Part Time" or "part-time" -> "Part-Time" to align with filters
//     final trimmed = value.trim();
//     if (trimmed.isEmpty) return 'Freelance';
//     final dashed = trimmed.replaceAll(RegExp(r'\s+'), '-');
//     // Title-case words separated by dash
//     return dashed
//         .split('-')
//         .where((w) => w.isNotEmpty)
//         .map((w) => '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
//         .join('-');
//   }
// }
class JobPostController extends GetxController {
  // Current Step Index (0 to 5)
  var currentStep = 0.obs;
  var isSubmitting = false.obs;

  // --- Step 1: Basics ---
  final titleController = TextEditingController();
  final descController = TextEditingController();
  var experienceLevel = 'Entry Level'.obs;
  var jobType = 'Freelance'.obs;
  var numPositions = 1.obs;

  // --- Step 2: Details ---
  final minSalaryController = TextEditingController();
  final maxSalaryController = TextEditingController();
  var currency = 'USD - US Dollar'.obs;
  var salaryPeriod = 'Monthly'.obs;
  final projectDetailsController = TextEditingController();
  var startDate = Rxn<DateTime>();
  var endDate = Rxn<DateTime>();
  var deadline = Rxn<DateTime>();

  // --- Step 3: Requirements ---
  var hasCamera = false.obs;
  var hasAudio = false.obs;
  var canTravel = false.obs;
  var portfolioRequired = false.obs;
  final contactNameController = TextEditingController();
  final contactEmailController = TextEditingController();
  final contactPhoneController = TextEditingController();
  var contactMethod = 'Email'.obs;

  // --- Step 4: Skills & Lists ---
  final skillInputController = TextEditingController();
  var skillsList = <String>[].obs;

  final langInputController = TextEditingController();
  var langList = <String>[].obs;

  final workTypeController = TextEditingController();
  var workTypeList = <String>[].obs;

  // --- Job Location ---
  var jobLocationType = 'Remote'.obs; // Remote / Onsite
  var selectedCountry = ''.obs; // If Onsite

  // --- Step 5: Additional Info ---
  final benefitsController = TextEditingController();
  final tagsController = TextEditingController();
  final categoriesController = TextEditingController();
  final additionalInfoController = TextEditingController();
  var isUrgent = false.obs;
  var isFeatured = false.obs;

  // --- Navigation Methods ---
  void nextStep() {
    switch (currentStep.value) {
      case 0:
        if (titleController.text.isEmpty) {
          Get.snackbar(
            "Required Fields Missing",
            "Please fill Title",
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }
        break;
      case 1:
        if (minSalaryController.text.isEmpty ||
            maxSalaryController.text.isEmpty ||
            projectDetailsController.text.isEmpty) {
          Get.snackbar(
            "Required Fields Missing",
            "Please fill Salary range and Project Details",
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }
        break;
      case 2:
        if (contactNameController.text.isEmpty ||
            contactEmailController.text.isEmpty) {
          Get.snackbar(
            "Required Fields Missing",
            "Please fill Contact Name and Contact Email",
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }
        break;
      case 3:
        if (skillsList.isEmpty) {
          Get.snackbar(
            "Required Fields Missing",
            "Please add at least one skill",
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }
        // If Onsite, ensure country selected
        if (jobLocationType.value == 'Onsite' &&
            selectedCountry.value.isEmpty) {
          Get.snackbar(
            "Required Field Missing",
            "Please select a country for Onsite job",
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }
        break;
      case 4:
        // Optional additional info check if needed
        break;
    }
    if (currentStep.value < 5) currentStep.value++;
  }

  void prevStep() {
    if (currentStep.value > 0) currentStep.value--;
  }

  void goToStep(int step) {
    currentStep.value = step;
  }

  // --- List Helpers ---
  void addItemToList(TextEditingController controller, RxList<String> list) {
    if (controller.text.isNotEmpty) {
      list.add(controller.text);
      controller.clear();
    }
  }

  void removeItem(RxList<String> list, String item) {
    list.remove(item);
  }

  // --- Firebase Submission ---
  Future<void> submitJob() async {
    isSubmitting.value = true;
    try {
      final normalizedJobType = _canonicalJobType(jobType.value);
      final jobData = JobPostModel(
        title: titleController.text,
        description: descController.text,
        experienceLevel: experienceLevel.value,
        jobType: normalizedJobType,
        numPositions: numPositions.value,
        minSalary: double.tryParse(minSalaryController.text),
        maxSalary: double.tryParse(maxSalaryController.text),
        currency: currency.value,
        period: salaryPeriod.value,
        projectDetails: projectDetailsController.text,
        startDate: startDate.value,
        endDate: endDate.value,
        deadline: deadline.value,
        hasCamera: hasCamera.value,
        hasAudio: hasAudio.value,
        canTravel: canTravel.value,
        portfolioRequired: portfolioRequired.value,
        contactName: contactNameController.text,
        contactEmail: contactEmailController.text,
        contactPhone: contactPhoneController.text,
        contactMethod: contactMethod.value,
        skills: skillsList,
        languages: langList,
        mediaTypes: workTypeList,
        jobLocationType: jobLocationType.value == 'Remote'
            ? 'Remote'
            : selectedCountry.value,
        benefits: benefitsController.text
            .split(',')
            .where((e) => e.isNotEmpty)
            .toList(),
        tags: tagsController.text
            .split(',')
            .where((e) => e.isNotEmpty)
            .toList(),
        categories: categoriesController.text
            .split(',')
            .where((e) => e.isNotEmpty)
            .toList(),
        additionalInfo: additionalInfoController.text,
        isUrgent: isUrgent.value,
        isFeatured: isFeatured.value,
      );

      final user = FirebaseAuth.instance.currentUser;
      final jobMap = jobData.toMap();
      jobMap['userId'] = user?.uid ?? '';

      await FirebaseFirestore.instance.collection('jobs').add(jobMap);

      Get.snackbar(
        "Success",
        "Job posted successfully!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  String _canonicalJobType(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'Freelance';
    final dashed = trimmed.replaceAll(RegExp(r'\s+'), '-');
    return dashed
        .split('-')
        .where((w) => w.isNotEmpty)
        .map((w) => '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
        .join('-');
  }
}
