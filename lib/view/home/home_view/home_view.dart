import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:we_source_you/core/constant/app_color.dart';
import 'package:we_source_you/core/constant/responsive_layout.dart';
import 'package:we_source_you/core/constant/text_style.dart';
import 'package:we_source_you/routes/app_routes.dart';
import 'package:we_source_you/view/auth/auth_controller/auth_controller.dart';
import 'package:we_source_you/view/home/home_controller/home_controller.dart';
import 'package:we_source_you/view/home/widgets/nav_drop.dart';
import 'package:we_source_you/view/home/widgets/herosection.dart';
import 'package:we_source_you/view/home/widgets/how_itworks.dart';
import 'package:we_source_you/view/home/widgets/image_sider.dart';
import 'package:we_source_you/view/jobs/widget/jobs_card.dart';
import 'package:we_source_you/view/jobs/jobs_controller/jobs_controller.dart';
import 'package:we_source_you/view/team/team_controller/team_controller.dart';
import 'package:we_source_you/view/team/widget/team_card.dart';
import 'package:we_source_you/view/home/widgets/statistics.dart';
import 'package:we_source_you/view/media_market/binding/media_binding.dart';
import 'package:we_source_you/view/media_market/media_market_view/media_market_view.dart';
// Removed unused import to avoid requiring MediaController before navigation
import 'package:we_source_you/widgets/app_footer/app_footer.dart';
import 'package:we_source_you/widgets/circular_icon/circular_icon.dart';
import 'package:we_source_you/widgets/glass_morphism.dart';

class HomeView extends StatelessWidget {
  HomeView({super.key});

  final HomeController controller = Get.find<HomeController>();
  final AuthController authController = Get.find<AuthController>();
  final TeamController jourController = Get.find<TeamController>();
  // Ensure JobsController is available for FeaturedJobsView.
  final JobsController jobsController = Get.put<JobsController>(
    JobsController(),
    permanent: false,
  );

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _buildMobile(context),
      tablet: _buildTablet(context),
      desktop: _buildDesktop(context),
    );
  }

  // ----------------------------------------------------------
  // ✅ Base Layout (يستخدمه كل الشاشات)
  // ----------------------------------------------------------
  Widget _baseLayout(BuildContext context, {required bool isDesktop}) {
    return Scaffold(
      body: Stack(
        children: [
          // MAIN CONTENT
          Padding(
            padding: const EdgeInsets.only(top: 70),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const AnimatedCarousel(),
                  const HeroSection(),
                  const StatsGridView(),
                  HowItWorksView(),
                  FeaturedteamlistsView(),
                  FeaturedJobsView(),
                  const AppFooter(),
                ],
              ),
            ),
          ),

          // NAVBAR
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: buildNavbar(isDesktop, context),
          ),

          // MOBILE + TABLET MENU
          if (!isDesktop)
            Positioned(
              top: 70,
              right: 24,
              child: Obx(() {
                return controller.isMenuOpen.value
                    ? _buildMenu()
                    : const SizedBox.shrink();
              }),
            ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // ✅ Mobile Layout
  // ----------------------------------------------------------
  Widget _buildMobile(BuildContext ctx) {
    return _baseLayout(ctx, isDesktop: false);
  }

  // ----------------------------------------------------------
  // ✅ Tablet Layout
  // ----------------------------------------------------------
  Widget _buildTablet(BuildContext ctx) {
    return _baseLayout(ctx, isDesktop: false);
  }

  // ----------------------------------------------------------
  // ✅ Desktop Layout
  // ----------------------------------------------------------
  Widget _buildDesktop(BuildContext ctx) {
    return _baseLayout(ctx, isDesktop: true);
  }

  // ----------------------------------------------------------
  // ✅ Mobile Menu (animation جاهزة عندك)
  // ----------------------------------------------------------
  Widget _buildMenu() {
    final isLoggedIn = authController.isLoggedIn.value;

    final titles = isLoggedIn
        ? ["Home", "Jobs", "Our Team", "Logout", "Media Market"]
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
                child: glassMenuItem(titles[i]),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // ✅ NAVBAR
  // ----------------------------------------------------------
  Widget buildNavbar(bool isDesktop, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: Colors.transparent,
      child: Row(
        children: [
          _logo(context),
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
              child: Text(
                "Jobs",
                style: Theme.of(context).textTheme.titleMedium,
              ),
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
                navButton("Home", context),
                Obx(() {
                  if (!authController.isLoggedIn.value) {
                    return Row(
                      children: [
                        navButton("Sign Up", context),
                        navButton("Sign In", context),
                      ],
                    );
                  } else {
                    // Desktop -> show username
                    return Row(children: [_userAvatarMenu(isDesktop: true)]);
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
                      child: _userAvatarMenu(isDesktop: false),
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

  // ----------------------------------------------------------
  // ✅ LOGO
  // ----------------------------------------------------------
  Widget _logo(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: "We",
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          TextSpan(
            text: "Source",
            style: AppTextStyles.h3(context).copyWith(
              foreground: Paint()
                ..shader = const LinearGradient(
                  colors: [Color(0xff7ab9e4), Color(0xff0c5596)],
                ).createShader(const Rect.fromLTWH(0, 0, 200, 50)),
            ),
          ),
          TextSpan(
            text: "You",
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // ✅ NAV BUTTON
  // ----------------------------------------------------------
  Widget navButton(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: InkWell(
        onTap: () => controller.navigateToSection(Get.context!, title),
        child: Text(title, style: Theme.of(context).textTheme.titleMedium),
      ),
    );
  }

  // ----------------------------------------------------------
  // ✅ GLASS MENU ITEM
  // ----------------------------------------------------------
  Widget glassMenuItem(String title) {
    return InkWell(
      onTap: () => controller.navigateToSection(Get.context!, title),
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

  // ----------------------------------------------------------
  // ✅ USER AVATAR MENU
  // ----------------------------------------------------------
  Widget _userAvatarMenu({required bool isDesktop}) {
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
        // Get username or first letter for avatar
        final userName =
            authController.fullName.value; // افترض أنه موجود في authController
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
          // Mobile/Tablet avatar
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
}

// CircleAvatar(
//   radius: 18,
//   backgroundColor: AppColors.lightBlue,
// child: Obx(() {
//   return Text(
//     authController.avatarLetter,
//     style: const TextStyle(
//       color: Colors.white,
//       fontWeight: FontWeight.bold,
//     ),
//   );
// }),
// ),
class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == "ar") {
          Get.updateLocale(const Locale("ar"));
        } else {
          Get.updateLocale(const Locale("en"));
        }
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
