// import 'package:get/get.dart';
// import 'package:we_source_you/view/media_market/media_market_controller/media_market_controller.dart';

// class MediaBinding extends Bindings {
//   @override
//   void dependencies() {
//     Get.lazyPut<MediaController>(() => MediaController());
//   }
// }
import 'package:get/get.dart';
import 'package:we_source_you/view/media_market/media_market_controller/media_market_controller.dart';

class MediaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MediaController>(() => MediaController(), fenix: true);
  }
}
