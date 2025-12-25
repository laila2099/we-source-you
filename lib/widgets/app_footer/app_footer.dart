import 'package:flutter/material.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isDesktop = width > 900;

    return Container(
      width: double.infinity,
      color: Colors.black,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------- TOP GRID ----------
          isDesktop ? _desktopGrid() : _mobileGrid(),

          const SizedBox(height: 40),

          const Divider(color: Colors.white24),

          const SizedBox(height: 20),

          // ---------- BOTTOM ----------
          _bottomRow(),
        ],
      ),
    );
  }

  // ==============================
  // DESKTOP LAYOUT
  // ==============================
  Widget _desktopGrid() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _column("Company", ["About", "Careers", "News", "Contact"]),
        ),
        Expanded(
          child: _column("Products", ["App", "Web", "API", "Integrations"]),
        ),
        Expanded(
          child: _column("Support", [
            "Help Center",
            "Privacy",
            "Terms",
            "Status",
          ]),
        ),
        Expanded(
          child: _column("Follow", [
            "Instagram",
            "LinkedIn",
            "Twitter",
            "YouTube",
          ]),
        ),
      ],
    );
  }

  // ==============================
  // MOBILE LAYOUT
  // ==============================
  Widget _mobileGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _column("Company", ["About", "Careers", "News", "Contact"]),
        const SizedBox(height: 25),
        _column("Products", ["App", "Web", "API", "Integrations"]),
        const SizedBox(height: 25),
        _column("Support", ["Help Center", "Privacy", "Terms", "Status"]),
        const SizedBox(height: 25),
        _column("Follow", ["Instagram", "LinkedIn", "Twitter", "YouTube"]),
      ],
    );
  }

  // ==============================
  // COLUMN W/ HOVER EFFECT
  // ==============================
  Widget _column(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 12),

        ...items.map((text) {
          return HoverText(text: text);
        }),
      ],
    );
  }

  // ==============================
  // BOTTOM ROW
  // ==============================
  Widget _bottomRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        Text(
          "© 2025 WeSourceYou. All rights reserved.",
          style: TextStyle(color: Colors.white60, fontSize: 14),
        ),

        // Social icons (Apple-like subtle icons)
        Row(
          children: [
            Icon(Icons.facebook, color: Colors.white60, size: 20),
            SizedBox(width: 16),
            Icon(Icons.camera_alt, color: Colors.white60, size: 20),
            SizedBox(width: 16),
            Icon(Icons.alternate_email, color: Colors.white60, size: 20),
          ],
        ),
      ],
    );
  }
}

/// =============================
/// ✅ Hover Text Effect (Apple Style)
/// =============================
class HoverText extends StatefulWidget {
  final String text;

  const HoverText({super.key, required this.text});

  @override
  State<HoverText> createState() => _HoverTextState();
}

class _HoverTextState extends State<HoverText> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 200),
        style: TextStyle(
          color: hover ? Colors.white : Colors.white70,
          fontSize: 15,
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(widget.text),
        ),
      ),
    );
  }
}
