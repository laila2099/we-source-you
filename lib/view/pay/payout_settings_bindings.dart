import 'package:get/get.dart';

import 'payout_settings_controller.dart';

class PayoutBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PayoutSettingsController>(() => PayoutSettingsController());
  }
}
