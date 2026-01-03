// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:we_source_you/view/media_market/media_card/media_card.dart';
// import 'package:we_source_you/view/media_market/media_market_controller/media_market_controller.dart';

// Widget buildDiscoverGrid() {
//   final MediaController controller = Get.find();

//   return Obx(
//     () => GridView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
//         maxCrossAxisExtent: 300, // Responsive card width
//         mainAxisExtent: 280, // Fixed card height
//         crossAxisSpacing: 16,
//         mainAxisSpacing: 16,
//       ),
//       itemCount: controller.discoverMedia.length,
//       itemBuilder: (context, index) {
//         return MediaCard(item: controller.discoverMedia[index]);
//       },
//     ),
//   );
// }
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../media_card/media_card.dart';
import '../media_market_controller/media_market_controller.dart';

Widget buildDiscoverGrid(MediaController controller) {
  return Obx(() {
    if (controller.discoverMedia.isEmpty) {
      return const Center(child: Text("No media found"));
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.discoverMedia.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 300,
        mainAxisExtent: 280,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemBuilder: (context, index) =>
          MediaCard(item: controller.discoverMedia[index]),
    );
  });
}
