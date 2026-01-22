import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:we_source_you/core/constant/responsive_layout.dart';
import 'package:we_source_you/view/home/home_controller/home_controller.dart';

class MediaLogosView extends StatelessWidget {
  MediaLogosView({Key? key}) : super(key: key);
  final HomeController controller = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();
    return Container(
      padding: ResponsiveLayout.screenPadding(context),
      child: Center(
        child: GetBuilder<HomeController>(
          builder: (c) {
            final theme = Theme.of(context);

            // قائمة تحدد أي Logos تتغير ألوانها في Dark Theme
            final List<bool> changeOnDarkFlags = [
              false, // Washington
              true, // NYT
              false, // Logo آخر
              false,
              true,
              true,
              true,
              true,
              // أضف الباقي حسب ترتيب c.logoAssets
            ];

            return AnimatedBuilder(
              animation: c.animationController,
              builder: (context, child) {
                return Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 40.0,
                  runSpacing: 40.0,
                  children: List.generate(c.logoAssets.length, (index) {
                    double begin =
                        c.randomDelays[index] /
                        c.animationDuration.inMilliseconds;
                    double end =
                        (c.randomDelays[index] + 500) /
                        c.animationDuration.inMilliseconds;
                    if (end > 1.0) end = 1.0;

                    final curvedAnimation = CurvedAnimation(
                      parent: c.animationController,
                      curve: Interval(begin, end, curve: Curves.easeOut),
                    );

                    final opacity = Tween<double>(
                      begin: 0,
                      end: 1,
                    ).evaluate(curvedAnimation);
                    final scale = Tween<double>(
                      begin: 0.8,
                      end: 1.0,
                    ).evaluate(curvedAnimation);

                    double logoWidth = ResponsiveLayout.isDesktop(context)
                        ? 180
                        : 150;
                    double logoHeight = ResponsiveLayout.isDesktop(context)
                        ? 120
                        : 100;

                    return Opacity(
                      opacity: opacity,
                      child: Transform.scale(
                        scale: scale,
                        child: _MediaLogo(
                          assetPath: c.logoAssets[index],
                          key: ValueKey(index),
                          width: logoWidth,
                          height: logoHeight,
                          changeOnDark: changeOnDarkFlags[index],
                        ),
                      ),
                    );
                  }),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _MediaLogo extends StatefulWidget {
  final String assetPath;
  final double width;
  final double height;
  final bool changeOnDark; // هل يتغير لونه في

  const _MediaLogo({
    Key? key,
    required this.assetPath,
    this.width = 150,
    this.height = 100,
    this.changeOnDark = false,
  }) : super(key: key);

  @override
  State<_MediaLogo> createState() => _MediaLogoState();
}

class _MediaLogoState extends State<_MediaLogo> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // لون الـ SVG حسب Theme فقط
    final Color? svgColor =
        (widget.changeOnDark && theme.brightness == Brightness.dark)
        ? Colors.white
        : null; // null يعني يستخدم لون SVG الأصلي

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => print("Clicked ${widget.assetPath}"),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          transform: Matrix4.identity()..scale(_isHovering ? 1.1 : 1.0),
          child: SizedBox(
            width: 150,
            height: 100,
            child: SvgPicture.asset(
              widget.assetPath,
              color: svgColor, // اللون لا يتغير بالـ hover
              placeholderBuilder: (context) => const SizedBox(
                width: 150,
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
