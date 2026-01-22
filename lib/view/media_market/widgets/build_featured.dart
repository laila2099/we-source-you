import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../media_card/media_card.dart';
import '../media_market_controller/media_market_controller.dart';

Widget buildFeaturedList(MediaController controller) {
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
