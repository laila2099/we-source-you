// // signup_form.dart

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:we_source_you/core/constant/app_color.dart';
// import 'package:we_source_you/core/constant/text_style.dart';
// import 'package:we_source_you/core/constant/responsive_layout.dart';
// import 'package:we_source_you/view/auth/sign_up/sign_up_controller/sign_up_controller.dart';
// import 'package:we_source_you/view/auth/widgets/drop_down.dart';
// import 'package:we_source_you/widgets/custom_buttom/custom_buttom.dart';
// import 'package:we_source_you/widgets/custom_text_form/custom_text_form.dart';

// class SignUpForm extends GetView<SignUpController> {
//   const SignUpForm({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return SingleChildScrollView(
//       padding: ResponsiveLayout.screenPadding(context),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: <Widget>[
//           // Back Home Button
//           IconButton(
//             iconSize: 18,
//             color: theme.textTheme.bodySmall?.color,
//             onPressed: controller.goBack,
//             icon: const Icon(Icons.arrow_back),
//           ),
//           SizedBox(height: 30.h),

//           // Logo / Brand
//           Text(
//             'WeSourceYou',
//             style: AppTextStyles.h1().copyWith(
//               color: theme.textTheme.headlineLarge?.color,
//             ),
//           ),
//           SizedBox(height: 5.h),
//           Text(
//             'Media Talent',
//             style: AppTextStyles.body().copyWith(color: Colors.grey),
//           ),
//           SizedBox(height: 20.h),

//           // Create Your Account Header
//           Text(
//             'Create Your Account',
//             style: AppTextStyles.h2().copyWith(
//               color: theme.textTheme.headlineMedium?.color,
//             ),
//           ),
//           SizedBox(height: 10.h),
//           Text(
//             'Join thousands of media professionals and companies worldwide',
//             style: AppTextStyles.body().copyWith(color: Colors.grey),
//           ),
//           SizedBox(height: 30.h),

//           // Continue with Google Button
//           OutlinedButton.icon(
//             onPressed: () {},
//             icon: Text('G', style: AppTextStyles.bodyBold()),
//             label: Text('Continue with Google', style: AppTextStyles.body()),
//             style: OutlinedButton.styleFrom(
//               minimumSize: Size(double.infinity, 50.h),
//               foregroundColor: Colors.black,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(4.r),
//               ),
//             ),
//           ),
//           SizedBox(height: 20.h),

//           // OR Separator
//           Row(
//             children: <Widget>[
//               const Expanded(child: Divider(color: Colors.grey)),
//               Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 10.w),
//                 child: Text(
//                   'or',
//                   style: AppTextStyles.body().copyWith(
//                     color: Colors.grey.shade600,
//                   ),
//                 ),
//               ),
//               const Expanded(child: Divider(color: Colors.grey)),
//             ],
//           ),
//           SizedBox(height: 20.h),

//           // First Name & Last Name
//           Row(
//             children: [
//               Expanded(
//                 child: CustomTextField(
//                   labelText: 'First Name',
//                   onChanged: (value) => controller.firstName.value = value,
//                 ),
//               ),
//               SizedBox(width: 20.w),
//               Expanded(
//                 child: CustomTextField(
//                   labelText: 'Last Name',
//                   onChanged: (value) => controller.lastName.value = value,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 20.h),

//           // Email
//           CustomTextField(
//             labelText: 'Email Address',
//             keyboardType: TextInputType.emailAddress,
//             onChanged: (value) => controller.email.value = value,
//           ),
//           SizedBox(height: 20.h),

//           // Country
//           const CountryDropdownField(),
//           SizedBox(height: 20.h),

//           // Phone Number
//           CustomTextField(
//             labelText: 'Phone Number',
//             isOptional: true,
//             keyboardType: TextInputType.phone,
//             onChanged: (value) => controller.phone.value = value,
//             prefix: Text('+1 (555) 123-4567', style: AppTextStyles.body()),
//           ),
//           SizedBox(height: 20.h),

//           // City
//           CustomTextField(
//             labelText: 'City',
//             isOptional: true,
//             onChanged: (value) => controller.city.value = value,
//           ),
//           SizedBox(height: 20.h),

//           // Password
//           CustomTextField(
//             labelText: 'Password',
//             isPassword: true,
//             onChanged: (value) => controller.password.value = value,
//           ),
//           SizedBox(height: 20.h),

//           // Terms & Privacy Checkbox
//           Obx(
//             () => Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Checkbox(
//                   value: controller.agreedToTerms.value,
//                   onChanged: controller.setAgreedToTerms,
//                   activeColor: AppColors.darkBlue,
//                 ),
//                 Expanded(
//                   child: Padding(
//                     padding: EdgeInsets.only(top: 10.h),
//                     child: RichText(
//                       text: TextSpan(
//                         text: 'I agree to the ',
//                         style: AppTextStyles.body().copyWith(
//                           color: Colors.black54,
//                         ),
//                         children: <TextSpan>[
//                           TextSpan(
//                             text: 'Terms of Service',
//                             style: AppTextStyles.bodyBold().copyWith(
//                               color: AppColors.darkBlue,
//                             ),
//                           ),
//                           const TextSpan(text: ' and '),
//                           TextSpan(
//                             text: 'Privacy Policy',
//                             style: AppTextStyles.bodyBold().copyWith(
//                               color: AppColors.darkBlue,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           SizedBox(height: 30.h),

//           // Create Account Button
//           Center(
//             child: WebHoverButton(
//               text: "Create Account",
//               onPressed: controller.createAccount,
//               width: 300.w,
//             ),
//           ),
//           SizedBox(height: 30.h),

//           // Already have an account?
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text("Already have an account? ", style: AppTextStyles.body()),
//               TextButton(
//                 onPressed: controller.gosignIn,
//                 child: Text(
//                   'Sign In',
//                   style: AppTextStyles.bodyBold().copyWith(
//                     color: AppColors.darkBlue,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
// signup_form.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:we_source_you/core/constant/app_color.dart';
import 'package:we_source_you/core/constant/text_style.dart';
import 'package:we_source_you/core/constant/responsive_layout.dart';
import 'package:we_source_you/view/auth/sign_up/sign_up_controller/sign_up_controller.dart';
import 'package:we_source_you/view/auth/widgets/drop_down.dart';
import 'package:we_source_you/widgets/custom_buttom/custom_buttom.dart';
import 'package:we_source_you/widgets/custom_text_form/custom_text_form.dart';

class SignUpForm extends GetView<SignUpController> {
  const SignUpForm({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(
      () => SingleChildScrollView(
        padding: ResponsiveLayout.screenPadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            /// Back Button
            IconButton(
              iconSize: 18,
              color: theme.textTheme.bodySmall?.color,
              onPressed: controller.goBack,
              icon: const Icon(Icons.arrow_back),
            ),
            SizedBox(height: 30.h),

            /// Brand
            Text(
              'WeSourceYou',
              style: AppTextStyles.h1().copyWith(
                color: theme.textTheme.headlineLarge?.color,
              ),
            ),
            SizedBox(height: 5.h),
            Text(
              'Media Talent',
              style: AppTextStyles.body().copyWith(color: Colors.grey),
            ),
            SizedBox(height: 20.h),

            Text(
              'Create Your Account',
              style: AppTextStyles.h2().copyWith(
                color: theme.textTheme.headlineMedium?.color,
              ),
            ),
            SizedBox(height: 10.h),

            /// Continue with Google Button
            OutlinedButton.icon(
              onPressed: () {},
              icon: Text('G', style: AppTextStyles.bodyBold()),
              label: Text('Continue with Google', style: AppTextStyles.body()),
              style: OutlinedButton.styleFrom(
                minimumSize: Size(double.infinity, 50.h),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ),
            SizedBox(height: 25.h),

            /// OR separator
            Row(
              children: <Widget>[
                const Expanded(child: Divider(color: Colors.grey)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Text(
                    'or',
                    style: AppTextStyles.body().copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                const Expanded(child: Divider(color: Colors.grey)),
              ],
            ),
            SizedBox(height: 30.h),

            /// ---------------- Account Type ----------------
            Text("Account Type", style: AppTextStyles.bodyBold()),
            SizedBox(height: 10.h),

            Row(
              children: [
                Radio<String>(
                  value: "individual",
                  groupValue: controller.accountType.value,
                  onChanged: controller.setAccountType,
                ),
                const Text("Individual"),

                SizedBox(width: 20.w),

                Radio<String>(
                  value: "company",
                  groupValue: controller.accountType.value,
                  onChanged: controller.setAccountType,
                ),
                const Text("Company"),
              ],
            ),
            SizedBox(height: 30.h),

            /// Email
            CustomTextField(
              labelText: 'Email Address',
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) => controller.email.value = value,
            ),
            SizedBox(height: 20.h),

            /// Country Dropdown
            const CountryDropdownField(),
            SizedBox(height: 20.h),

            /// Phone Number
            CustomTextField(
              labelText: 'Phone Number',
              keyboardType: TextInputType.phone,
              onChanged: (value) => controller.phone.value = value,
            ),
            SizedBox(height: 20.h),

            /// City
            CustomTextField(
              labelText: 'City',
              onChanged: (value) => controller.city.value = value,
            ),
            SizedBox(height: 30.h),

            /// ---------------- COMPANY FIELDS ----------------
            if (controller.accountType.value == "company") ...[
              Text("Company Information", style: AppTextStyles.bodyBold()),
              SizedBox(height: 15.h),

              CustomTextField(
                labelText: 'Company Name',
                onChanged: (val) => controller.companyName.value = val,
              ),
              SizedBox(height: 20.h),

              CustomTextField(
                labelText: 'Website (optional)',
                onChanged: (val) => controller.website.value = val,
              ),
              SizedBox(height: 20.h),
            ],

            /// ---------------- INDIVIDUAL FIELDS ----------------
            if (controller.accountType.value == "individual") ...[
              Text("Personal Information", style: AppTextStyles.bodyBold()),
              SizedBox(height: 15.h),

              CustomTextField(
                labelText: 'Full Name',
                onChanged: (val) => controller.fullName.value = val,
              ),
              SizedBox(height: 20.h),

              /// Individual Job Type
              Text("Type of Media Work", style: AppTextStyles.bodyBold()),
              SizedBox(height: 10.h),

              DropdownButtonFormField<String>(
                value: controller.individualJob.value.isEmpty
                    ? null
                    : controller.individualJob.value,
                items: const [
                  DropdownMenuItem(value: "Producer", child: Text("منتج")),
                  DropdownMenuItem(value: "Reporter", child: Text("مراسل")),
                  DropdownMenuItem(
                    value: "TV Cameraman",
                    child: Text("مصور تلفزيوني"),
                  ),
                  DropdownMenuItem(
                    value: "Photographer",
                    child: Text("مصور ضوئي"),
                  ),
                  DropdownMenuItem(value: "Editor", child: Text("مونتير")),
                  DropdownMenuItem(value: "Trainer", child: Text("مدرب")),
                  DropdownMenuItem(
                    value: "Graphic Designer",
                    child: Text("مصمم غرافيك"),
                  ),
                  DropdownMenuItem(
                    value: "Media Lawyer",
                    child: Text("محامي مختص بالشأن الاعلامي"),
                  ),
                  DropdownMenuItem(
                    value: "Voice Over",
                    child: Text("فويس أوفر"),
                  ),
                  DropdownMenuItem(value: "Translator", child: Text("مترجم")),
                  DropdownMenuItem(value: "Analyst", child: Text("محلل")),
                ],
                onChanged: (value) {
                  controller.individualJob.value = value ?? '';
                  if (value != "Analyst") {
                    controller.analystSpecialty.value = '';
                  }
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Select your job",
                ),
              ),
              SizedBox(height: 20.h),

              /// Analyst Specialty
              if (controller.individualJob.value == "Analyst") ...[
                Text("Analyst Specialty", style: AppTextStyles.bodyBold()),
                SizedBox(height: 10.h),

                DropdownButtonFormField<String>(
                  value: controller.analystSpecialty.value.isEmpty
                      ? null
                      : controller.analystSpecialty.value,
                  items: const [
                    DropdownMenuItem(
                      value: "Arabic Affairs",
                      child: Text("عربي"),
                    ),
                    DropdownMenuItem(
                      value: "Kurdish Affairs",
                      child: Text("كردي"),
                    ),
                    DropdownMenuItem(
                      value: "Persian Affairs",
                      child: Text("فارسي"),
                    ),
                  ],
                  onChanged: (value) =>
                      controller.analystSpecialty.value = value ?? '',
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Select specialty",
                  ),
                ),
              ],

              SizedBox(height: 20.h),

              CustomTextField(
                labelText: 'Social Account Links (optional)',
                onChanged: (val) => controller.socialLinks.value = val,
              ),
              SizedBox(height: 20.h),
            ],

            /// Password
            CustomTextField(
              labelText: 'Password',
              isPassword: true,
              onChanged: (value) => controller.password.value = value,
            ),
            SizedBox(height: 30.h),

            /// Terms
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: controller.agreedToTerms.value,
                  onChanged: controller.agreedToTerms,
                  activeColor: AppColors.darkBlue,
                ),
                Expanded(
                  child: Text(
                    "I agree to the Terms of Service & Privacy Policy",
                    style: AppTextStyles.body(),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30.h),

            /// Submit Button
            Center(
              child: WebHoverButton(
                text: "Create Account",
                onPressed: controller.createAccount,
                width: 300.w,
              ),
            ),
            SizedBox(height: 20.h),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Already have an account? ", style: AppTextStyles.body()),
                TextButton(
                  onPressed: controller.gosignIn,
                  child: Text(
                    'Sign In',
                    style: AppTextStyles.bodyBold().copyWith(
                      color: AppColors.darkBlue,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
