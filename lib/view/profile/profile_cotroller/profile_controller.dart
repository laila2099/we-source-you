import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:we_source_you/model/job_post_model.dart';
import 'package:we_source_you/routes/app_routes.dart';

class ProfileController extends GetxController {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  // Payout info
  var payoutProfile = <String, dynamic>{}.obs;
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
  var hourlyRate = 0.0.obs;
  var dailyRate = 0.0.obs;
  var projectRate = 0.0.obs;
  var kycStatus = ''.obs;
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

  // Future<void> getProfile() async {
  //   try {
  //     isLoading.value = true;

  //     final doc = await firestore.collection('users').doc(uid).get();
  //     if (!doc.exists) return;

  //     final data = doc.data() as Map<String, dynamic>;
  //     kycStatus.value = data['kycStatus'] ?? ''; // empty if not started

  //     accountType.value = data['accountType'] ?? data['type'] ?? 'individual';
  //     available.value = data['available'] ?? false;
  //     if (accountType.value == "individual") {
  //       fullNameCtrl.text = data["fullName"] ?? "";
  //       emailCtrl.text = data["email"] ?? "";
  //       phoneCtrl.text = data["phone"] ?? "";
  //       countryCtrl.text = data["country"] ?? "";
  //       analystSpecialty.value = data["analystSpecialty"] ?? '';
  //       socialLinksCtrl.text = data["socialLinks"] ?? "";

  //       // نجيب كل الوظائف من الـ array
  //       List<String> types = [];
  //       if (data["mediaWorkTypes"] != null) {
  //         types = List<String>.from(data["mediaWorkTypes"]);
  //       }

  //       mediaWorkTypes.value = types;

  //       // خلي أول عنصر كوظيفة أساسية

  //       // إذا موجود Analyst كبداية يمكن تعيينه كوظيفة أساسية
  //       individualJob.value = types.isNotEmpty ? types.first : '';

  //       // باقي الوظائف بدون أول عنصر
  //       // mediaWorkTypes.value = types.length > 1 ? types.sublist(1) : [];

  //       socialLinksCtrl.text = data["socialLinks"] ?? "";
  //       available.value = data['available'] ?? false; // <-- هذا السطر الجديد
  //     } else if (accountType.value == "company") {
  //       available.value = data['available'] ?? false; // <-- هذا السطر الجديد

  //       companyNameCtrl.text = data["companyName"] ?? "";
  //       emailCtrl.text = data["email"] ?? "";
  //       phoneCtrl.text = data["phone"] ?? "";
  //       countryCtrl.text = data["country"] ?? "";
  //       websiteCtrl.text = data["website"] ?? "";
  //       descriptionCtrl.text = data["description"] ?? "";
  //     }
  //     payoutProfile.value = data['payoutProfile'] ?? {};

  //     available.value = data['available'] ?? false;
  //     final teamDoc = await firestore.collection('team').doc(uid).get();
  //     if (teamDoc.exists) {
  //       final teamData = teamDoc.data()!;
  //       hourlyRate.value = (teamData['hourlyRate'] ?? 0).toDouble();
  //       dailyRate.value = (teamData['dailyRate'] ?? 0).toDouble();
  //       projectRate.value = (teamData['projectRate'] ?? 0).toDouble();
  //       available.value = teamData['available'] ?? available.value;
  //     }
  //   } catch (e) {
  //     Get.snackbar("Error", "Failed to load profile: $e");
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }
  Future<void> getProfile() async {
    try {
      isLoading.value = true;
      final doc = await firestore.collection('users').doc(uid).get();
      if (!doc.exists) return;

      final data = doc.data() as Map<String, dynamic>;

      // تحويل آمن لكل الحقول النصية لتجنب خطأ الـ LinkedMap
      kycStatus.value = data['kycStatus']?.toString() ?? '';
      accountType.value =
          data['accountType']?.toString() ??
          data['type']?.toString() ??
          'individual';
      available.value = data['available'] == true;

      if (accountType.value == "individual") {
        fullNameCtrl.text = data["fullName"]?.toString() ?? "";
        emailCtrl.text = data["email"]?.toString() ?? "";
        phoneCtrl.text = data["phone"]?.toString() ?? "";
        countryCtrl.text = data["country"]?.toString() ?? "";
        analystSpecialty.value = data["analystSpecialty"]?.toString() ?? '';
        socialLinksCtrl.text = data["socialLinks"]?.toString() ?? "";

        if (data["mediaWorkTypes"] is List) {
          mediaWorkTypes.value = List<String>.from(data["mediaWorkTypes"]);
        }
        individualJob.value = mediaWorkTypes.isNotEmpty
            ? mediaWorkTypes.first
            : '';
      } else {
        companyNameCtrl.text = data["companyName"]?.toString() ?? "";
        emailCtrl.text = data["email"]?.toString() ?? "";
        phoneCtrl.text = data["phone"]?.toString() ?? "";
        countryCtrl.text = data["country"]?.toString() ?? "";
        websiteCtrl.text = data["website"]?.toString() ?? "";
        descriptionCtrl.text = data["description"]?.toString() ?? "";
      }

      // التعامل مع الـ Map
      if (data['payoutProfile'] is Map) {
        payoutProfile.value = Map<String, dynamic>.from(data['payoutProfile']);
      }

      // جلب بيانات الأسعار من الـ team collection
      final teamDoc = await firestore.collection('team').doc(uid).get();
      if (teamDoc.exists) {
        final teamData = teamDoc.data()!;
        // التأكد من تحويل الرقم بشكل صحيح
        hourlyRate.value =
            double.tryParse(teamData['hourlyRate']?.toString() ?? '0') ?? 0.0;
        dailyRate.value =
            double.tryParse(teamData['dailyRate']?.toString() ?? '0') ?? 0.0;
        projectRate.value =
            double.tryParse(teamData['projectRate']?.toString() ?? '0') ?? 0.0;
      }
    } catch (e) {
      print(
        "Error details: $e",
      ); // هذا سيطبع لكِ في الـ Console أي حقل بالضبط هو المشكلة
      Get.snackbar("Error", "Failed to load profile details");
    } finally {
      isLoading.value = false;
    }
  }

  bool get canBeAvailable {
    final paypal = payoutProfile['paypal'] as Map? ?? {};
    final stripe = payoutProfile['stripe'] as Map? ?? {};

    bool hasPayment =
        (paypal['enabled'] == true &&
            (paypal['paypalEmail']?.isNotEmpty ?? false)) ||
        (stripe['enabled'] == true &&
            (stripe['stripeConnectAccountId']?.isNotEmpty ?? false));
    if (!hasPayment) return false;
    if (accountType.value == "individual") {
      // Individual يمكن استخدام كل شيء
      return fullNameCtrl.text.isNotEmpty &&
          phoneCtrl.text.isNotEmpty &&
          mediaWorkTypes.isNotEmpty &&
          analystSpecialty.isNotEmpty &&
          hourlyRate > 0 &&
          dailyRate > 0 &&
          projectRate > 0;
    } else if (accountType.value == "company") {
      // Company يحتاج companyName + rates
      return companyNameCtrl.text.isNotEmpty &&
          hourlyRate > 0 &&
          dailyRate > 0 &&
          projectRate > 0;
    }
    return false;
  }

  Future<void> toggleAvailability(bool val) async {
    // شرط التأكد من وجود كل rates
    if (hourlyRate.value <= 0 ||
        dailyRate.value <= 0 ||
        projectRate.value <= 0) {
      Get.snackbar(
        "Error",
        "Please fill in all rates before enabling availability",
      );
      return;
    }
    final paypalData = payoutProfile['paypal'];
    final stripeData = payoutProfile['stripe'];
    bool isPaypalReady =
        paypalData != null &&
        paypalData['enabled'] == true &&
        (paypalData['paypalEmail'] != null &&
            paypalData['paypalEmail'].toString().isNotEmpty);

    // التحقق من تفعيل سترايب ووجود الآيدي
    bool isStripeReady =
        stripeData != null &&
        stripeData['enabled'] == true &&
        (stripeData['stripeConnectAccountId'] != null &&
            stripeData['stripeConnectAccountId'].toString().isNotEmpty);

    // إذا لم يكن أي منهما جاهزاً، نمنع التوفر
    if (!isPaypalReady && !isStripeReady) {
      Get.snackbar(
        "Action Required",
        "Please add a valid payout method (PayPal or Stripe) in your settings to become available.",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      // إعادة الزر لوضعه السابق في الواجهة لكي لا يظهر أنه تفعل
      available.value = false;
      return;
    }
    try {
      available.value = val;

      // تحديث users document (اختياري)
      await firestore.collection('users').doc(uid).update({'available': val});

      // تحديث team document
      final teamRef = firestore.collection('team').doc(uid);
      final teamDoc = await teamRef.get();
      if (teamDoc.exists) {
        await teamRef.update({'available': val});
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

      // ---------------- تحديث users document ----------------
      Map<String, dynamic> updateData = {
        "email": emailCtrl.text,
        "phone": phoneCtrl.text,
        "country": countryCtrl.text,
        "mediaWorkTypes": allJobs,
        "analystSpecialty": analystSpecialty.value,
        "socialLinks": socialLinksCtrl.text,
        "fullName": fullNameCtrl.text,
        "hourlyRate": hourlyRate.value,
        "dailyRate": dailyRate.value,
        "projectRate": projectRate.value,
        "available": available.value,
      };

      if (accountType.value == "company") {
        updateData.addAll({
          "companyName": companyNameCtrl.text,
          "website": websiteCtrl.text,
          "description": descriptionCtrl.text,
        });
      }

      await firestore.collection('users').doc(uid).update(updateData);

      try {
        final teamDoc = await firestore.collection('team').doc(uid).get();
        if (teamDoc.exists) {
          Map<String, dynamic> teamData = {
            "title": allJobs.isNotEmpty ? allJobs.first : "",
            "specialties": allJobs,
            "hourlyRate": hourlyRate.value,
            "dailyRate": dailyRate.value,
            "projectRate": projectRate.value,
            "available": available.value,
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
