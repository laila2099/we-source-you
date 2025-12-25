// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:we_source_you/core/constant/app_color.dart';
// import 'package:we_source_you/widgets/custom_buttom/custom_buttom_controller.dart';

// class WebHoverButton extends StatelessWidget {
//   final String text;
//   final VoidCallback onPressed;
//   final Widget? icon;
//   final double? width;
//   final double? height;

//   WebHoverButton({
//     super.key,
//     required this.text,
//     required this.onPressed,
//     this.icon,
//     this.width,
//     this.height,
//   });

//   final controller = Get.put(WebHoverController());

//   final gradient = const LinearGradient(
//     colors: [AppColors.darkBlue, AppColors.lightBlue],
//   );

//   double _responsiveFontSize(BuildContext context) {
//     final width = MediaQuery.of(context).size.width;

//     if (width >= 1200) return 18; // Desktop
//     if (width >= 800) return 16; // Tablet
//     return 14; // Mobile
//   }

//   @override
//   Widget build(BuildContext context) {
//     final fontSize = _responsiveFontSize(context);
//     return MouseRegion(
//       cursor: SystemMouseCursors.click,
//       onEnter: (_) => controller.setHover(true),
//       onExit: (_) => controller.setHover(false),
//       child: GestureDetector(
//         onTap: onPressed,
//         behavior: HitTestBehavior.opaque,
//         child: Obx(() {
//           final isHover = controller.isHover.value;

//           return AnimatedContainer(
//             duration: const Duration(milliseconds: 250),
//             height: height ?? 52.h,
//             width: width ?? 220.w,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(40.r),
//               gradient: isHover ? null : gradient,
//               color: isHover ? Colors.white : null,
//             ),
//             child: CustomPaint(
//               painter: isHover
//                   ? _GradientBorderPainter(gradient: gradient, strokeWidth: 2)
//                   : null,
//               child: Center(
//                 child: Text(
//                   text,
//                   style: TextStyle(
//                     fontSize: fontSize,
//                     fontWeight: FontWeight.w600,
//                     color: isHover ? AppColors.darkBlue : Colors.white,
//                   ),
//                 ),
//               ),
//             ),
//           );
//         }),
//       ),
//     );
//   }
// }

// class _GradientBorderPainter extends CustomPainter {
//   final Gradient gradient;
//   final double strokeWidth;

//   _GradientBorderPainter({required this.gradient, required this.strokeWidth});

//   @override
//   void paint(Canvas canvas, Size size) {
//     final rect = Offset.zero & size;

//     final paint = Paint()
//       ..shader = gradient.createShader(rect)
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = strokeWidth;

//     final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(40));
//     canvas.drawRRect(rrect, paint);
//   }

//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) => true;
// }
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:we_source_you/core/constant/app_color.dart';
// import 'package:we_source_you/widgets/custom_buttom/custom_buttom_controller.dart';

// class WebHoverButton extends StatelessWidget {
//   final String text;
//   final VoidCallback onPressed;
//   final Widget? icon;
//   final double? width;
//   final double? height;

//   WebHoverButton({
//     super.key,
//     required this.text,
//     required this.onPressed,
//     this.icon,
//     this.width,
//     this.height,
//   });

//   final controller = Get.put(WebHoverController());

//   final gradient = const LinearGradient(
//     colors: [AppColors.darkBlue, AppColors.lightBlue],
//   );

//   // تحديث: حساب الخط بناءً على عرض الـ Parent المتاح
//   double _getFontSize(double parentWidth) {
//     if (parentWidth >= 300) return 18; // مساحة واسعة
//     if (parentWidth >= 150) return 15; // مساحة متوسطة
//     return 12; // مساحة ضيقة
//   }

//   @override
//   Widget build(BuildContext context) {
//     // نستخدم LayoutBuilder لمعرفة القيود (Constraints) من الأب
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         // إذا لم يتم تمرير width ثابت، نستخدم 80% من مساحة الأب بحد أقصى 220
//         final double calculatedWidth =
//             width ?? constraints.maxWidth.clamp(120.0, 220.0);
//         final double fontSize = _getFontSize(constraints.maxWidth);

//         return MouseRegion(
//           cursor: SystemMouseCursors.click,
//           onEnter: (_) => controller.setHover(true),
//           onExit: (_) => controller.setHover(false),
//           child: GestureDetector(
//             onTap: onPressed,
//             behavior: HitTestBehavior.opaque,
//             child: Obx(() {
//               final isHover = controller.isHover.value;

//               return AnimatedContainer(
//                 duration: const Duration(milliseconds: 250),
//                 height: height ?? 48.h, // تقليل الارتفاع قليلاً ليكون متناسقاً
//                 width: calculatedWidth,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(40.r),
//                   gradient: isHover ? null : gradient,
//                   color: isHover ? Colors.white : null,
//                 ),
//                 child: CustomPaint(
//                   painter: isHover
//                       ? _GradientBorderPainter(
//                           gradient: gradient,
//                           strokeWidth: 2,
//                         )
//                       : null,
//                   child: Center(
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         if (icon != null) ...[icon!, SizedBox(width: 8.w)],
//                         Flexible(
//                           child: Text(
//                             text,
//                             textAlign: TextAlign.center,
//                             overflow: TextOverflow.ellipsis,
//                             style: TextStyle(
//                               fontSize: fontSize,
//                               fontWeight: FontWeight.w600,
//                               color: isHover
//                                   ? AppColors.darkBlue
//                                   : Colors.white,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             }),
//           ),
//         );
//       },
//     );
//   }
// }

// // الكلاس Painter يبقى كما هو
// class _GradientBorderPainter extends CustomPainter {
//   final Gradient gradient;
//   final double strokeWidth;

//   _GradientBorderPainter({required this.gradient, required this.strokeWidth});

//   @override
//   void paint(Canvas canvas, Size size) {
//     final rect = Offset.zero & size;
//     final paint = Paint()
//       ..shader = gradient.createShader(rect)
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = strokeWidth;

//     final rrect = RRect.fromRectAndRadius(rect, Radius.circular(40.r));
//     canvas.drawRRect(rrect, paint);
//   }

//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) => true;
// }
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_source_you/core/constant/app_color.dart';
import 'package:we_source_you/core/constant/text_style.dart';

class WebHoverButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Widget? icon;
  final double? width;
  final double? height;

  const WebHoverButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.width,
    this.height,
  });

  final LinearGradient gradient = const LinearGradient(
    colors: [AppColors.darkBlue, AppColors.lightBlue],
  );

  // حساب حجم الخط بناءً على عرض الأب
  double _getFontSize(double parentWidth) {
    if (parentWidth >= 300) return 18;
    if (parentWidth >= 150) return 15;
    return 12;
  }

  @override
  Widget build(BuildContext context) {
    final hover = ValueNotifier<bool>(false); // state مستقل لكل زر

    return LayoutBuilder(
      builder: (context, constraints) {
        final calculatedWidth =
            width ?? constraints.maxWidth.clamp(120.0, 220.0);
        // final fontSize = _getFontSize(constraints.maxWidth);

        return MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => hover.value = true,
          onExit: (_) => hover.value = false,
          child: GestureDetector(
            onTap: onPressed,
            behavior: HitTestBehavior.opaque,
            child: ValueListenableBuilder<bool>(
              valueListenable: hover,
              builder: (context, isHover, child) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: height ?? 48.h,
                  width: calculatedWidth,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40.r),
                    gradient: isHover ? null : gradient,
                    color: isHover ? Colors.white : null,
                  ),
                  child: CustomPaint(
                    painter: isHover
                        ? _GradientBorderPainter(
                            gradient: gradient,
                            strokeWidth: 2,
                          )
                        : null,
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (icon != null) ...[icon!, SizedBox(width: 8.w)],
                          Flexible(
                            child: Text(
                              text,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

// Painter للحدود المتدرجة عند hover
class _GradientBorderPainter extends CustomPainter {
  final Gradient gradient;
  final double strokeWidth;

  _GradientBorderPainter({required this.gradient, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(40.r));
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
