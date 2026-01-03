// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:we_source_you/view/media_market/category_card/category_card.dart';
// import 'package:we_source_you/view/media_market/media_market_controller/media_market_controller.dart';

// Widget buildCategoryGrid() {
//   final MediaController controller = Get.find();

//   return Obx(
//     () => Wrap(
//       spacing: 16,
//       runSpacing: 16,
//       children: controller.categories.map((category) {
//         return CategoryCard(item: category);
//       }).toList(),
//     ),
//   );
// }
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../category/category_card.dart';
import '../media_market_controller/media_market_controller.dart';

Widget buildCategoryGrid(MediaController controller) {
  return Obx(() {
    final cats = controller.categories;
    if (cats.isEmpty) return const SizedBox();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cats.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 2.2,
      ),
      itemBuilder: (context, index) => CategoryCard(item: cats[index]),
    );
  });
}
