import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:we_source_you/core/constant/app_color.dart';
import 'package:we_source_you/routes/app_routes.dart';
import 'package:we_source_you/view/auth/auth_controller/auth_controller.dart';
import 'package:we_source_you/widgets/circular_icon/circular_icon.dart';

Widget userAvatarMenu({
  required bool isDesktop,
  required AuthController authController,
}) {
  return PopupMenuButton<String>(
    offset: const Offset(0, 40),
    onSelected: (value) {
      if (value == 'Profile') {
        Get.toNamed(AppRoutes.profile);
      } else if (value == 'logout') {
        authController.logout();
        Get.offAllNamed(AppRoutes.home);
      }
    },
    itemBuilder: (context) => [
      const PopupMenuItem(value: 'Profile', child: Text('Profile')),
      const PopupMenuItem(value: 'logout', child: Text('Logout')),
    ],
    child: Obx(() {
      final userName = authController.fullName.value;
      if (isDesktop) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            userName,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        );
      } else {
        return CircularIcon(
          gradientColors: [AppColors.lightBlue, AppColors.darkBlue],
          child: Center(
            child: Text(
              authController.avatarLetter,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }
    }),
  );
}
