import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:we_source_you/view/media_market/media_card/media_card.dart';
import 'package:we_source_you/view/media_market/media_market_controller/media_market_controller.dart';

class CategoryMediaPage extends GetView<MediaController> {
  final String category;

  const CategoryMediaPage({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(category.capitalizeFirst ?? category)),
      body: Obx(() {
        if (controller.discoverMedia.isEmpty) {
          return const Center(child: Text("No media found for this category"));
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.75,
          ),
          itemCount: controller.discoverMedia.length,
          itemBuilder: (context, index) {
            final item = controller.discoverMedia[index];
            return MediaCard(item: item);
          },
        );
      }),
    );
  }
}
