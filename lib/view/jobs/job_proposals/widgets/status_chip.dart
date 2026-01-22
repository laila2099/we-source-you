import 'package:flutter/material.dart';

Widget statusChip(String status) {
  Color bg;
  Color text;

  switch (status) {
    case 'approved':
      bg = Colors.green.shade100;
      text = Colors.green.shade800;
      break;
    case 'rejected':
      bg = Colors.red.shade100;
      text = Colors.red.shade800;
      break;
    default:
      bg = Colors.orange.shade100;
      text = Colors.orange.shade800;
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      status.toUpperCase(),
      style: TextStyle(fontWeight: FontWeight.bold, color: text, fontSize: 12),
    ),
  );
}
