import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:we_source_you/core/constant/responsive_layout.dart';
import 'package:we_source_you/view/auth/auth_controller/auth_controller.dart';
import 'package:we_source_you/view/home/home_controller/home_controller.dart';
import 'package:we_source_you/view/home/widgets/build_menu.dart';
import 'package:we_source_you/view/home/widgets/herosection.dart';
import 'package:we_source_you/view/home/widgets/how_itworks.dart';
import 'package:we_source_you/view/home/widgets/image_sider.dart';
import 'package:we_source_you/view/home/widgets/navbar.dart';
import 'package:we_source_you/view/home/widgets/statistics.dart';
import 'package:we_source_you/view/jobs/jobs_controller/jobs_controller.dart';
import 'package:we_source_you/view/jobs/widget/jobs_card.dart';
import 'package:we_source_you/view/team/team_controller/team_controller.dart';
import 'package:we_source_you/view/team/widget/team_card.dart';
import 'package:we_source_you/widgets/app_footer/app_footer.dart';

class HomeView extends StatelessWidget {
  HomeView({super.key});

  final HomeController controller = Get.find<HomeController>();
  final AuthController authController = Get.find<AuthController>();
  final TeamController jourController = Get.find<TeamController>();
  final JobsController jobsController = Get.find<JobsController>();

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _buildMobile(context),
      tablet: _buildTablet(context),
      desktop: _buildDesktop(context),
    );
  }

  Widget _baseLayout(BuildContext context, {required bool isDesktop}) {
    return Scaffold(
      body: Stack(
        children: [
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
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: buildNavbar(isDesktop, context),
          ),

          if (!isDesktop)
            Positioned(
              top: 70,
              right: 24,
              child: Obx(() {
                return controller.isMenuOpen.value
                    ? buildMenu(context)
                    : const SizedBox.shrink();
              }),
            ),
        ],
      ),
    );
  }

  Widget _buildMobile(BuildContext ctx) {
    return _baseLayout(ctx, isDesktop: false);
  }

  Widget _buildTablet(BuildContext ctx) {
    return _baseLayout(ctx, isDesktop: false);
  }

  Widget _buildDesktop(BuildContext ctx) {
    return _baseLayout(ctx, isDesktop: true);
  }
}
