import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:we_source_you/core/constant/app_images.dart';
import 'package:we_source_you/core/constant/responsive_layout.dart';
import 'package:we_source_you/model/how_itwork_model.dart';
import 'package:we_source_you/model/statistics_model.dart';
import 'dart:math';

import 'package:we_source_you/routes/app_routes.dart';
import 'package:we_source_you/view/auth/auth_controller/auth_controller.dart'; // FIX 1: Import dart:math for Random

class HomeController extends GetxController with GetTickerProviderStateMixin {
  final AuthController authController = Get.find<AuthController>();

  // --- EXISTING MENU PROPERTIES ---
  var isMenuOpen = false.obs;
  var stepsAnimationStarted = false.obs;
  late final AnimationController menuController;
  late final AnimationController itemsController;
  late final Animation<Offset> menuSlide;
  late final List<Animation<Offset>> itemSlides;
  late final List<Animation<double>> itemFades;

  // --- MEDIA LOGO ANIMATION PROPERTIES (FIXES) ---
  late AnimationController animationController;

  // FIX 2: Declare animationDuration
  final Duration animationDuration = const Duration(milliseconds: 1500);

  // FIX 3: Declare randomDelays
  late List<int> randomDelays;
  // --------------------------------------------------

  final List<String> logoAssets = [
    AppImages.aljazeera,
    AppImages.bbc,
    AppImages.associated,
    AppImages.cnn,
    AppImages.nyc,
    AppImages.reuters,
    AppImages.guardian,
    AppImages.washington,
  ];

  @override
  void onInit() {
    super.onInit();
    initAnimations();

    // Initialize AnimationController for Media Logos
    animationController = AnimationController(
      vsync: this,
      duration: animationDuration,
    );

    // Generate random delays for each logo (Uses Random from dart:math)
    final random = Random();
    randomDelays = List.generate(
      logoAssets.length,
      (index) =>
          random.nextInt(800) + 100, // Random delay between 100ms and 900ms
    );

    // Start the animation (as per your current logic)
    animationController.forward();
  }

  void initAnimations() {
    // MAIN MENU
    menuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    menuSlide = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: menuController, curve: Curves.easeInOut));

    // ITEMS STAGGER
    itemsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    itemSlides = List.generate(6, (i) {
      final start = i * 0.10;
      final end = start + 0.25;

      return Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: itemsController,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });

    itemFades = List.generate(6, (i) {
      final start = i * 0.10;
      final end = start + 0.25;

      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: itemsController,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });
  }

  Future<void> toggleMenu({bool? forceClose}) async {
    if (forceClose == true) {
      if (!isMenuOpen.value) return;
      await itemsController.reverse();
      await menuController.reverse();
      isMenuOpen.value = false;
      return;
    }

    if (isMenuOpen.value) {
      await itemsController.reverse();
      await menuController.reverse();
    } else {
      menuController.forward();
      await itemsController.forward();
    }

    isMenuOpen.value = !isMenuOpen.value;
  }

  @override
  void onClose() {
    menuController.dispose();
    itemsController.dispose();
    animationController.dispose(); // Dispose media logo controller
    super.onClose();
  }

  // NOTE: You'll need to re-add your imports for AppRoutes and ResponsiveLayout
  // if you plan to use them inside this method. I've commented out the original imports.
  void navigateToSection(BuildContext context, String title) {
    if (!ResponsiveLayout.isDesktop(context)) {
      toggleMenu();
    }

    switch (title) {
      case "Home":
        // Scroll to home section أو لا شيء
        break;

      case "Sign Up":
        Get.toNamed(AppRoutes.signup);
        // scroll
        break;

      case "Sign In":
        Get.toNamed(AppRoutes.signin);
        break;

      case "Jobs":
        Get.toNamed(AppRoutes.jobs);
        break;
      case "Our Team":
        Get.toNamed(AppRoutes.team);
        break;

      case "Media Market":
        Get.toNamed(AppRoutes.media);

        // scroll
        break;
      // case "Profile":
      //   Get.offAllNamed(AppRoutes.profile);
      //   break;
      case "Logout":
        authController.logout();
        Get.offAllNamed(AppRoutes.home);
        break;

      default:
        break;
    }
  }

  static const Color pinkStart = Color(0xFFE94057);
  static const Color pinkEnd = Color(0xFFF27121);
  static const Color blueStart = Color(0xFF43C6AC);
  static const Color blueEnd = Color(0xFF191654);
  static const Color purpleStart = Color(0xFFBA5370);
  static const Color purpleEnd = Color(0xFFF4E2D8);

  // List of statistic items
  final stats = <StatisticItem>[
    StatisticItem(
      count: '10,000+',
      description: 'stat1_desc',
      icon: Icons.group,
      gradientColors: [pinkStart, pinkEnd],
    ),
    StatisticItem(
      count: '150+',
      description: 'stat2_desc',
      icon: Icons.language,
      gradientColors: [blueStart, blueEnd],
    ),
    StatisticItem(
      count: '4.9/5',
      description: 'stat3_desc',
      icon: Icons.star_half,
      gradientColors: [purpleStart, purpleEnd],
    ),
    StatisticItem(
      count: '5,000+',
      description: 'stat4_desc',
      icon: Icons.business_center,
      gradientColors: [pinkStart, pinkEnd],
    ),
    StatisticItem(
      count: '24/7',
      description: 'stat5_desc',
      icon: Icons.watch_later,
      gradientColors: [blueStart, blueEnd],
    ),
    StatisticItem(
      count: '98%',
      description: 'stat6_desc',
      icon: Icons.done_all,
      gradientColors: [purpleStart, purpleEnd],
    ),
  ].obs;

  final List<HowItWorksStep> steps = [
    HowItWorksStep(
      stepNumber: 1,
      title: 'howitworks_step1_title',
      icon: Icons.group,
      description: 'howitworks_step1_desc',
      checklist: [
        'howitworks_step1_item1',
        'howitworks_step1_item2',
        'howitworks_step1_item3',
        'howitworks_step1_item4',
      ],
    ),
    HowItWorksStep(
      stepNumber: 2,
      title: 'howitworks_step2_title',
      icon: Icons.search,
      description: 'howitworks_step2_desc',
      checklist: [
        'howitworks_step2_item1',
        'howitworks_step2_item2',
        'howitworks_step2_item3',
        'howitworks_step2_item4',
      ],
    ),
    HowItWorksStep(
      stepNumber: 3,
      title: 'howitworks_step3_title',
      icon: Icons.people,
      description: 'howitworks_step3_desc',
      checklist: [
        'howitworks_step3_item1',
        'howitworks_step3_item2',
        'howitworks_step3_item3',
        'howitworks_step3_item4',
      ],
    ),
    HowItWorksStep(
      stepNumber: 4,
      title: 'howitworks_step4_title',
      icon: Icons.check_circle_outline,
      description: 'howitworks_step4_desc',
      checklist: [
        'howitworks_step4_item1',
        'howitworks_step4_item2',
        'howitworks_step4_item3',
        'howitworks_step4_item4',
      ],
    ),
  ].obs;
}
