import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:we_source_you/routes/app_routes.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final box = GetStorage();

  Rxn<User> firebaseUser = Rxn<User>();
  RxBool isLoggedIn = false.obs;

  RxString role = 'user'.obs;
  RxString accountType = ''.obs;

  RxString country = ''.obs;
  RxString city = ''.obs;
  RxString phone = ''.obs;

  // Individual
  RxString fullName = ''.obs;
  RxList<String> mediaWorkTypes = <String>[].obs;
  RxString analystSpecialty = ''.obs;
  RxString socialLinks = ''.obs;

  // Company
  RxString companyName = ''.obs;
  RxString website = ''.obs;

  bool rememberMe = false;
  RxBool isUserDataLoaded = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initAuth();
  }

  // ---------------------------
  // Initialization
  // ---------------------------
  Future<void> _initAuth() async {
    rememberMe = box.read('rememberMe') ?? false;

    try {
      await _auth.setPersistence(
        rememberMe ? Persistence.LOCAL : Persistence.SESSION,
      );
    } catch (e) {
      debugPrint('⚠️ Persistence error: $e');
    }

    // Bind auth state
    firebaseUser.bindStream(_auth.authStateChanges());

    ever(firebaseUser, (User? user) async {
      if (user == null) {
        _clearState();
        return;
      }

      isLoggedIn.value = true;

      await _loadUserData(user.uid);

      _handlePostLoginRouting();
    });

    // Load cached data for quick UI update
    _loadLocalCache();
  }

  // ---------------------------
  // Manual refresh auth state
  // ---------------------------
  Future<void> refreshAuthState() async {
    final user = _auth.currentUser;
    if (user != null) {
      firebaseUser.value = user;
      isLoggedIn.value = true;
      await _loadUserData(user.uid);
      _handlePostLoginRouting();
    } else {
      _clearState();
    }
  }

  // ---------------------------
  // Load user data from Firestore
  // ---------------------------
  Future<void> _loadUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return;

      final data = doc.data()!;

      role.value = data['role'] ?? 'user';
      accountType.value = data['type'] ?? 'individual';

      country.value = data['country']?.toString() ?? '';
      city.value = data['city']?.toString() ?? '';
      phone.value = data['phone']?.toString() ?? '';

      fullName.value = data['fullName']?.toString() ?? '';
      mediaWorkTypes.assignAll(
        data['mediaWorkTypes'] != null
            ? List<String>.from(data['mediaWorkTypes'])
            : [],
      );
      analystSpecialty.value = data['analystSpecialty']?.toString() ?? '';
      socialLinks.value = data['socialLinks']?.toString() ?? '';

      companyName.value =
          data['companyName']?.toString() ?? data['name']?.toString() ?? '';
      website.value = data['website']?.toString() ?? '';
      isUserDataLoaded.value = true;

      // Cache locally
      await box.write('role', role.value);
      await box.write('accountType', accountType.value);
      await box.write('country', country.value);
      await box.write('city', city.value);
      await box.write('phone', phone.value);
      await box.write('fullName', fullName.value);
      await box.write('mediaWorkTypes', mediaWorkTypes.toList());
      await box.write('analystSpecialty', analystSpecialty.value);
      await box.write('socialLinks', socialLinks.value);
      await box.write('companyName', companyName.value);
      await box.write('website', website.value);
    } catch (e) {
      debugPrint('⚠️ Firestore load error: $e');
    }
  }

  // ---------------------------
  // Google Sign-In
  // ---------------------------
  Future<UserCredential?> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn.standard(scopes: ['email', 'profile']);

    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    return await _auth.signInWithCredential(credential);
  }

  // ---------------------------
  // Routing
  // ---------------------------
  // void _handlePostLoginRouting() {
  //   if (!isLoggedIn.value) return;

  //   if (role.value == 'admin') {
  //     Get.offAllNamed(AppRoutes.adminDashboard);
  //   } else {
  //     Get.offAllNamed(AppRoutes.home);
  //   }
  // }
  void _handlePostLoginRouting() {
    if (!isLoggedIn.value) return;

    // 1. تحقق مما إذا كان المستخدم قادماً من عملية دفع أو في مسار المكتبة حالياً
    // في الويب، المسار الحالي يمنعنا من عمل إعادة توجيه قسرية للهوم
    String currentRoute = Get.currentRoute;

    if (currentRoute == AppRoutes.myLibrary ||
        currentRoute.contains('payment-success')) {
      debugPrint(
        "العودة من الدفع: تم إيقاف التوجيه التلقائي للحفاظ على المسار الحالي",
      );
      return; // توقف هنا ولا تذهب للهوم
    }

    // 2. التوجيه الطبيعي عند فتح التطبيق لأول مرة فقط
    if (role.value == 'admin') {
      Get.offAllNamed(AppRoutes.adminDashboard);
    } else {
      Get.offAllNamed(AppRoutes.home);
    }
  }

  // ---------------------------
  // Logout
  // ---------------------------
  Future<void> logout() async {
    await _auth.signOut();
    await box.erase();
    _clearState();
    Get.offAllNamed(AppRoutes.signin);
  }

  // ---------------------------
  // Helpers
  // ---------------------------
  void _clearState() {
    isLoggedIn.value = false;
    role.value = 'user';
    accountType.value = '';

    country.value = '';
    city.value = '';
    phone.value = '';

    fullName.value = '';
    mediaWorkTypes.clear();
    analystSpecialty.value = '';
    // socialLinks.clear();

    companyName.value = '';
    website.value = '';
  }

  void _loadLocalCache() {
    role.value = box.read('role') ?? role.value;
    accountType.value = box.read('accountType') ?? accountType.value;
    country.value = box.read('country') ?? '';
    city.value = box.read('city') ?? '';
    phone.value = box.read('phone') ?? '';
    fullName.value = box.read('fullName') ?? '';
    analystSpecialty.value = box.read('analystSpecialty') ?? '';
    socialLinks.value = box.read('socialLinks') ?? '';
    companyName.value = box.read('companyName') ?? '';
    website.value = box.read('website') ?? '';

    final storedTypes = box.read('mediaWorkTypes');
    if (storedTypes != null) {
      mediaWorkTypes.assignAll(List<String>.from(storedTypes));
    }
  }

  // ---------------------------
  // Avatar Letter
  // ---------------------------
  String get avatarLetter {
    final name = accountType.value == 'company'
        ? companyName.value
        : fullName.value;

    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}
