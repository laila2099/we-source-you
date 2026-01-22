import 'package:flutter/material.dart';
import 'package:we_source_you/core/constant/text_style.dart';

Widget logo(BuildContext context) {
  return RichText(
    text: TextSpan(
      children: [
        TextSpan(text: "We", style: Theme.of(context).textTheme.headlineSmall),
        TextSpan(
          text: "Source",
          style: AppTextStyles.h3(context).copyWith(
            foreground: Paint()
              ..shader = const LinearGradient(
                colors: [Color(0xff7ab9e4), Color(0xff0c5596)],
              ).createShader(const Rect.fromLTWH(0, 0, 200, 50)),
          ),
        ),
        TextSpan(text: "You", style: Theme.of(context).textTheme.headlineSmall),
      ],
    ),
  );
}
