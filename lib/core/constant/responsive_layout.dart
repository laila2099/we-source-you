// import 'package:flutter/material.dart';

// class ResponsiveLayout extends StatelessWidget {
//   final Widget mobile;
//   final Widget tablet;
//   final Widget desktop;

//   const ResponsiveLayout({
//     super.key,
//     required this.mobile,
//     required this.tablet,
//     required this.desktop,
//   });

//   static bool isMobile(BuildContext context) =>
//       MediaQuery.of(context).size.width < 600;

//   static bool isTablet(BuildContext context) =>
//       MediaQuery.of(context).size.width >= 600 &&
//       MediaQuery.of(context).size.width < 1200;

//   static bool isDesktop(BuildContext context) =>
//       MediaQuery.of(context).size.width >= 1200;

//   /// ✅ Screen padding
//   static EdgeInsets screenPadding(BuildContext context) {
//     if (isDesktop(context)) {
//       return EdgeInsets.symmetric(horizontal: 80, vertical: 40);
//     } else if (isTablet(context)) {
//       return EdgeInsets.symmetric(horizontal: 60, vertical: 32);
//     } else {
//       return EdgeInsets.symmetric(horizontal: 20, vertical: 24);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         if (constraints.maxWidth >= 1200) return desktop;
//         if (constraints.maxWidth >= 600) return tablet;
//         return mobile;
//       },
//     );
//   }
// }
// import 'package:flutter/material.dart';

// class ResponsiveLayout extends StatelessWidget {
//   final Widget mobile;
//   final Widget tablet;
//   final Widget desktop;

//   const ResponsiveLayout({
//     super.key,
//     required this.mobile,
//     required this.tablet,
//     required this.desktop,
//   });

//   /// Screen size checks
//   static bool isMobile(BuildContext context) =>
//       MediaQuery.of(context).size.width < 600;

//   static bool isTablet(BuildContext context) =>
//       MediaQuery.of(context).size.width >= 600 &&
//       MediaQuery.of(context).size.width < 1200;

//   static bool isDesktop(BuildContext context) =>
//       MediaQuery.of(context).size.width >= 1200;

//   /// Screen padding
//   static EdgeInsets screenPadding(BuildContext context) {
//     if (isDesktop(context)) {
//       return const EdgeInsets.symmetric(horizontal: 80, vertical: 40);
//     } else if (isTablet(context)) {
//       return const EdgeInsets.symmetric(horizontal: 60, vertical: 32);
//     } else {
//       return const EdgeInsets.symmetric(horizontal: 20, vertical: 24);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         Widget child;

//         if (constraints.maxWidth >= 1200) {
//           child = desktop;
//         } else if (constraints.maxWidth >= 600) {
//           child = tablet;
//         } else {
//           child = mobile;
//         }

//         // Wrap in SingleChildScrollView to prevent vertical overflow
//         return ScrollConfiguration(
//           behavior: const ScrollBehavior().copyWith(overscroll: false),
//           child: SingleChildScrollView(
//             padding: screenPadding(context),
//             child: ConstrainedBox(
//               constraints: BoxConstraints(
//                 minHeight: constraints.maxHeight,
//                 maxWidth: double.infinity,
//               ),
//               child: IntrinsicHeight(child: child),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget tablet;
  final Widget desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    required this.tablet,
    required this.desktop,
  });

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1024;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1024;

  static EdgeInsets screenPadding(BuildContext context) {
    if (isDesktop(context))
      return const EdgeInsets.symmetric(horizontal: 80, vertical: 40);
    if (isTablet(context))
      return const EdgeInsets.symmetric(horizontal: 60, vertical: 32);
    return const EdgeInsets.symmetric(horizontal: 20, vertical: 24);
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    double maxWidth = MediaQuery.of(context).size.width;

    if (maxWidth >= 1024) {
      child = desktop;
    } else if (maxWidth >= 600) {
      child = tablet;
    } else {
      child = mobile;
    }

    return ScrollConfiguration(
      behavior: const ScrollBehavior().copyWith(overscroll: false),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
          maxWidth: double.infinity,
        ),
        child: child,
      ),
    );
  }
}
