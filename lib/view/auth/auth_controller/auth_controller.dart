import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final box = GetStorage();

  Rxn<User> firebaseUser = Rxn<User>();

  RxBool isLoggedIn = false.obs;
  RxString country = ''.obs;
  RxString city = ''.obs;
  RxString phone = ''.obs;

  bool rememberMe = false;
  RxString accountType = ''.obs; // individual | company

  // ---------------------------
  // Individual data
  // ---------------------------
  RxString fullName = ''.obs;
  RxString mediaWorkType = ''.obs;
  RxString analystSpecialty = ''.obs;
  RxString socialLinks = ''.obs;

  // ---------------------------
  // Company data
  // ---------------------------
  RxString companyName = ''.obs;
  RxString website = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initAuth();
  }

  // ---------------------------
  // Initialization
  // ---------------------------
  Future<void> _initAuth() async {
    // 1️⃣ Read Remember Me from local storage
    rememberMe = box.read('rememberMe') ?? false;

    // 2️⃣ Set persistence **قبل** أي auth check
    try {
      await _auth.setPersistence(
        rememberMe ? Persistence.LOCAL : Persistence.SESSION,
      );
    } catch (e) {
      print('⚠️ Error setting persistence: $e');
    }

    // 3️⃣ Bind auth state changes
    firebaseUser.bindStream(_auth.authStateChanges());

    ever(firebaseUser, (User? user) async {
      if (user == null) {
        isLoggedIn.value = false;

        country.value = '';
        city.value = '';
        phone.value = '';
      } else {
        isLoggedIn.value = true;
        await _loadUserData(user.uid);
      }
    });

    // 4️⃣ Force check current user
    final user = _auth.currentUser;
    if (user != null) {
      firebaseUser.value = user;
    }

    // 5️⃣ Load any locally stored data

    country.value = box.read('country') ?? country.value;
    city.value = box.read('city') ?? city.value;
    phone.value = box.read('phone') ?? phone.value;
    accountType.value = box.read('accountType') ?? accountType.value;

    fullName.value = box.read('fullName') ?? fullName.value;
    mediaWorkType.value = box.read('mediaWorkType') ?? mediaWorkType.value;
    analystSpecialty.value =
        box.read('analystSpecialty') ?? analystSpecialty.value;
    socialLinks.value = box.read('socialLinks') ?? socialLinks.value;

    companyName.value = box.read('companyName') ?? companyName.value;
    website.value = box.read('website') ?? website.value;
  }

  // ---------------------------
  // Load user data from Firestore & store locally
  // ---------------------------
  Future<void> _loadUserData(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists) {
        final data = doc.data() ?? <String, dynamic>{};

        country.value = data['country']?.toString() ?? '';
        city.value = data['city']?.toString() ?? '';
        phone.value = data['phone']?.toString() ?? '';
        accountType.value = data['type']?.toString() ?? 'individual';

        // ---------------------------
        // Individual
        // ---------------------------
        fullName.value = data['fullName']?.toString() ?? '';
        mediaWorkType.value = data['mediaWorkType']?.toString() ?? '';
        analystSpecialty.value = data['analystSpecialty']?.toString() ?? '';
        socialLinks.value = data['socialLinks']?.toString() ?? '';

        // ---------------------------
        // Company
        // ---------------------------
        companyName.value =
            data['companyName']?.toString() ?? data['name']?.toString() ?? '';
        website.value = data['website']?.toString() ?? '';

        // حفظ محليًا لضمان persistence بعد stop/run

        await box.write('country', country.value);
        await box.write('city', city.value);
        await box.write('phone', phone.value);
        await box.write('accountType', accountType.value);

        await box.write('fullName', fullName.value);
        await box.write('mediaWorkType', mediaWorkType.value);
        await box.write('analystSpecialty', analystSpecialty.value);
        await box.write('socialLinks', socialLinks.value);

        await box.write('companyName', companyName.value);
        await box.write('website', website.value);
      }
    } catch (e) {
      print('⚠️ Error fetching user data: $e');
    }
  }

  // ---------------------------
  // Manual check & update auth state
  // ---------------------------
  Future<void> _checkAuthState() async {
    final user = _auth.currentUser;
    if (user != null) {
      firebaseUser.value = user;
      isLoggedIn.value = true;
      await _loadUserData(user.uid);
    } else {
      isLoggedIn.value = false;

      country.value = '';
      city.value = '';
      phone.value = '';
    }
  }

  // ---------------------------
  // Public method to refresh auth state
  // ---------------------------
  Future<void> refreshAuthState() async {
    await _checkAuthState();
  }

  // ---------------------------
  // Logout
  // ---------------------------
  void logout() async {
    await _auth.signOut();
    isLoggedIn.value = false;

    country.value = '';
    city.value = '';
    phone.value = '';
    accountType.value = '';
    fullName.value = '';
    mediaWorkType.value = '';
    analystSpecialty.value = '';
    socialLinks.value = '';
    companyName.value = '';
    website.value = '';

    await box.remove('accountType');
    await box.remove('fullName');
    await box.remove('mediaWorkType');
    await box.remove('analystSpecialty');
    await box.remove('socialLinks');
    await box.remove('companyName');
    await box.remove('website');

    // مسح البيانات المحلية عند logout
    await box.remove('firstName');
    await box.remove('lastName');
    await box.remove('country');
    await box.remove('city');
    await box.remove('phone');
    await box.remove('rememberMe');
  }

  // ---------------------------
  // Check auth before sensitive actions
  // ---------------------------
  bool checkAuthForAction() {
    if (!isLoggedIn.value) {
      Get.snackbar(
        "Authentication Required",
        "You must be signed in to perform this action.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }
    return true;
  }

  // ---------------------------
  // Avatar letter
  // ---------------------------
  String get avatarLetter {
    if (accountType.value == 'company' && companyName.isNotEmpty) {
      return companyName.value[0].toUpperCase();
    }
    if (fullName.isNotEmpty) {
      return fullName.value[0].toUpperCase();
    }
    return '?';
  }
}
