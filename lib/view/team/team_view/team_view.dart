import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:we_source_you/core/constant/app_color.dart';
import 'package:we_source_you/view/team/team_controller/team_controller.dart';
import 'package:we_source_you/core/constant/responsive_layout.dart';
import 'package:we_source_you/view/team/team_page.dart';
import 'package:we_source_you/view/media_market/widgets/build_searchbar.dart';

class TeamView extends StatefulWidget {
  const TeamView({super.key});

  @override
  State<TeamView> createState() => _TeamViewState();
}

class _TeamViewState extends State<TeamView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final TeamController controller = Get.find<TeamController>();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: Get.back,
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text("Team Board"),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        // foregroundColor: Colors.black,
      ),

      // Mobile drawer
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SearchBarWithFilter(
              hintText: "Search for team members...",
              onSearchChanged: (value) {
                controller.updateSearchQuery(value);
              },
              onFilterTap: () {
                // Show TeamFilterSidebar as dialog
                Get.dialog(
                  Dialog(
                    insetPadding: const EdgeInsets.all(24),
                    child: SizedBox(
                      width: 320,
                      child: SingleChildScrollView(child: TeamFilterSidebar()),
                    ),
                  ),
                );
              },
              maxWidth: 600,
              showFilterButton: !isDesktop,
            ),
          ),

          const SizedBox(height: 16),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Desktop sidebar always visible
                if (isDesktop)
                  const SizedBox(
                    width: 320,
                    child: SingleChildScrollView(child: TeamFilterSidebar()),
                  ),

                if (isDesktop)
                  VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: Colors.grey.shade300,
                  ),

                // Team results
                const Expanded(child: TeamResultsList()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
