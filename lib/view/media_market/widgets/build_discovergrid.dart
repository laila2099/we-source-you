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
