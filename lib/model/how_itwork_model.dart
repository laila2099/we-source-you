import 'package:flutter/material.dart';

class HowItWorksStep {
  final int stepNumber;
  final String title;
  final IconData icon;
  final String description;
  final List<String> checklist;

  HowItWorksStep({
    required this.stepNumber,
    required this.title,
    required this.icon,
    required this.description,
    required this.checklist,
  });
}
