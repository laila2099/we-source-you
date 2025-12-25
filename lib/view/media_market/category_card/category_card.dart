import 'package:flutter/material.dart';
import 'package:we_source_you/model/category_item.dart';

class CategoryCard extends StatelessWidget {
  final CategoryItem item;

  const CategoryCard({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Stack(
        children: [
          // Text Label
          Positioned(
            left: 16,
            top: 0,
            bottom: 0,
            child: Center(
              child: Text(
                item.name,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          // Icon Circle (Clipped to right)
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
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Icon(
                  item.icon,
                  color: Colors.white.withOpacity(0.8),
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
