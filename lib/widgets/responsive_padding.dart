import 'package:flutter/material.dart';
import 'package:we_source_you/core/constant/responsive_layout.dart';

class ResponsivePadding extends StatelessWidget {
  final Widget? child;
  const ResponsivePadding({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveLayout.screenPadding(context);
    return Padding(padding: padding, child: child ?? const SizedBox.shrink());
  }
}
