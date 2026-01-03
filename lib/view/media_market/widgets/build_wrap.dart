import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:we_source_you/view/media_market/media_market_controller/media_market_controller.dart';

final Color borderColor = const Color(0xFFE0E0E0);

Widget buildWrapOptions(
  MediaController controller,
  List<String> options,
  RxSet<String> selectedSet, {
  bool isMulti = true,
}) {
  return Wrap(
    spacing: 10,
    runSpacing: 10,
    children: options.map((option) {
      final bool isSelected = selectedSet.contains(option);

      return InkWell(
        onTap: () => controller.toggleFilter(selectedSet, option),
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: isSelected ? Colors.black : borderColor),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            option,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.black87,
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      );
    }).toList(),
  );
}
