// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:we_source_you/model/statistics_model.dart';
// import 'package:we_source_you/view/home/home_controller/home_controller.dart';
// import 'package:we_source_you/widgets/circular_icon/Circular_icon.dart';
// import 'package:we_source_you/widgets/glass_morphism.dart';
// import 'package:we_source_you/core/constant/responsive_layout.dart';

// class StatsGridView extends GetView<HomeController> {
//   const StatsGridView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     Get.find<HomeController>();

//     return Container(
//       padding: ResponsiveLayout.screenPadding(context),
//       color: const Color(0xFF1c1c1c),
//       child: Column(
//         children: [
//           const Text(
//             'Connect with thousands of media professionals and companies worldwide',
//             textAlign: TextAlign.center,
//             style: TextStyle(fontSize: 18, color: Colors.white70),
//           ),
//           const SizedBox(height: 50),

//           // Responsive Grid
//           LayoutBuilder(
//             builder: (context, constraints) {
//               // تحديد عدد الأعمدة حسب الشاشة
//               int crossAxisCount = ResponsiveLayout.isDesktop(context)
//                   ? 4
//                   : ResponsiveLayout.isTablet(context)
//                   ? 3
//                   : 2;

//               // حساب عرض كل عنصر مع الأخذ بالاعتبار الـ spacing
//               double spacing = 40.0;
//               double totalWidth = constraints.maxWidth;
//               double itemWidth =
//                   (totalWidth - (crossAxisCount - 1) * spacing) /
//                   crossAxisCount;

//               return GridView.builder(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 padding: EdgeInsets.zero,
//                 gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: crossAxisCount,
//                   crossAxisSpacing: spacing,
//                   mainAxisSpacing: spacing,
//                   childAspectRatio: 1, // سيجعلها مربعة
//                 ),
//                 itemCount: controller.stats.length,
//                 itemBuilder: (context, index) {
//                   final item = controller.stats[index];
//                   return SizedBox(
//                     width: itemWidth,
//                     height: itemWidth,
//                     child: _StatBox(item: item),
//                   );
//                 },
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _StatBox extends StatelessWidget {
//   final StatisticItem item;
//   const _StatBox({required this.item});

//   @override
//   Widget build(BuildContext context) {
//     return GlassContainer(
//       gradientColors: item.gradientColors
//           .map((c) => c.withOpacity(0.08))
//           .toList(),
//       blur: 8,
//       opacity: 0.05,
//       borderColor: Colors.white12,
//       borderRadius: 12,
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           CircularIcon(icon: item.icon, gradientColors: item.gradientColors),
//           const SizedBox(height: 16),
//           Text(
//             item.count,
//             style: const TextStyle(
//               color: Colors.white,
//               fontSize: 28,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             item.description,
//             style: const TextStyle(
//               color: Colors.white70,
//               fontSize: 14,
//               height: 1.4,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:we_source_you/model/statistics_model.dart';
// import 'package:we_source_you/view/home/home_controller/home_controller.dart';
// import 'package:we_source_you/widgets/circular_icon/Circular_icon.dart';
// import 'package:we_source_you/widgets/glass_morphism.dart';
// import 'package:we_source_you/core/constant/responsive_layout.dart';
// import 'package:we_source_you/core/constant/text_style.dart';
// import 'package:we_source_you/core/constant/app_color.dart';

// class StatsGridView extends GetView<HomeController> {
//   const StatsGridView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     Get.find<HomeController>();

//     return Container(
//       padding: ResponsiveLayout.screenPadding(context),
//       color: AppColors.darkBg,
//       child: Column(
//         children: [
//           // العنوان الرئيسي
//           Text(
//             'Connect with thousands of media professionals and companies worldwide',
//             textAlign: TextAlign.center,
//             style: AppTextStyles.body().copyWith(
//               color: Colors.white70,
//               fontSize: AppTextStyles.size(mobile: 16, tablet: 18, desktop: 22),
//               height: 1.6,
//             ),
//           ),
//           SizedBox(height: 50.h),

//           // Responsive Grid
//           LayoutBuilder(
//             builder: (context, constraints) {
//               int crossAxisCount = ResponsiveLayout.isDesktop(context)
//                   ? 4
//                   : ResponsiveLayout.isTablet(context)
//                   ? 3
//                   : 2;

//               double spacing = 40.0;
//               double totalWidth = constraints.maxWidth;
//               double itemWidth =
//                   (totalWidth - (crossAxisCount - 1) * spacing) /
//                   crossAxisCount;

//               return GridView.builder(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 padding: EdgeInsets.zero,
//                 gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: crossAxisCount,
//                   crossAxisSpacing: spacing,
//                   mainAxisSpacing: spacing,
//                   childAspectRatio: 1, // يجعل كل عنصر مربع
//                 ),
//                 itemCount: controller.stats.length,
//                 itemBuilder: (context, index) {
//                   final item = controller.stats[index];
//                   return SizedBox(
//                     width: itemWidth,
//                     height: itemWidth,
//                     child: _StatBox(item: item),
//                   );
//                 },
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _StatBox extends StatelessWidget {
//   final StatisticItem item;
//   const _StatBox({required this.item});

//   @override
//   Widget build(BuildContext context) {
//     return GlassContainer(
//       gradientColors: item.gradientColors
//           .map((c) => c.withOpacity(0.08))
//           .toList(),
//       blur: 8,
//       opacity: 0.05,
//       borderColor: Colors.white12,
//       borderRadius: 12,
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           CircularIcon(icon: item.icon, gradientColors: item.gradientColors),
//           SizedBox(height: 16.h),

//           // عدد الإحصائيات
//           Text(
//             item.count,
//             style: AppTextStyles.h6().copyWith(color: Colors.white),
//           ),
//           SizedBox(height: 8.h),

//           // وصف الإحصائيات
//           Text(
//             item.description,
//             style: AppTextStyles.body().copyWith(
//               color: Colors.white70,
//               height: 1.4,
//               fontSize: AppTextStyles.size(mobile: 12, tablet: 14, desktop: 16),
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:we_source_you/model/statistics_model.dart';
// import 'package:we_source_you/view/home/home_controller/home_controller.dart';
// import 'package:we_source_you/widgets/circular_icon/Circular_icon.dart';
// import 'package:we_source_you/widgets/glass_morphism.dart';
// import 'package:we_source_you/core/constant/responsive_layout.dart';
// import 'package:we_source_you/core/constant/text_style.dart';
// import 'package:we_source_you/core/constant/app_color.dart';

// class StatsGridView extends GetView<HomeController> {
//   const StatsGridView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.find<HomeController>();
//     double aspectRatio = ResponsiveLayout.isDesktop(context)
//         ? 1.5
//         : ResponsiveLayout.isTablet(context)
//         ? 0.95
//         : 0.85;

//     return Container(
//       padding: ResponsiveLayout.screenPadding(context),
//       color: AppColors.darkBg,
//       child: Column(
//         children: [
//           /// ✨ Title
//           Text(
//             'Connect with thousands of media professionals and companies worldwide',
//             textAlign: TextAlign.center,
//             style: AppTextStyles.h4().copyWith(color: Colors.white),
//           ),

//           SizedBox(height: 50.h),

//           /// ✨ Responsive Grid
//           LayoutBuilder(
//             builder: (context, constraints) {
//               int crossAxisCount = ResponsiveLayout.isDesktop(context)
//                   ? 4
//                   : ResponsiveLayout.isTablet(context)
//                   ? 2
//                   : 2;

//               double spacing = 20.0;
//               double totalWidth = constraints.maxWidth;
//               double itemWidth =
//                   (totalWidth - (crossAxisCount - 1) * spacing) /
//                   crossAxisCount;

//               return GridView.builder(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 padding: EdgeInsets.zero,
//                 gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: crossAxisCount,
//                   crossAxisSpacing: spacing,
//                   mainAxisSpacing: spacing,
//                   childAspectRatio: aspectRatio,
//                 ),
//                 itemCount: controller.stats.length,
//                 itemBuilder: (context, index) {
//                   final item = controller.stats[index];
//                   return SizedBox(
//                     width: itemWidth,
//                     height: itemWidth,
//                     child: _StatBox(item: item),
//                   );
//                 },
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _StatBox extends StatelessWidget {
//   final StatisticItem item;
//   const _StatBox({required this.item});

//   @override
//   Widget build(BuildContext context) {
//     return GlassContainer(
//       gradientColors: item.gradientColors
//           .map((c) => c.withOpacity(0.08))
//           .toList(),
//       blur: 8,
//       opacity: 0.05,
//       borderColor: Colors.white12,
//       borderRadius: 16,
//       child: Padding(
//         padding: EdgeInsets.symmetric(
//           horizontal: ResponsiveLayout.isDesktop(context) ? 24 : 16,
//           vertical: ResponsiveLayout.isDesktop(context) ? 20 : 16,
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             SizedBox(height: 12.h),

//             /// Icon
//             CircularIcon(icon: item.icon, gradientColors: item.gradientColors),

//             SizedBox(height: 16.h),

//             /// Count
//             Text(
//               item.count,
//               style: AppTextStyles.h4().copyWith(color: Colors.white),
//             ),

//             SizedBox(height: 8.h),

//             /// Description
//             Text(
//               item.description,
//               textAlign: TextAlign.center,
//               style: AppTextStyles.subtitle().copyWith(
//                 color: Colors.white70,
//                 height: 1.4,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
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

/// -----------------------------------------------
/// ✅ Stats Grid View
/// -----------------------------------------------
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
            style: AppTextStyles.h4().copyWith(color: Colors.white),
          ),
          SizedBox(height: 50.h),

          // Responsive Wrap Grid
          Obx(() {
            return Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: [
                for (final item in controller.stats)
                  SizedBox(
                    width: ResponsiveLayout.isDesktop(context)
                        ? 320
                        : ResponsiveLayout.isTablet(context)
                        ? 280
                        : MediaQuery.of(context).size.width * 0.9,
                    child: _StatBox(item: item),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

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
              style: AppTextStyles.h4().copyWith(
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
              style: AppTextStyles.subtitle().copyWith(
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
