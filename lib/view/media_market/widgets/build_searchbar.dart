// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:we_source_you/view/media_market/filer_section/filter_section.dart';
// import 'package:we_source_you/view/media_market/media_market_controller/media_market_controller.dart';

// Widget buildSearchBar(context) {
//   final controller = Get.find<MediaController>();
//   final theme = Theme.of(context);
//   return Center(
//     child: Container(
//       width: 600, // Fixed width for search bar
//       decoration: BoxDecoration(
//         color: theme.colorScheme.surface, // <-- background from theme
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: Colors.grey.withOpacity(0.2)),
//       ),
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//       child: Row(
//         children: [
//           Expanded(
//             child: TextField(
//               onChanged: (value) => controller.searchQuery.value = value,
//               decoration: InputDecoration(
//                 hintText: "Search for content...",
//                 border: InputBorder.none,
//               ),
//             ),
//           ),

//           InkWell(
//             onTap: () {
//               // Dialog opening works
//               Get.dialog(FilterDialog());
//             },
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               decoration: BoxDecoration(
//                 color: const Color(0xFFD81B60), // Filter button color
//                 borderRadius: BorderRadius.circular(4),
//               ),
//               child: Row(
//                 children: const [
//                   Icon(Icons.filter_list, color: Colors.white, size: 16),
//                   SizedBox(width: 6),
//                   Text(
//                     "Filters",
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 13,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }
// import 'package:flutter/material.dart';

// class SearchBarWithFilter extends StatelessWidget {
//   final String hintText;
//   final ValueChanged<String>? onSearchChanged;
//   final VoidCallback? onFilterTap;
//   final double? maxWidth;

//   const SearchBarWithFilter({
//     super.key,
//     this.hintText = "Search...",
//     this.onSearchChanged,
//     this.onFilterTap,
//     this.maxWidth,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final screenWidth = MediaQuery.of(context).size.width;

//     // Responsive width
//     double width;
//     if (screenWidth >= 1200) {
//       // Desktop
//       width = maxWidth ?? 600;
//     } else if (screenWidth >= 800) {
//       // Tablet
//       width = screenWidth * 0.7;
//     } else {
//       // Mobile
//       width = screenWidth * 0.95;
//     }

//     return Center(
//       child: Container(
//         width: width,
//         decoration: BoxDecoration(
//           color: theme.colorScheme.surface,
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(color: Colors.grey.withOpacity(0.2)),
//         ),
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//         child: Row(
//           children: [
//             // Search Field
//             Expanded(
//               child: TextField(
//                 onChanged: onSearchChanged,
//                 decoration: InputDecoration(
//                   hintText: hintText,
//                   border: InputBorder.none,
//                 ),
//               ),
//             ),

//             // Filter Button
//             InkWell(
//               onTap: onFilterTap,
//               child: Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 8,
//                 ),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFD81B60),
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//                 child: Row(
//                   children: const [
//                     Icon(Icons.filter_list, color: Colors.white, size: 16),
//                     SizedBox(width: 6),
//                     Text(
//                       "Filters",
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 13,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
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
