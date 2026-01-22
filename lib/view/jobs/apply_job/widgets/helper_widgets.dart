import 'package:flutter/material.dart';

String formatDate(DateTime? d) =>
    d == null ? "" : "${d.day}/${d.month}/${d.year}";

Widget statusBadgeFromDate(DateTime? createdAt, Color color) {
  return Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      timeAgo(createdAt),
      style: TextStyle(color: color, fontWeight: FontWeight.bold),
    ),
  );
}

String timeAgo(DateTime? date) {
  if (date == null) return '';

  final diff = DateTime.now().difference(date);

  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) return '${diff.inHours} h ago';
  if (diff.inDays < 7) return '${diff.inDays} d ago';

  return '${date.day}/${date.month}/${date.year}';
}

BoxDecoration cardDecoration(Color color) =>
    BoxDecoration(color: color, borderRadius: BorderRadius.circular(15));

Widget errorScaffold(String msg) => Scaffold(
  appBar: AppBar(title: const Text("Job Details")),
  body: Center(child: Text(msg)),
);

Widget loadingScaffold() =>
    const Scaffold(body: Center(child: CircularProgressIndicator()));

Widget warningBox(String text, String button, VoidCallback onTap) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: cardDecoration(Colors.orange.shade50),
    child: Column(
      children: [
        Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ElevatedButton(onPressed: onTap, child: Text(button)),
      ],
    ),
  );
}

Widget infoBox(String text) => Container(
  padding: const EdgeInsets.all(20),
  decoration: cardDecoration(Colors.grey.shade200),
  child: Center(child: Text(text)),
);
