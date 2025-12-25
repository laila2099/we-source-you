import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:we_source_you/view/media_market/filer_section/filter_section.dart';
import 'package:we_source_you/view/media_market/media_market_controller/media_market_controller.dart';
import 'package:we_source_you/view/media_market/widgets/build_categorygrid.dart';
import 'package:we_source_you/view/media_market/widgets/build_discovergrid.dart';
import 'package:we_source_you/view/media_market/widgets/build_featured.dart';
import 'package:we_source_you/view/media_market/widgets/build_header.dart';
import 'package:we_source_you/view/media_market/widgets/build_searchbar.dart';
import 'package:we_source_you/view/media_market/widgets/build_section_title.dart';

Widget buildMainContent(BuildContext context) {
  final theme = Theme.of(context);
  final MediaController controller = Get.find();

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 40),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            iconSize: 18,
            color: theme.textTheme.bodySmall?.color,
            onPressed: controller.goBack,
            icon: const Icon(Icons.arrow_back),
          ),
          buildHeader(context),
        ],
      ),
      const SizedBox(height: 30),
      SearchBarWithFilter(
        onSearchChanged: (value) => controller.searchQuery.value = value,
        onFilterTap: () => Get.dialog(FilterDialog()),
      ),
      const SizedBox(height: 40),
      buildSectionTitle("Featured Media", context),
      buildFeaturedList(),
      const SizedBox(height: 40),
      buildSectionTitle("Search by category", context),
      buildCategoryGrid(),
      const SizedBox(height: 40),
      buildSectionTitle("Discover", context),
      buildDiscoverGrid(),
      const SizedBox(height: 60),
      const Center(
        child: Text(
          "No more media to load",
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ),
      const SizedBox(height: 40),
    ],
  );
}
