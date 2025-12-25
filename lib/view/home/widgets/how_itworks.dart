// // how_it_works_view.dart

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:we_source_you/core/constant/app_color.dart';
// import 'package:we_source_you/model/how_itwork_model.dart';
// import 'package:we_source_you/view/home/home_controller/home_controller.dart'; // Import AppColors

// class HowItWorksView extends GetView<HomeController> {
//   const HowItWorksView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     Get.find<HomeController>();

//     return Container(
//       color: AppColors.cream,
//       padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
//       child: Column(
//         children: [
//           // Section Header
//           Text(
//             'How It Works',
//             style: TextStyle(
//               fontSize: 32,
//               fontWeight: FontWeight.bold,
//               color: AppColors.grey,
//             ),
//           ),
//           const SizedBox(height: 10),
//           const Text(
//             'Get started in just a few simple steps and join thousands of media professionals',
//             textAlign: TextAlign.center,
//             style: TextStyle(fontSize: 18, color: AppColors.darkGrey),
//           ),
//           const SizedBox(height: 50),

//           // The Steps Grid (Responsive Wrap)
//           Center(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20.0),
//               child: Wrap(
//                 spacing: 30.0,
//                 runSpacing: 40.0,
//                 alignment: WrapAlignment.center,
//                 children: controller.steps.map((step) {
//                   return SizedBox(
//                     width: 280, // Slightly wider constraint for the card
//                     child: _StepCard(step: step),
//                   );
//                 }).toList(),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // Helper Widget for the Individual Card
// class _StepCard extends StatelessWidget {
//   final HowItWorksStep step;
//   const _StepCard({required this.step});

//   @override
//   Widget build(BuildContext context) {
//     // The main card container
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(
//           // Red border only for step 4, otherwise light grey
//           color: step.stepNumber == 4
//               ? AppColors.lightBlue.withOpacity(0.5)
//               : Colors.grey.shade200,
//           width: 1.5,
//         ),
//         boxShadow: [
//           if (step.stepNumber == 4) // Subtle shadow for the highlighted card
//             BoxShadow(
//               color: AppColors.lightBlue.withOpacity(0.1),
//               blurRadius: 10,
//               offset: const Offset(0, 5),
//             ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // 1. Numbered Icon/Circle
//           _NumberedCircle(stepNumber: step.stepNumber),
//           const SizedBox(height: 20),

//           // 2. Title
//           Text(
//             step.title,
//             style: const TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: AppColors.grey,
//             ),
//           ),
//           const SizedBox(height: 8),

//           // 3. Description
//           Text(
//             step.description,
//             style: const TextStyle(fontSize: 14, color: AppColors.darkGrey),
//           ),
//           const SizedBox(height: 15),

//           // 4. Checklist Items
//           ...step.checklist.map(
//             (item) => Padding(
//               padding: const EdgeInsets.only(bottom: 8.0),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Icon(
//                     Icons.check_circle_outline,
//                     color: AppColors.lightBlue, // Use a light blue checkmark
//                     size: 16,
//                   ),
//                   const SizedBox(width: 8),
//                   Flexible(
//                     child: Text(
//                       item,
//                       style: const TextStyle(
//                         fontSize: 14,
//                         color: AppColors.grey,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // Helper Widget for the Numbered Circle/Icon (with subtle gradient/shadow)
// class _NumberedCircle extends StatelessWidget {
//   final int stepNumber;
//   const _NumberedCircle({required this.stepNumber});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 40,
//       height: 40,
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         border: Border.all(
//           color: AppColors.darkGrey.withOpacity(0.5),
//           width: 1,
//         ),
//         color: Colors.white,
//       ),
//       child: Center(
//         child: Text(
//           stepNumber.toString(),
//           style: TextStyle(
//             color: stepNumber == 4 ? AppColors.lightBlue : AppColors.grey,
//             fontWeight: FontWeight.bold,
//             fontSize: 16,
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:we_source_you/core/constant/app_color.dart';
import 'package:we_source_you/model/how_itwork_model.dart';
import 'package:we_source_you/view/home/home_controller/home_controller.dart';

class HowItWorksView extends StatelessWidget {
  HowItWorksView({super.key});
  final HomeController controller = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    // الوصول للثيم الحالي
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Container(
      // استخدام اللون من الثيم أو AppColors إذا كان متوافقاً
      color: theme.brightness == Brightness.light
          ? AppColors.cream
          : theme.scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
      child: Column(
        children: [
          // Section Header
          Text(
            'How It Works'.tr,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              // يفضل استخدام لون الثيم الأساسي للنصوص
              color: textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Get started in just a few simple steps and join thousands of media professionals'
                .tr,
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge,
          ),
          const SizedBox(height: 50),

          // The Steps Grid
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Wrap(
                spacing: 30.0,
                runSpacing: 40.0,
                alignment: WrapAlignment.center,
                children: controller.steps.map((step) {
                  return SizedBox(width: 280, child: _StepCard(step: step));
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final HowItWorksStep step;
  const _StepCard({required this.step});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(10),
        // تعديل: البوردر دائماً باللون الأزرق الفاتح لكل الكروت
        border: Border.all(
          color: AppColors.lightBlue.withOpacity(0.5),
          width: 1.5,
        ),
        boxShadow: [
          // يمكنك إبقاء الظل فقط للكارت المميز أو إزالته حسب رغبتك
          if (step.stepNumber == 4)
            BoxShadow(
              color: AppColors.lightBlue.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _NumberedCircle(stepNumber: step.stepNumber),
          const SizedBox(height: 20),

          Text(
            step.title.tr,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          Text(step.description.tr, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 15),

          ...step.checklist.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    // تعديل: لون الـ check دائماً lightBlue
                    color: AppColors.lightBlue,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(item.tr, style: theme.textTheme.bodySmall),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NumberedCircle extends StatelessWidget {
  final int stepNumber;
  const _NumberedCircle({required this.stepNumber});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // تعديل: بوردر الدائرة دائماً lightBlue
        border: Border.all(color: AppColors.lightBlue, width: 1.5),
        color: theme.canvasColor,
      ),
      child: Center(
        child: Text(
          stepNumber.toString(),
          style: TextStyle(
            // تعديل: رقم الخطوة دائماً lightBlue
            color: AppColors.lightBlue,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

// class _StepCard extends StatelessWidget {
//   final HowItWorksStep step;
//   const _StepCard({required this.step});

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;

//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         // cardColor يتغير تلقائياً بين الأبيض والرمادي الغامق حسب الثيم
//         color: theme.cardColor,
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(
//           color: step.stepNumber == 4
//               ? theme.primaryColor.withOpacity(0.5)
//               : theme.dividerColor, // استخدام لون المقسمات الافتراضي كحدود
//           width: 1.5,
//         ),
//         boxShadow: [
//           if (step.stepNumber == 4)
//             BoxShadow(
//               color: theme.primaryColor.withOpacity(0.1),
//               blurRadius: 10,
//               offset: const Offset(0, 5),
//             ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _NumberedCircle(stepNumber: step.stepNumber),
//           const SizedBox(height: 20),

//           // Title
//           Text(
//             step.title,
//             style: theme.textTheme.titleLarge?.copyWith(
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 8),

//           // Description
//           Text(step.description, style: theme.textTheme.bodyMedium),
//           const SizedBox(height: 15),

//           // Checklist Items
//           ...step.checklist.map(
//             (item) => Padding(
//               padding: const EdgeInsets.only(bottom: 8.0),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Icon(
//                     Icons.check_circle_outline,
//                     // استخدام لون البراند الأساسي من الثيم
//                     color: theme.primaryColor,
//                     size: 16,
//                   ),
//                   const SizedBox(width: 8),
//                   Flexible(child: Text(item, style: theme.textTheme.bodySmall)),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _NumberedCircle extends StatelessWidget {
//   final int stepNumber;
//   const _NumberedCircle({required this.stepNumber});

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Container(
//       width: 40,
//       height: 40,
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         border: Border.all(color: theme.dividerColor, width: 1),
//         color: theme.canvasColor, // لون خلفية العناصر الصغيرة
//       ),
//       child: Center(
//         child: Text(
//           stepNumber.toString(),
//           style: TextStyle(
//             color: stepNumber == 4
//                 ? theme.primaryColor
//                 : theme.textTheme.bodyLarge?.color,
//             fontWeight: FontWeight.bold,
//             fontSize: 16,
//           ),
//         ),
//       ),
//     );
//   }
// }
