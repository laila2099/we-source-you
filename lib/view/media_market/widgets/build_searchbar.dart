import 'package:flutter/material.dart';

class SearchBarWithFilter extends StatelessWidget {
  final String hintText;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onFilterTap;
  final double? maxWidth;
  final bool showFilterButton; // ✅ جديد

  const SearchBarWithFilter({
    super.key,
    this.hintText = "Search...",
    this.onSearchChanged,
    this.onFilterTap,
    this.maxWidth,
    this.showFilterButton = true, // افتراضي true
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive width
    double width;
    if (screenWidth >= 1200) {
      width = maxWidth ?? 600;
    } else if (screenWidth >= 800) {
      width = screenWidth * 0.7;
    } else {
      width = screenWidth * 0.95;
    }

    return Center(
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            // Search Field
            Expanded(
              child: TextField(
                onChanged: onSearchChanged,
                decoration: InputDecoration(
                  hintText: hintText,
                  border: InputBorder.none,
                ),
              ),
            ),

            // Filter Button فقط إذا showFilterButton = true
            if (showFilterButton)
              InkWell(
                onTap: onFilterTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD81B60),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.filter_list, color: Colors.white, size: 16),
                      SizedBox(width: 6),
                      Text(
                        "Filters",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
