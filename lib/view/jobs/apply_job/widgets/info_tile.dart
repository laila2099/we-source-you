import 'package:flutter/material.dart';
import 'package:we_source_you/view/jobs/apply_job/widgets/list_tile.dart';

Widget infoTile(String title, String value) {
  return glassTile(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(color: Colors.white)),
      ],
    ),
  );
}
