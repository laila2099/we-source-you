import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:we_source_you/core/constant/text_style.dart';
import 'package:we_source_you/view/auth/sign_up/sign_up_controller/sign_up_controller.dart';

class CountryDropdownField extends StatelessWidget {
  const CountryDropdownField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SignUpController>();

    return InkWell(
      onTap: () {
        showCountryPicker(
          context: context,
          showPhoneCode: false,
          onSelect: (Country country) {
            controller.country.value = country.name;
          },
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.r),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Obx(
          () => Text(
            controller.country.value.isEmpty
                ? 'Country'
                : controller.country.value,
            style: AppTextStyles.body(context),
          ),
        ),
      ),
    );
  }
}
