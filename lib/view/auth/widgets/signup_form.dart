import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:we_source_you/core/constant/app_color.dart';
import 'package:we_source_you/core/constant/text_style.dart';
import 'package:we_source_you/core/constant/responsive_layout.dart';
import 'package:we_source_you/view/auth/sign_up/sign_up_controller/sign_up_controller.dart';
import 'package:we_source_you/view/auth/widgets/drop_down.dart';
import 'package:we_source_you/view/auth/widgets/google_sign.dart';
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
            SizedBox(height: 5.h),
            const Text(
              'Media Talent',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            SizedBox(height: 20.h),

            Text(
              'Create your account'.tr,
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.h),
            GoogleSignInButton(),

            /// Continue with Google Button
            // OutlinedButton.icon(
            //   onPressed: () {},
            //   icon: Text('G', style: AppTextStyles.bodyBold(context)),
            //   label: Text(
            //     'Continue with Google',
            //     style: AppTextStyles.body(context),
            //   ),
            //   style: OutlinedButton.styleFrom(
            //     minimumSize: Size(double.infinity, 50.h),
            //     foregroundColor: Colors.black,
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(4.r),
            //     ),
            //   ),
            // ),
            SizedBox(height: 25.h),

            /// OR separator
            Row(
              children: <Widget>[
                const Expanded(child: Divider(color: Colors.grey)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Text(
                    'or',
                    style: AppTextStyles.body(
                      context,
                    ).copyWith(color: Colors.grey.shade600),
                  ),
                ),
                const Expanded(child: Divider(color: Colors.grey)),
              ],
            ),
            SizedBox(height: 30.h),

            /// ---------------- Account Type ----------------
            Text("Account Type", style: AppTextStyles.bodyBold(context)),
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
            SizedBox(height: 30.h),

            /// ---------------- COMPANY FIELDS ----------------
            if (controller.accountType.value == "company") ...[
              Text(
                "Company Information",
                style: AppTextStyles.bodyBold(context),
              ),
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
              Text(
                "Personal Information",
                style: AppTextStyles.bodyBold(context),
              ),
              SizedBox(height: 15.h),

              CustomTextField(
                labelText: 'Full Name',
                onChanged: (val) => controller.fullName.value = val,
              ),
              SizedBox(height: 20.h),

              /// Individual Job Type
              Text(
                "Type of Media Work",
                style: AppTextStyles.bodyBold(context),
              ),
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
                // onChanged: (value) {
                //   controller.individualJob.value = value ?? '';
                //   if (value != "Analyst") {
                //     controller.analystSpecialty.value = '';
                //   }
                // },
                onChanged: (value) {
                  controller.individualJob.value = value ?? '';

                  // Clear analyst specialty if not Analyst
                  if (value != "Analyst") {
                    controller.analystSpecialty.value = '';
                  }

                  // ✅ Add to mediaWorkTypes if not already there
                  if (value != null &&
                      !controller.mediaWorkTypes.contains(value)) {
                    controller.mediaWorkTypes.add(value);
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
                Text(
                  "Analyst Specialty",
                  style: AppTextStyles.bodyBold(context),
                ),
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
              crossAxisAlignment: CrossAxisAlignment.center, // بدل start
              children: [
                Checkbox(
                  value: controller.agreedToTerms.value,
                  onChanged: (val) => controller.agreedToTerms.value = val!,
                  activeColor: AppColors.darkBlue,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "I agree to the Terms of Service & Privacy Policy",
                    style: AppTextStyles.body(context),
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
                Text(
                  "Already have an account? ",
                  style: AppTextStyles.body(context),
                ),
                TextButton(
                  onPressed: controller.gosignIn,
                  child: Text(
                    'Sign In',
                    style: AppTextStyles.bodyBold(
                      context,
                    ).copyWith(color: AppColors.darkBlue),
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
