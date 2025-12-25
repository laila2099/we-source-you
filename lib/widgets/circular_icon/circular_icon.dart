// import 'package:flutter/material.dart';

// class CircularIcon extends StatelessWidget {
//   final IconData icon;
//   final List<Color> gradientColors;
//   const CircularIcon({required this.icon, required this.gradientColors});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 50,
//       height: 50,
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         gradient: LinearGradient(
//           colors: gradientColors,
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: gradientColors.last.withOpacity(0.4),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Icon(icon, color: Colors.white, size: 24),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:we_source_you/core/constant/responsive_layout.dart';
// import 'package:we_source_you/core/constant/text_style.dart';

class CircularIcon extends StatelessWidget {
  final Widget child;
  final List<Color> gradientColors;

  const CircularIcon({
    super.key,
    required this.child,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    double size = ResponsiveLayout.isDesktop(context)
        ? 52
        : ResponsiveLayout.isTablet(context)
        ? 44
        : 36;

    // double iconSize = AppTextStyles.size(mobile: 18, tablet: 22, desktop: 26);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: gradientColors.last.withOpacity(0.35),
            blurRadius: size * 0.3,
            offset: Offset(0, size * 0.08),
          ),
        ],
      ),
      child: child,
    );
  }
}
