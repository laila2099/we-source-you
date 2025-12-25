import 'package:get/get.dart';
import 'package:we_source_you/view/team/team_controller/team_controller.dart';

class TeamBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TeamController>(() => TeamController());
  }
}

