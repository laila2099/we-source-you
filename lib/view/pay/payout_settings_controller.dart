import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/services/payments/payout_service.dart';
import '../../core/services/payments/payout_setup_service.dart';
import '../../routes/app_routes.dart';

class PayoutSettingsController extends GetxController
    with WidgetsBindingObserver {
  final PayoutSetupService service = PayoutSetupService();
  final PayoutService payoutService = PayoutService();
  final String baseUrl = Uri.base.origin;

  final isLoading = true.obs;
  final error = ''.obs;

  final settings = <String, dynamic>{}.obs;

  Map<String, dynamic> _asMap(dynamic v) =>
      (v is Map) ? Map<String, dynamic>.from(v) : <String, dynamic>{};

  // computed helpers
  String get payoutDefault => (settings['payoutDefault'] ?? '').toString();
  Map<String, dynamic> get payoutProfile => _asMap(settings['payoutProfile']);
  Map<String, dynamic> get stripe =>
      _asMap(settings['payoutProfile']['stripe']);
  Map<String, dynamic> get paypal =>
      _asMap(settings['payoutProfile']['paypal']);

  String get stripeAccountId =>
      (stripe['stripeConnectAccountId'] ?? '').toString();
  bool get stripeReady => stripeAccountId.isNotEmpty;

  String get paypalEmail => (paypal['paypalEmail'] ?? '').toString();
  bool get paypalReady => paypalEmail.isNotEmpty;

  String get providerInProfile => (payoutProfile['provider'] ?? '').toString();
  String get effectiveDefault =>
      payoutDefault.isNotEmpty ? payoutDefault : providerInProfile;

  final selectedProvider = 'stripe'.obs;

  final _userPicked = false.obs;

  void pickProvider(String p) {
    selectedProvider.value = p;
    _userPicked.value = true;
  }

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    load();
    print(settings);
  }

  Future<void> load() async {
    try {
      isLoading.value = true;
      error.value = '';
      final data = await payoutService.getPayoutSettings();
      print(data);
      settings.assignAll(data);
      syncSelectedWithData();
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void syncSelectedWithData() {
    if (_userPicked.value) return;

    final eff = effectiveDefault;
    if (eff.isNotEmpty) {
      selectedProvider.value = eff;
      return;
    }
    if (stripeReady) {
      selectedProvider.value = 'stripe';
      return;
    }
    if (paypalReady) {
      selectedProvider.value = 'paypal';
      return;
    }
    selectedProvider.value = 'stripe';
  }

  Future<void> setDefault(String provider) async {
    try {
      await payoutService.setDefaultPayoutProvider(provider);
      Get.snackbar('Saved', 'Default payout set to $provider');
      _userPicked.value = false; // ✅ رجّعي التحكم للداتا
      await load();
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> savePayPalEmail(String email) async {
    final clean = email.trim();
    if (clean.isEmpty || !clean.contains('@')) {
      Get.snackbar('Invalid', 'Enter a valid PayPal email');
      return;
    }

    try {
      await service.setPayoutProfilePayPal(email: clean);
      Get.snackbar('Saved', 'PayPal email updated');
      await load();
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> openStripe() async {
    try {
      await service.openStripeOnboarding(baseUrl: baseUrl);
      Get.snackbar('Stripe', 'Onboarding opened');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  bool isSelectedReady(String p) =>
      p == 'stripe' ? stripeReady : (p == 'paypal' ? paypalReady : false);

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      load(); // ✅ لما ترجعي من Stripe
    }
  }

  @override
  void onReady() {
    super.onReady();

    final qp = Uri.base.queryParameters;
    if (qp['stripe'] == 'done' || qp['stripe'] == 'refresh') {
      load();

      Future.microtask(() {
        Get.offNamed(AppRoutes.payoutSettings);
      });
    }
  }
}
