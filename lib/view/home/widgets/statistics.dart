import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_source_you/model/statistics_model.dart';
import 'package:we_source_you/view/home/home_controller/home_controller.dart';
import 'package:we_source_you/widgets/circular_icon/Circular_icon.dart';
import 'package:we_source_you/widgets/glass_morphism.dart';
import 'package:we_source_you/core/constant/responsive_layout.dart';
import 'package:we_source_you/core/constant/text_style.dart';
import 'package:we_source_you/core/constant/app_color.dart';

class _StatBox extends StatelessWidget {
  final StatisticItem item;
  const _StatBox({required this.item});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      gradientColors: item.gradientColors
          .map((c) => c.withOpacity(0.08))
          .toList(),
      blur: 8,
      opacity: 0.05,
      borderColor: Colors.white12,
      borderRadius: 16,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveLayout.isDesktop(context) ? 24 : 16,
          vertical: ResponsiveLayout.isDesktop(context) ? 20 : 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon
            CircularIcon(
              child: Icon(
                item.icon,
                size: ResponsiveLayout.isDesktop(context) ? 32 : 28,
              ),
              gradientColors: item.gradientColors,
            ),
            SizedBox(height: 12.h),

            // Count
            Text(
              item.count,
              style: AppTextStyles.h4(context).copyWith(
                color: Colors.white,
                fontSize: ResponsiveLayout.isDesktop(context) ? 24 : 20,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 6.h),

            // Description
            Text(
              item.description.tr,
              textAlign: TextAlign.center,
              style: AppTextStyles.subtitle(context).copyWith(
                color: Colors.white70,
                height: 1.4,
                fontSize: ResponsiveLayout.isDesktop(context) ? 16 : 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class StatsGridView extends GetView<HomeController> {
  const StatsGridView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final padding = ResponsiveLayout.screenPadding(context);

    return Container(
      padding: padding,
      color: AppColors.darkBg,
      child: Column(
        children: [
          // Title
          Text(
            'Connect with thousands of media professionals and companies worldwide'
                .tr,
            textAlign: TextAlign.center,
            style: AppTextStyles.h4(context).copyWith(color: Colors.white),
          ),
          SizedBox(height: 50.h),

          // Wrap داخل Center للحفاظ على المحاذاة
          Obx(() {
            return Center(
              child: Wrap(
                spacing: 20,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                children: [
                  for (final item in controller.stats)
                    ConstrainedBox(
                      // أقصى عرض لكل Box لتجنب الانزلاق
                      constraints: BoxConstraints(
                        maxWidth: ResponsiveLayout.isDesktop(context)
                            ? 320
                            : ResponsiveLayout.isTablet(context)
                            ? 280
                            : 350, // موبايل كبير
                        minWidth: 150, // اختياري لتجنب الصغر جداً
                      ),
                      child: SizedBox(
                        width: ResponsiveLayout.isDesktop(context)
                            ? 320
                            : ResponsiveLayout.isTablet(context)
                            ? 280
                            : null, // null للسماح للWrap بالتحكم
                        child: _StatBox(item: item),
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
