import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:we_source_you/routes/app_routes.dart';
import 'package:we_source_you/view/jobs/jobs_controller/jobs_controller.dart';
import 'package:we_source_you/core/constant/responsive_layout.dart';
import 'package:we_source_you/view/jobs/jobs_page.dart';
import 'package:we_source_you/view/media_market/widgets/build_searchbar.dart';
import 'package:we_source_you/widgets/custom_buttom/custom_buttom.dart';

class JobView extends StatefulWidget {
  const JobView({super.key});

  @override
  State<JobView> createState() => _JobViewState();
}

class _JobViewState extends State<JobView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<JobsController>()) {
      Get.put(JobsController());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final JobsController controller = Get.find<JobsController>();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(onPressed: Get.back, icon: Icon(Icons.arrow_back)),
        title: const Text("Job Board"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: WebHoverButton(
              width: 50.w,
              height: 30.h,
              text: "post job",
              onPressed: () => Get.toNamed(AppRoutes.post),
            ),
          ),
        ],
      ),

      // Mobile drawer
      body: Column(
        children: [
          SearchBarWithFilter(
            hintText: "Search for content...",
            onSearchChanged: (value) {
              controller.updateSearchQuery(value);
            },
            onFilterTap: () {
              // Show JobFilterSidebar as dialog
              Get.dialog(
                Dialog(
                  insetPadding: const EdgeInsets.all(24),
                  child: SizedBox(
                    width: 320,
                    child: SingleChildScrollView(child: JobFilterSidebar()),
                  ),
                ),
              );
            },
            maxWidth: 600,
            showFilterButton: !isDesktop, // ✅ تظهر فقط على الموبايل
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
                    child: SingleChildScrollView(child: JobFilterSidebar()),
                  ),

                if (isDesktop)
                  VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: Colors.grey.shade300,
                  ),

                // Job results
                const Expanded(child: JobResultsList()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
