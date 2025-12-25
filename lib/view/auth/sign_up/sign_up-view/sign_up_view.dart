// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:get/get.dart';
// import 'package:task1_adv/core/constans/app_colors.dart';
// import 'package:task1_adv/core/constans/app_images.dart';
// import 'package:task1_adv/routes/app_routes.dart';
// import 'package:task1_adv/view/auth/register/register_controller/register_controller.dart';
// import 'package:task1_adv/widgets/general/custom_button/custom_button.dart';
// import 'package:task1_adv/widgets/general/text_form_field/custom_text_form.dart';
// import 'package:we_source_you/auth/sign_up/sign_up_controller/sign_up_controller.dart';

// class SignUpView extends GetView<SignUpController> {
//   SignUpView({super.key});

//   final _formKey = GlobalKey<FormState>();

//   final RxString? emailError = ''.obs;
//   final RxString? passwordError = ''.obs;

//   final Rx<File?> storeLicenseImage = Rx<File?>(null);

//   Future<void> pickImage() async {
//     final picker = ImagePicker();
//     final XFile? image = await showModalBottomSheet<XFile?>(
//       context: Get.context!,
//       builder: (_) => SafeArea(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ListTile(
//               leading: const Icon(Icons.camera_alt),
//               title: const Text('Camera'),
//               onTap: () async {
//                 final img = await picker.pickImage(source: ImageSource.camera);
//                 Get.back(result: img);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.photo_library),
//               title: const Text('Gallery'),
//               onTap: () async {
//                 final img = await picker.pickImage(source: ImageSource.gallery);
//                 Get.back(result: img);
//               },
//             ),
//           ],
//         ),
//       ),
//     );

//     if (image != null) {
//       storeLicenseImage.value = File(image.path);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       extendBodyBehindAppBar: true,
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Padding(
//           padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 25.h),
//           child: SingleChildScrollView(
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     "Create Account",
//                     style: TextStyle(
//                       fontSize: 24.sp,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   SizedBox(height: 5.h),
//                   Text(
//                     "Start learning with create your account",
//                     style: TextStyle(color: Colors.grey),
//                   ),
//                   SizedBox(height: 40.h),

//                   Center(
//                     child: Obx(
//                       () => GestureDetector(
//                         onTap: pickImage,
//                         child: Stack(
//                           alignment: Alignment.bottomRight,
//                           children: [
//                             CircleAvatar(
//                               radius: 50.r,
//                               backgroundImage: storeLicenseImage.value != null
//                                   ? FileImage(storeLicenseImage.value!)
//                                   : null,
//                               child: storeLicenseImage.value == null
//                                   ? const Icon(
//                                       Icons.store,
//                                       size: 50,
//                                       color: Colors.grey,
//                                     )
//                                   : null,
//                             ),
//                             CircleAvatar(
//                               radius: 15.r,
//                               backgroundColor: ColorsApp.purple,
//                               child: const Icon(
//                                 Icons.add,
//                                 size: 20,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 30.h),

//                   CustomTextFormField(
//                     hint: "create your username",
//                     text: "Username",
//                     icon: Icons.person_outline,
//                     controller: controller.usernameController,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return "This field is required";
//                       }
//                       return null;
//                     },
//                   ),
//                   SizedBox(height: 20.h),

//                   Obx(
//                     () => CustomTextFormField(
//                       hint: "enter your email or phone number",
//                       text: "Email or Phone Number",
//                       icon: Icons.email_outlined,
//                       controller: controller.emailOrPhoneController,
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return "This field is required";
//                         }
//                         return null;
//                       },
//                       errorText: emailError!.value.isEmpty
//                           ? null
//                           : emailError!.value,
//                     ),
//                   ),
//                   SizedBox(height: 20.h),

//                   Obx(
//                     () => CustomTextFormField(
//                       hint: "create your password",
//                       text: "Password",
//                       icon: Icons.lock_outline,
//                       controller: controller.passwordController,
//                       isPassword: true,
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return "This field is required";
//                         }
//                         final passwordRegex = RegExp(
//                           r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$',
//                         );
//                         if (!passwordRegex.hasMatch(value)) {
//                           return "Password must be at least 6 characters and include letters and numbers";
//                         }
//                         return null;
//                       },
//                       errorText: passwordError!.value.isEmpty
//                           ? null
//                           : passwordError!.value,
//                     ),
//                   ),
//                   SizedBox(height: 20.h),

//                   CustomTextFormField(
//                     hint: "Commercial Name",
//                     text: "Commercial Name",
//                     icon: Icons.business,
//                     controller: controller.commercialNameController,
//                   ),
//                   SizedBox(height: 20.h),
//                   CustomTextFormField(
//                     hint: "Commercial Account",
//                     text: "Commercial Account",
//                     icon: Icons.account_balance_wallet_outlined,
//                     controller: controller.commercialAccountController,
//                   ),
//                   SizedBox(height: 40.h),

//                   Center(
//                     child: Column(
//                       children: [
//                         CustomButton(
//                           text: "Create Account",
//                           onPressed: () {
//                             controller.handleCreateAccount(
//                               username: controller.usernameController.text
//                                   .trim(),
//                               input: controller.emailOrPhoneController.text
//                                   .trim(),
//                               password: controller.passwordController.text
//                                   .trim(),
//                               commercialName: controller
//                                   .commercialNameController
//                                   .text
//                                   .trim(),
//                               commercialAccount: controller
//                                   .commercialAccountController
//                                   .text
//                                   .trim(),
//                               storeLicensePath: storeLicenseImage.value?.path,
//                               formKey: _formKey,
//                               onError: (emailErr, passErr) {
//                                 emailError!.value = emailErr ?? '';
//                                 passwordError!.value = passErr ?? '';
//                               },
//                             );
//                           },
//                         ),
//                         SizedBox(height: 27.h),
//                         Text(
//                           "Or using other method",
//                           style: TextStyle(
//                             color: Colors.grey,
//                             fontWeight: FontWeight.normal,
//                           ),
//                         ),
//                         SizedBox(height: 24.h),
//                         MaterialButton(
//                           height: 56.h,
//                           elevation: 0,
//                           minWidth: 325.w,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(45.r),
//                             side: BorderSide(
//                               color: ColorsApp.cream,
//                               width: 1.w,
//                             ),
//                           ),
//                           color: Colors.white,
//                           onPressed: () {},
//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Image.asset(
//                                 AppImages.google,
//                                 height: 30.h,
//                                 width: 30.w,
//                               ),
//                               SizedBox(width: 10.w),
//                               Text(
//                                 "Sign Up with Google ",
//                                 style: TextStyle(
//                                   color: Colors.black,
//                                   fontSize: 16.sp,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         SizedBox(height: 15.h),
//                         MaterialButton(
//                           height: 56.h,
//                           elevation: 0,
//                           minWidth: 325.w,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(45.r),
//                             side: BorderSide(
//                               color: ColorsApp.cream,
//                               width: 1.w,
//                             ),
//                           ),
//                           color: Colors.white,
//                           onPressed: () {},
//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Image.asset(
//                                 AppImages.facebook,
//                                 height: 24.h,
//                                 width: 24.w,
//                               ),
//                               SizedBox(width: 10.w),
//                               Text(
//                                 "Sign Up with Facebook ",
//                                 style: TextStyle(
//                                   color: Colors.black,
//                                   fontSize: 16.sp,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   SizedBox(height: 20.h),
//                   Center(
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const Text(
//                           "Already have an account? ",
//                           style: TextStyle(color: Colors.grey),
//                         ),
//                         TextButton(
//                           onPressed: () => Get.offNamed(AppRoutes.login),
//                           child: Text(
//                             "Sign In",
//                             style: TextStyle(
//                               color: ColorsApp.purple,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

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
