// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:task1_adv/core/constans/app_images.dart';
// import 'package:task1_adv/view/auth/login/login_controller/login_controller.dart';
// import 'package:task1_adv/widgets/general/custom_button/custom_button.dart';
// import 'package:task1_adv/widgets/general/text_form_field/custom_text_form.dart';
// import 'package:task1_adv/widgets/general/text_form_field/custom_textf_controller.dart';
// import 'package:task1_adv/widgets/helpful/buttom_sheet.dart';

// class LoginScreen extends GetView<LoginController> {
//   LoginScreen({super.key});

//   bool isValidEmail(String input) {
//     final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
//     return emailRegex.hasMatch(input);
//   }

//   void showChangePasswordSheet(BuildContext context) {
//     final newPasswordController = CustomTextFormFieldController();
//     final confirmPasswordController = CustomTextFormFieldController();
//     final _formKeySheet = GlobalKey<FormState>();

//     SuccessBottomSheet.show(
//       context,
//       child: Form(
//         key: _formKeySheet,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               "Create New Password",
//               style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 10.h),
//             Text(
//               "Enter your new password below",
//               style: TextStyle(fontSize: 10.sp, color: Colors.grey),
//             ),
//             SizedBox(height: 10.h),
//             CustomTextFormField(
//               hint: "New Password",
//               text: "Password",
//               icon: Icons.lock_outline,
//               controller: newPasswordController,
//               isPassword: true,
//               validator: (value) {
//                 if (value == null || value.isEmpty)
//                   return "This field is required";
//                 final passwordRegex = RegExp(
//                   r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$',
//                 );
//                 if (!passwordRegex.hasMatch(value))
//                   return "Password must be at least 6 characters and include letters and numbers";
//                 return null;
//               },
//             ),
//             SizedBox(height: 16.h),
//             CustomTextFormField(
//               hint: "Confirm Password",
//               text: "Confirm Password",
//               icon: Icons.lock_outline,
//               controller: confirmPasswordController,
//               isPassword: true,
//               validator: (value) {
//                 if (value == null || value.isEmpty)
//                   return "This field is required";
//                 if (value != newPasswordController.text)
//                   return "Passwords do not match";
//                 return null;
//               },
//             ),
//             SizedBox(height: 24.h),
//             Center(
//               child: CustomButton(
//                 text: 'Change Password',
//                 onPressed: () async {
//                   if (!_formKeySheet.currentState!.validate()) return;

//                   final success = await controller.changePassword(
//                     newPasswordController.text.trim(),
//                   );
//                   if (success) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                         content: Text("Password changed successfully"),
//                       ),
//                     );
//                     Navigator.pop(context);
//                   } else {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(
//                         content: Text(controller.errorMessage.value ?? "Error"),
//                       ),
//                     );
//                   }
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Padding(
//           padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 25.h),
//           child: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   "Login Account",
//                   style: TextStyle(
//                     fontSize: 24.sp,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 SizedBox(height: 5.h),
//                 const Text(
//                   "Please login with registered account",
//                   style: TextStyle(color: Colors.grey),
//                 ),
//                 SizedBox(height: 40.h),
//                 CustomTextFormField(
//                   hint: "Enter your email",
//                   text: "Email",
//                   icon: Icons.email_outlined,
//                   controller: controller.emailController,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return "This field is required";
//                     } else if (!isValidEmail(value)) {
//                       return "Enter only a valid email";
//                     }
//                     return null;
//                   },
//                 ),
//                 SizedBox(height: 20.h),
//                 CustomTextFormField(
//                   hint: "Enter your password",
//                   text: "Password",
//                   icon: Icons.lock_outline,
//                   controller: controller.passwordController,
//                   isPassword: true,
//                   validator: (value) => (value == null || value.isEmpty)
//                       ? "This field is required"
//                       : null,
//                 ),
//                 Align(
//                   alignment: Alignment.topRight,
//                   child: TextButton(
//                     onPressed: () => showChangePasswordSheet(context),
//                     child: const Text("Forgot Password?"),
//                   ),
//                 ),
//                 SizedBox(height: 45.h),
//                 Center(
//                   child: Column(
//                     children: [
//                       Obx(
//                         () => controller.isLoading.value
//                             ? const CircularProgressIndicator()
//                             : CustomButton(
//                                 text: "Sign In",
//                                 onPressed: () async {
//                                   final success = await controller.login();
//                                   if (success) {
//                                     Navigator.pushReplacementNamed(
//                                       context,
//                                       '/home',
//                                     );
//                                   } else {
//                                     final message =
//                                         controller.errorMessage.value;
//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                       SnackBar(
//                                         content: Text(
//                                           message == null || message.isEmpty
//                                               ? 'Login failed'
//                                               : message,
//                                         ),
//                                       ),
//                                     );
//                                   }
//                                 },
//                               ),
//                       ),
//                       SizedBox(height: 24.h),
//                       Text(
//                         "Or using other method",
//                         style: TextStyle(
//                           color: Colors.grey,
//                           fontWeight: FontWeight.normal,
//                         ),
//                       ),
//                       SizedBox(height: 24.h),

//                       CustomButton(
//                         text: "Sign Up with Google",
//                         onPressed: () {},
//                         color: Colors.white,
//                         textColor: Colors.black,
//                         borderColor: Colors.grey,
//                         borderWidth: 1,
//                         icon: Image.asset(
//                           AppImages.google,
//                           width: 24.w,
//                           height: 24.h,
//                         ),
//                       ),

//                       SizedBox(height: 15.h),
//                       CustomButton(
//                         text: "Sign Up with Facebook",
//                         onPressed: () {},
//                         color: Colors.white,
//                         textColor: Colors.black,
//                         borderColor: Colors.grey,
//                         borderWidth: 1,
//                         icon: Image.asset(
//                           AppImages.facebook,
//                           width: 24.w,
//                           height: 24.h,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:we_source_you/core/constant/app_color.dart';
// import 'package:we_source_you/view/auth/sign_in/widgets/sign_in_form.dart';
// import 'package:we_source_you/view/auth/widgets/right_side.dart';

// class SignInView extends StatelessWidget {
//   const SignInView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
// width: double.infinity,
// height: double.infinity,
// decoration: const BoxDecoration(
//   gradient: LinearGradient(
//     colors: [AppColors.lightBlue, AppColors.darkBlue],
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//   ),
// ),
//         child: Center(
//           child: Container(
//             // Constrain the overall width of the content container for large screens
//             constraints: const BoxConstraints(maxWidth: 1000),
//             margin: const EdgeInsets.all(40),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.1),
//                   blurRadius: 20,
//                   offset: const Offset(0, 10),
//                 ),
//               ],
//             ),
//             child: Row(
//               children: <Widget>[
//                 // Left Side: Login Form (Occupies 50% on wider screens)
//                 const Expanded(flex: 1, child: LoginForm()),

//                 // Right Side: Welcome/Info Section (Hidden on small screens)
//                 if (MediaQuery.of(context).size.width > 700)
//                   const Expanded(flex: 1, child: WelcomePanel()),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:we_source_you/core/constant/app_color.dart';
import 'package:we_source_you/core/constant/responsive_layout.dart';
import 'package:we_source_you/view/auth/sign_in/widgets/sign_in_form.dart';
import 'package:we_source_you/view/auth/widgets/right_side.dart';

class SignInView extends StatelessWidget {
  SignInView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: LoginForm(),
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
          children: [
            Expanded(child: LoginForm()),
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
          children: [
            Expanded(child: LoginForm()),
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
