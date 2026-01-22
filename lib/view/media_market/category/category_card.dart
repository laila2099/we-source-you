import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:we_source_you/model/category_item.dart';
import 'package:we_source_you/view/media_market/category/category_page.dart';
import 'package:we_source_you/view/media_market/media_market_controller/media_market_controller.dart';

class CategoryCard extends StatelessWidget {
  final CategoryItem item;

  const CategoryCard({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: () {
        final controller = Get.find<MediaController>();

        controller.loadMediaByCategory(item.name);

        Get.to(() => CategoryMediaPage(category: item.name));
      },

      child: Container(
        width: 180,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: Text(
                  item.name.capitalizeFirst ?? item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 5,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        item.accentColor.withOpacity(0.6),
                        item.accentColor,
                      ],
                    ),
                  ),
                  child: Icon(item.icon, color: Colors.white.withOpacity(0.8)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
