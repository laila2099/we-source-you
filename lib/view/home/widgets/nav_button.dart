import 'package:flutter/material.dart';
import 'package:we_source_you/view/home/home_controller/home_controller.dart';

Widget navButton(
  String title,
  BuildContext context, {
  required HomeController controller,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    child: InkWell(
      onTap: () => controller.navigateToSection(context, title),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    ),
  );
}
