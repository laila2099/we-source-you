import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:we_source_you/core/constant/app_color.dart';
import 'package:we_source_you/core/constant/responsive_layout.dart';
import 'package:we_source_you/model/job_card_model.dart';
import 'package:we_source_you/view/jobs/jobs_controller/jobs_controller.dart';
import 'package:we_source_you/widgets/circular_icon/Circular_icon.dart';
import 'package:we_source_you/widgets/glass_morphism.dart';

class FeaturedJobsView extends StatelessWidget {
  FeaturedJobsView({super.key});
  final JobsController controller = Get.find<JobsController>();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<JobsController>();
    final padding = ResponsiveLayout.screenPadding(context);

    return Container(
      padding: padding,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          // Header
          Text(
            'Featured Jobs'.tr,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          Text(
            'Discover exciting opportunities from top media companies'.tr,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: ResponsiveLayout.isMobile(context) ? 16 : 18,
              fontWeight: FontWeight.normal,
            ),
          ),
          const SizedBox(height: 40),

          // Jobs Grid like Journalists
          Obx(() {
            final items = controller.featuredJobs;
            return Center(
              child: Wrap(
                spacing: 30,
                runSpacing: 30,
                alignment: WrapAlignment.center,
                children: [
                  for (final job in items)
                    SizedBox(
                      width: ResponsiveLayout.isDesktop(context)
                          ? 320
                          : ResponsiveLayout.isTablet(context)
                          ? 280
                          : MediaQuery.of(context).size.width * 0.9,
                      child: JobCard(job: job),
                    ),
                ],
              ),
            );
          }),
          const SizedBox(height: 30),

          // View More Button
          OutlinedButton(
            onPressed: controller.viewMoreJobs,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.lightBlue,
              side: const BorderSide(color: AppColors.lightBlue),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: const Text(
              'View More Jobs',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------- Individual Job Card -------------------

class JobCard extends GetView<JobsController> {
  final JobCardModel job;
  const JobCard({required this.job});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Initials & Company
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircularIcon(
                gradientColors: [AppColors.lightBlue, const Color(0xFF9B27B0)],
                child: Center(
                  child: Text(
                    controller.avatarLetter(job),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.publisherName,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          job.locationType,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Budget: ${job.budgetRange}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Job Title
          Text(
            job.title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 10),

          // Stats (e.g., Posted Date, Contract)
          _StatColumn(
            count:
                '${job.postedDate.day}/${job.postedDate.month}/${job.postedDate.year}',
            label: 'Posted',
          ),
          const SizedBox(height: 10),
          const Divider(),
          const SizedBox(height: 10),

          // Apply Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => controller.applyForJob(job),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: const Text(
                'Apply Now',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------- Reusable Stat Column -------------------
class _StatColumn extends StatelessWidget {
  final String count;
  final String label;
  const _StatColumn({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}
