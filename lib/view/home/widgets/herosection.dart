import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_source_you/core/constant/responsive_layout.dart';
import 'package:we_source_you/core/constant/text_style.dart';
import 'package:we_source_you/view/home/widgets/media.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveLayout.isDesktop(context);

    return Container(
      padding: ResponsiveLayout.screenPadding(context),
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// ⭐ Title — fully responsive using AppTextStyles
          Text(
            "Trusted by Leading Media Organizations",
            textAlign: TextAlign.center,
            style: AppTextStyles.h4(context).copyWith(
              color: Theme.of(context).textTheme.headlineMedium!.color,
            ),
          ),

          SizedBox(height: isDesktop ? 80.h : 40.h),

          /// ⭐ Logos View
          MediaLogosView(),
        ],
      ),
    );
  }
}
