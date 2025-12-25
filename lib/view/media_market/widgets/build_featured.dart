// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:we_source_you/view/media_market/media_card/media_card.dart';
// import 'package:we_source_you/view/media_market/media_market_controller/media_market_controller.dart';

// Widget buildFeaturedList() {
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
//       itemCount: controller.featuredMedia.length,
//       itemBuilder: (context, index) {
//         return MediaCard(item: controller.featuredMedia[index]);
//       },
//     ),
//   );
// }
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:we_source_you/view/media_market/media_card/media_card.dart';
// import 'package:we_source_you/view/media_market/media_market_controller/media_market_controller.dart';

// Widget buildFeaturedList() {
//   final MediaController controller = Get.find();

//   return Obx(() {
//     final items = controller.featuredMedia;

//     if (items.isEmpty) {
//       return const Padding(
//         padding: EdgeInsets.all(20),
//         child: Center(child: Text("No featured media yet")),
//       );
//     }

//     return SizedBox(
//       height: 260,
//       child: ListView.separated(
//         scrollDirection: Axis.horizontal,
//         itemCount: items.length,
//         separatorBuilder: (_, __) => const SizedBox(width: 16),
//         itemBuilder: (_, index) {
//           return MediaCard(item: items[index]);
//         },
//       ),
//     );
//   });
// }
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../media_card/media_card.dart';
import '../media_market_controller/media_market_controller.dart';

Widget buildFeaturedList() {
  final controller = Get.find<MediaController>();

  return Obx(() {
    final items = controller.featuredMedia;
    if (items.isEmpty)
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: Text("No featured media yet")),
      );

    return SizedBox(
      height: 260,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (_, index) => Padding(
          padding: const EdgeInsets.only(right: 16),
          child: MediaCard(item: items[index]),
        ),
      ),
    );
  });
}
