import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      // onSelected: (value) {
      //   if (value == "ar") {
      //     Get.updateLocale(const Locale("ar"));
      //   } else {
      //     Get.updateLocale(const Locale("en"));
      //   }
      // },
      onSelected: (value) {
        Locale locale = Locale(value);
        Get.updateLocale(
          locale,
        ); // هذا السطر يخبر GetX بتغيير اللغة واتجاه الواجهة فوراً
      },
      itemBuilder: (context) => const [
        PopupMenuItem(value: "ar", child: Text("العربية")),
        PopupMenuItem(value: "en", child: Text("English")),
      ],
      child: Row(
        children: [
          const Icon(Icons.language, size: 20),
          const Icon(Icons.arrow_drop_down_rounded, size: 20),
          const SizedBox(width: 6),
        ],
      ),
    );
  }
}
