import 'package:flutter/material.dart';

Widget buildHeader(BuildContext context) {
  final theme = Theme.of(context);

  return Center(
    child: Column(
      children: [
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              fontFamily: 'Arial',
            ),
            children: [
              TextSpan(text: "Make it ", style: theme.textTheme.displaySmall),
              const TextSpan(
                text: "real.",
                style: TextStyle(color: Color(0xFFFF4081)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Handpicked services from our best freelancers.",
          style: TextStyle(color: Colors.grey[400], fontSize: 14),
        ),
      ],
    ),
  );
}
