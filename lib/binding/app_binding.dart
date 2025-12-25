// import 'package:get/get.dart';
// import 'package:we_source_you/view/auth/auth_controller/auth_controller.dart';
// import 'package:we_source_you/view/home/home_controller/home_controller.dart';
// import 'package:we_source_you/view/team/team_controller/team_controller.dart';

// class AppBinding extends Bindings {
//   @override5
//   void dependencies() {
//     Get.put<AuthController>(AuthController(), permanent: true);
//     Get.put<HomeController>(HomeController(), permanent: true);
//     Get.put(TeamController());
//   }
// }

import 'package:get/get.dart';
import 'package:we_source_you/view/auth/auth_controller/auth_controller.dart';
import 'package:we_source_you/view/home/home_controller/home_controller.dart';
import 'package:we_source_you/view/team/team_controller/team_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
    Get.lazyPut<TeamController>(() => TeamController(), fenix: true);
  }
}
