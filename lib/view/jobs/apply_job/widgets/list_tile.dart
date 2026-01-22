import 'package:flutter/material.dart';
import 'package:we_source_you/view/jobs/apply_job/widgets/helper_widgets.dart';

Widget listTile(String title, List<String> items, IconData icon) {
  return glassTile(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(spacing: 6, runSpacing: 4, children: items.map(chip).toList()),
      ],
    ),
  );
}

Widget glassTile(Widget child) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: cardDecoration(Colors.white.withOpacity(0.15)),
    child: child,
  );
}

Widget chip(String text) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.3),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      style: const TextStyle(color: Colors.white, fontSize: 11),
    ),
  );
}
