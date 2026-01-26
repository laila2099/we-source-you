import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:we_source_you/view/auth/auth_controller/auth_controller.dart';
import 'package:we_source_you/view/home/home_controller/home_controller.dart';
import 'package:we_source_you/widgets/glass_morphism.dart';

Widget buildMenu(BuildContext context) {
  final HomeController controller = Get.find<HomeController>();
  final AuthController authController = Get.find<AuthController>();
  final isLoggedIn = authController.isLoggedIn.value;

  final titles = isLoggedIn
      ? ["Home", "Jobs", "Our Team", "Media Market"]
      : ["Home", "Sign Up", "Sign In", "Jobs", "Our Team", "Media Market"];

  return SlideTransition(
    position: controller.menuSlide,
    child: GlassContainer(
      width: 220,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(titles.length, (i) {
          return FadeTransition(
            opacity: controller.itemFades[i],
            child: SlideTransition(
              position: controller.itemSlides[i],
              child: glassMenuItem(titles[i], controller, context),
            ),
          );
        }),
      ),
    ),
  );
}

Widget glassMenuItem(
  String title,
  HomeController controller,
  BuildContext context,
) {
  return InkWell(
    onTap: () => controller.navigateToSection(context, title),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  );
}
