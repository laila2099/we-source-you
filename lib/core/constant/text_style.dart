// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// class AppTextStyles {
//   static double size({
//     required double mobile,
//     required double tablet,
//     required double desktop,
//   }) {
//     final w = ScreenUtil().screenWidth;

//     if (w >= 1200) return desktop * 0.8;
//     if (w >= 600) return tablet;
//     return mobile;
//   }

//   // Headings
//   static TextStyle h1() => TextStyle(
//     fontFamily: "Merriweather",
//     fontSize: size(mobile: 28, tablet: 36, desktop: 42),
//     fontWeight: FontWeight.w800,
//     height: 1.2,
//     letterSpacing: 0.5,
//   );

//   static TextStyle h2() => TextStyle(
//     fontFamily: "Merriweather",
//     fontSize: size(mobile: 24, tablet: 32, desktop: 36),
//     fontWeight: FontWeight.w700,
//     height: 1.25,
//   );

// static TextStyle h3() => TextStyle(
//   fontFamily: "Merriweather",
//   fontSize: size(mobile: 20, tablet: 26, desktop: 28),
//   fontWeight: FontWeight.w700,
// );

//   static TextStyle h4() => TextStyle(
//     fontFamily: "Inter",
//     fontSize: size(mobile: 18, tablet: 20, desktop: 22),
//     fontWeight: FontWeight.w600,
//   );

// static TextStyle h5() => TextStyle(
//   fontFamily: "Inter",
//   fontSize: size(mobile: 16, tablet: 18, desktop: 20),
//   fontWeight: FontWeight.w600,
// );

// static TextStyle h6() => TextStyle(
//   fontFamily: "Inter",
//   fontSize: size(mobile: 14, tablet: 15, desktop: 16),
//   fontWeight: FontWeight.w600,
// );

//   // Body text
//   static TextStyle body() => TextStyle(
//     fontFamily: "Inter",
//     fontSize: size(mobile: 14, tablet: 16, desktop: 16),
//     fontWeight: FontWeight.w400,
//     height: 1.6,
//   );

// static TextStyle bodyBold() => TextStyle(
//   fontFamily: "Inter",
//   fontSize: size(mobile: 14, tablet: 16, desktop: 16),
//   fontWeight: FontWeight.w700,
// );

//   // Subtitle
// static TextStyle subtitle() => TextStyle(
//   fontFamily: "Inter",
//   fontSize: size(mobile: 12, tablet: 14, desktop: 15),
//   fontWeight: FontWeight.w500,
// );

//   // Button
// static TextStyle button() => TextStyle(
//   fontFamily: "Inter",
//   fontSize: size(mobile: 14, tablet: 15, desktop: 16),
//   fontWeight: FontWeight.w600,
//   letterSpacing: 0.3,
// );

// // Caption / small text
// static TextStyle caption() => TextStyle(
//   fontFamily: "Inter",
//   fontSize: size(mobile: 11, tablet: 12, desktop: 14),
//   fontWeight: FontWeight.w400,
// );
// }
import 'package:flutter/material.dart';

class AppTextStyles {
  static double size(
    BuildContext context, {
    required double mobile,
    required double tablet,
    required double desktop,
  }) {
    final w = MediaQuery.of(context).size.width;

    if (w >= 1200) return desktop;
    if (w >= 600) return tablet;
    return mobile;
  }

  static TextStyle h1(BuildContext context) => TextStyle(
    fontFamily: "Merriweather",
    fontSize: size(context, mobile: 28, tablet: 36, desktop: 42),
    fontWeight: FontWeight.w800,
    height: 1.2,
    letterSpacing: 0.5,
  );

  static TextStyle h2(BuildContext context) => TextStyle(
    fontFamily: "Merriweather",
    fontSize: size(context, mobile: 24, tablet: 32, desktop: 36),
    fontWeight: FontWeight.w700,
  );
  static TextStyle h3(BuildContext context) => TextStyle(
    fontFamily: "Merriweather",
    fontSize: size(context, mobile: 20, tablet: 26, desktop: 28),
    fontWeight: FontWeight.w700,
  );

  static TextStyle h4(BuildContext context) => TextStyle(
    fontFamily: "Inter",
    fontSize: size(context, mobile: 18, tablet: 20, desktop: 22),
    fontWeight: FontWeight.w600,
  );
  static TextStyle h5(BuildContext context) => TextStyle(
    fontFamily: "Inter",
    fontSize: size(context, mobile: 16, tablet: 18, desktop: 20),
    fontWeight: FontWeight.w600,
  );

  static TextStyle h6(BuildContext context) => TextStyle(
    fontFamily: "Inter",
    fontSize: size(context, mobile: 14, tablet: 15, desktop: 16),
    fontWeight: FontWeight.w600,
  );

  static TextStyle body(BuildContext context) => TextStyle(
    fontFamily: "Inter",
    fontSize: size(context, mobile: 14, tablet: 16, desktop: 16),
    fontWeight: FontWeight.w400,
    height: 1.6,
  );
  static TextStyle bodyBold(BuildContext context) => TextStyle(
    fontFamily: "Inter",
    fontSize: size(context, mobile: 14, tablet: 16, desktop: 16),
    fontWeight: FontWeight.w700,
  );
  static TextStyle subtitle(BuildContext context) => TextStyle(
    fontFamily: "Inter",
    fontSize: size(context, mobile: 12, tablet: 14, desktop: 15),
    fontWeight: FontWeight.w500,
  );
  static TextStyle button(BuildContext context) => TextStyle(
    fontFamily: "Inter",
    fontSize: size(context, mobile: 14, tablet: 15, desktop: 16),
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  );

  // Caption / small text
  static TextStyle caption(BuildContext context) => TextStyle(
    fontFamily: "Inter",
    fontSize: size(context, mobile: 11, tablet: 12, desktop: 14),
    fontWeight: FontWeight.w400,
  );
}
