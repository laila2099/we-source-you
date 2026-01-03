import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:we_source_you/core/constant/app_color.dart';
import 'package:we_source_you/core/constant/responsive_layout.dart';
import 'package:we_source_you/core/constant/text_style.dart';
import 'package:we_source_you/routes/app_routes.dart';
import 'package:we_source_you/view/auth/sign_in/sign_in_controller/sign_in_controller.dart';
import 'package:we_source_you/widgets/custom_buttom/custom_buttom.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final controller = Get.put(SignInController());
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Sync initial values if they exist
    emailController.text = controller.email.value;
    passwordController.text = controller.password.value;

    // Listen to controller changes and update text fields
    emailController.addListener(() {
      if (emailController.text != controller.email.value) {
        controller.email.value = emailController.text;
      }
    });

    passwordController.addListener(() {
      if (passwordController.text != controller.password.value) {
        controller.password.value = passwordController.text;
      }
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: ResponsiveLayout.screenPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Back
          IconButton(
            iconSize: 18,
            color: theme.textTheme.bodySmall?.color,
            onPressed: controller.goBack,
            icon: const Icon(Icons.arrow_back),
          ),
          const SizedBox(height: 30),

          RichText(
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
          ),
          const Text(
            'Media Talent',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 10),

          Text(
            'welcome'.tr,
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          const Text(
            'Sign in to your account',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 30),

          // Google
          // OutlinedButton.icon(
          //   onPressed: () {},
          //   icon: Text('G', style: Theme.of(context).textTheme.labelLarge),
          //   label: Text(
          //     'Continue with Google',
          //     style: Theme.of(context).textTheme.labelLarge,
          //   ),
          //   style: OutlinedButton.styleFrom(
          //     minimumSize: Size(double.infinity, 50.h),
          //     foregroundColor: Colors.black,
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(4.r),
          //     ),
          //   ),
          // ),
          const SizedBox(height: 20),

          // OR
          Row(
            children: <Widget>[
              const Expanded(child: Divider(color: Colors.grey)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text('or', style: TextStyle(color: Colors.grey[600])),
              ),
              const Expanded(child: Divider(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 20),

          // Email
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email Address',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide: BorderSide(color: Theme.of(context).primaryColor),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 16,
              ),
            ),
            onChanged: (value) {
              controller.email.value = value;
            },
          ),
          const SizedBox(height: 20),

          // Password
          TextField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide: BorderSide(color: Theme.of(context).primaryColor),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 16,
              ),
            ),
            onChanged: (value) {
              controller.password.value = value;
            },
          ),
          const SizedBox(height: 10),

          // Remember + Forgot
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Obx(
                () => Row(
                  children: [
                    Checkbox(
                      value: controller.rememberMe.value,
                      onChanged: (v) => controller.toggleRememberMe(v ?? false),
                      activeColor: AppColors.darkBlue,
                    ),
                    const Text('Remember Me', style: TextStyle(fontSize: 13)),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(color: AppColors.darkBlue, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),

          // Sign In Button
          Center(
            child: Obx(
              () => controller.isLoading.value
                  ? SizedBox(
                      width: 300.w,
                      height: 52.h,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.darkBlue,
                        ),
                      ),
                    )
                  : WebHoverButton(
                      text: "Sign in",
                      onPressed: controller.isLoading.value
                          ? () {}
                          : controller.signIn,
                      width: 300.w,
                    ),
            ),
          ),

          const SizedBox(height: 30),

          // Sign Up
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Don't have an account? "),
              TextButton(
                onPressed: () => Get.toNamed(AppRoutes.signup),
                child: const Text(
                  'Sign Up',
                  style: TextStyle(
                    color: AppColors.darkBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
