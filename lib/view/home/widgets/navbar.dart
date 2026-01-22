import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:we_source_you/routes/app_routes.dart';
import 'package:we_source_you/view/auth/auth_controller/auth_controller.dart';
import 'package:we_source_you/view/home/home_controller/home_controller.dart';
import 'package:we_source_you/view/home/widgets/language_switch.dart';
import 'package:we_source_you/view/home/widgets/logo.dart';
import 'package:we_source_you/view/home/widgets/nav_button.dart';
import 'package:we_source_you/view/home/widgets/user_menu.dart';

Widget buildNavbar(bool isDesktop, BuildContext context) {
  final HomeController controller = Get.find<HomeController>();
  final AuthController authController = Get.find<AuthController>();
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    color: Colors.transparent,
    child: Row(
      children: [
        logo(context),
        SizedBox(width: 10.w),

        if (isDesktop) ...[
          TextButton(
            onPressed: () => Get.toNamed(AppRoutes.team),
            child: Text(
              "Our Team",
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          TextButton(
            onPressed: () => Get.toNamed(AppRoutes.jobs),
            child: Text("Jobs", style: Theme.of(context).textTheme.titleMedium),
          ),
          TextButton(
            onPressed: () => Get.toNamed(AppRoutes.media),
            child: Text(
              "Media Market",
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],

        Spacer(),

        if (isDesktop)
          Row(
            children: [
              navButton("Home", context, controller: controller),
              Obx(() {
                if (!authController.isLoggedIn.value) {
                  return Row(
                    children: [
                      navButton("Sign Up", context, controller: controller),
                      navButton("Sign In", context, controller: controller),
                    ],
                  );
                } else {
                  // Desktop -> show username
                  return Row(
                    children: [
                      userAvatarMenu(
                        isDesktop: true,
                        authController: authController,
                      ),
                    ],
                  );
                }
              }),
              SizedBox(width: 3.w),
              const LanguageSwitcher(),
            ],
          )
        else
          Row(
            children: [
              Obx(() {
                if (authController.isLoggedIn.value) {
                  // Mobile/Tablet -> show circular avatar
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: userAvatarMenu(
                      isDesktop: false,
                      authController: authController,
                    ),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              }),
              IconButton(
                icon: const Icon(Icons.menu, size: 30),
                onPressed: controller.toggleMenu,
              ),
            ],
          ),
      ],
    ),
  );
}
