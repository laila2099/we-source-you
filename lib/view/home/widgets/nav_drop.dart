import 'package:flutter/material.dart';
import 'package:we_source_you/core/constant/text_style.dart';
import 'package:we_source_you/core/constant/responsive_layout.dart';

class HoverDropdown extends StatefulWidget {
  final String title;
  final List<String> items;

  const HoverDropdown({super.key, required this.title, required this.items});

  @override
  State<HoverDropdown> createState() => _HoverDropdownState();
}

class _HoverDropdownState extends State<HoverDropdown> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isHovered = false;

  void _showMenu() {
    if (_overlayEntry != null) return;

    final isDesktop = ResponsiveLayout.isDesktop(context);

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          width: isDesktop ? 200 : 160, // Responsive width
          child: CompositedTransformFollower(
            link: _layerLink,
            offset: Offset(0, isDesktop ? 48 : 40),
            child: Material(
              elevation: 12,
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.items.map((item) {
                    return InkWell(
                      onTap: () {},
                      hoverColor: Colors.blue.withOpacity(0.08),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        child: Text(
                          item,
                          style: AppTextStyles.body(context).copyWith(
                            fontSize: AppTextStyles.size(
                              context,
                              mobile: 13,
                              tablet: 14,
                              desktop: 15,
                            ),
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideMenu() {
    if (_overlayEntry?.mounted ?? false) {
      _overlayEntry?.remove();
    }
    _overlayEntry = null;
  }

  @override
  void dispose() {
    if (_overlayEntry?.mounted ?? false) {
      _overlayEntry?.remove();
    }
    _overlayEntry = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        if (isDesktop) _showMenu(); // القائمة فقط للديسكتوب
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        if (isDesktop) _hideMenu();
      },
      child: CompositedTransformTarget(
        link: _layerLink,
        child: Row(
          children: [
            Text(widget.title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: isDesktop ? 22 : 20,
              color: _isHovered ? Colors.blueAccent : Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}
