import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:we_source_you/core/constant/app_color.dart';

class WebHoverButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed; // ✅ nullable
  final Widget? icon;
  final double? width;
  final double? height;
  final bool enabled; // ✅

  const WebHoverButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.width,
    this.height,
    this.enabled = true,
  });

  final LinearGradient gradient = const LinearGradient(
    colors: [AppColors.darkBlue, AppColors.lightBlue],
  );

  @override
  Widget build(BuildContext context) {
    final hover = ValueNotifier<bool>(false);

    return LayoutBuilder(
      builder: (context, constraints) {
        final calculatedWidth =
            width ?? constraints.maxWidth.clamp(120.0, 220.0);

        return MouseRegion(
          cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
          onEnter: (_) {
            if (enabled) hover.value = true;
          },
          onExit: (_) {
            if (enabled) hover.value = false;
          },
          child: GestureDetector(
            onTap: enabled ? onPressed : null,
            behavior: HitTestBehavior.opaque,
            child: ValueListenableBuilder<bool>(
              valueListenable: hover,
              builder: (context, isHover, child) {
                final showHover = enabled && isHover;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: height ?? 48.h,
                  width: calculatedWidth,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40.r),
                    gradient: enabled ? (showHover ? null : gradient) : null,
                    color: enabled
                        ? (showHover ? Colors.white : null)
                        : Colors.grey.shade400, // ✅ disabled color
                  ),
                  child: CustomPaint(
                    painter: showHover
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
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    color: enabled
                                        ? (showHover
                                              ? AppColors.darkBlue
                                              : Colors.white)
                                        : Colors.white,
                                  ),
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
