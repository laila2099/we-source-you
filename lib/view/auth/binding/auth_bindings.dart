import 'package:get/get.dart';
import 'package:we_source_you/view/auth/sign_up/sign_up_controller/sign_up_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(SignUpController());
  }
}
