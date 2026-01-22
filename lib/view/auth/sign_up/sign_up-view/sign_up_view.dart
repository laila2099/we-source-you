import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:we_source_you/core/constant/responsive_layout.dart';
import 'package:we_source_you/view/auth/sign_up/sign_up_controller/sign_up_controller.dart';
import 'package:we_source_you/view/auth/widgets/right_side.dart';
import 'package:we_source_you/view/auth/widgets/signup_form.dart';
import 'package:we_source_you/core/constant/app_color.dart';

class SignUpView extends StatelessWidget {
  SignUpView({super.key});

  final controller = Get.put(SignUpController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.lightBlue, AppColors.darkBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ResponsiveLayout(
          mobile: _buildMobile(context),
          tablet: _buildTablet(context),
          desktop: _buildDesktop(context),
        ),
      ),
    );
  }

  /// ---------------- MOBILE ----------------
  Widget _buildMobile(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: _cardDecoration(context),
        child: const SignUpForm(),
      ),
    );
  }

  /// ---------------- TABLET ----------------
  Widget _buildTablet(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 900),
        margin: const EdgeInsets.all(32),
        decoration: _cardDecoration(context),
        child: Row(
          children: const [
            Expanded(child: SignUpForm()),
            Expanded(child: WelcomePanel()),
          ],
        ),
      ),
    );
  }

  /// ---------------- DESKTOP ----------------
  Widget _buildDesktop(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1100),
        margin: const EdgeInsets.all(40),
        decoration: _cardDecoration(context),
        child: Row(
          children: const [
            Expanded(child: SignUpForm()),
            Expanded(child: WelcomePanel()),
          ],
        ),
      ),
    );
  }

  /// ---------------- CARD DECORATION ----------------
  BoxDecoration _cardDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BoxDecoration(
      color: isDark ? Colors.grey[900] : Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }
}
