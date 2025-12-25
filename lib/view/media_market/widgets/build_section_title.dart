import 'package:flutter/material.dart';
import 'package:we_source_you/core/constant/text_style.dart';

Widget buildSectionTitle(String title, BuildContext context) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Text(
      title,
      style: AppTextStyles.h4().copyWith(
        color: Theme.of(context).textTheme.headlineMedium!.color,
      ),
    ),
  );
}
