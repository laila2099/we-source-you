import 'package:flutter/material.dart';

class StatisticItem {
  final String count;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;

  StatisticItem({
    required this.count,
    required this.description,
    required this.icon,
    required this.gradientColors,
  });
}
