import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:we_source_you/core/constant/text_style.dart';
import 'package:we_source_you/view/auth/sign_up/sign_up_controller/sign_up_controller.dart';

class CountryDropdownField extends StatelessWidget {
  const CountryDropdownField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          labelText: 'Country',
        ),
        value: 'United States',
        items: ['United States', 'Canada', 'United Kingdom', 'other'].map((
          String value,
        ) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value, style: AppTextStyles.body(context)),
          );
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            Get.find<SignUpController>().country.value = newValue;
          }
        },
      ),
    );
  }
}
