import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:we_source_you/core/constant/app_color.dart';
import 'package:we_source_you/routes/app_routes.dart';
import 'package:we_source_you/view/auth/auth_controller/auth_controller.dart';
import 'package:we_source_you/widgets/circular_icon/circular_icon.dart';
import 'package:we_source_you/widgets/glass_morphism.dart';

class userAvatarMenu extends StatelessWidget {
  final bool isDesktop;
  final AuthController authController;

  const userAvatarMenu({
    super.key,
    required this.isDesktop,
    required this.authController,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final displayName = authController.accountType.value == 'company'
          ? authController.companyName.value
          : authController.fullName.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          InkWell(
            onTap: () => _showMenu(context),
            child: isDesktop
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      displayName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  )
                : CircularIcon(
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
                  ),
          ),
        ],
      );
    });
  }

  void _showMenu(BuildContext context) {
    final overlay = Overlay.of(context)!;
    final box = context.findRenderObject() as RenderBox;
    final position = box.localToGlobal(Offset.zero);

    OverlayEntry? entry;
    entry = OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: () {
          entry?.remove();
        },
        child: Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              Positioned(
                top: position.dy + box.size.height + 8,
                right: 16,
                child: GlassContainer(
                  width: 220,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _item(
                        'Profile',
                        () => Get.toNamed(AppRoutes.profile),
                        entry,
                      ),
                      _item(
                        'My Library',
                        () => Get.toNamed(AppRoutes.myLibrary),
                        entry,
                      ),
                      _item('Inbox', () => Get.toNamed(AppRoutes.inbox), entry),
                      _item(
                        'Payout Settings',
                        () => Get.toNamed(AppRoutes.payoutSettings),
                        entry,
                      ),
                      const Divider(color: Colors.white24),
                      _item('Logout', () {
                        authController.logout();
                        Get.offAllNamed(AppRoutes.home);
                      }, entry),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    overlay.insert(entry);
  }

  Widget _item(String title, VoidCallback onTap, OverlayEntry? entry) {
    return InkWell(
      onTap: () {
        entry?.remove(); // Close overlay
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
