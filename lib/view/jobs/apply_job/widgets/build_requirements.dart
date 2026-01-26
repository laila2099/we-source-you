import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:we_source_you/core/constant/responsive_layout.dart';
import 'package:we_source_you/model/job_post_model.dart';
import 'package:we_source_you/view/jobs/apply_job/widgets/helper_widgets.dart';
import 'package:we_source_you/view/jobs/apply_job/widgets/info_tile.dart';
import 'package:we_source_you/view/jobs/apply_job/widgets/list_tile.dart';

Widget buildRequirements(JobPostModel job, BuildContext context) {
  final List<Widget> tiles = [];

  void addList(String title, List<String> items, IconData icon) {
    if (items.isNotEmpty) {
      tiles.add(listTile(title, items, icon));
    }
  }

  Widget addSingleValue(String title, String value, IconData icon) {
    if (value.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: Colors.grey),
            const SizedBox(width: 6),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Chip(label: Text(value)),
        const SizedBox(height: 16),
      ],
    );
  }

  void addInfo(String title, String value) {
    if (value.trim().isNotEmpty) {
      tiles.add(infoTile(title, value));
    }
  }

  void addBool(String title, bool value) {
    tiles.add(infoTile(title, value ? "Yes" : "No"));
  }

  addList("Skills", job.skills, Icons.sell);
  addList("Media Types", job.mediaTypes, Icons.work);
  addList("Languages", job.languages, Icons.language);
  addSingleValue("Location", job.jobLocationType, Icons.location_on);
  addList("Benefits", job.benefits, Icons.card_giftcard);
  addList("Categories", job.categories, Icons.category);
  addList("Tags", job.tags, Icons.tag);

  addInfo("Experience Level", job.experienceLevel);
  addInfo("Job Type", job.jobType);
  addInfo("Currency", job.currency);
  addInfo("Project Details", job.projectDetails);
  addInfo("Additional Info", job.additionalInfo);
  addInfo("Contact Name", job.contactName);
  addInfo("Contact Email", job.contactEmail);
  addInfo("Contact Phone", job.contactPhone);

  if (job.startDate != null) {
    addInfo("Start Date", formatDate(job.startDate));
  }
  if (job.endDate != null) {
    addInfo("End Date", formatDate(job.endDate));
  }

  addBool("Portfolio Required", job.portfolioRequired);
  addBool("Can Travel", job.canTravel);
  addBool("Has Camera", job.hasCamera);
  addBool("Has Audio", job.hasAudio);
  addBool("Urgent", job.isUrgent);
  addBool("Featured", job.isFeatured);

  if (tiles.isEmpty) return const SizedBox.shrink();

  final crossAxisCount = ResponsiveLayout.isDesktop(context)
      ? 3
      : ResponsiveLayout.isTablet(context)
      ? 2
      : 1;

  Widget content;

  if (ResponsiveLayout.isMobile(context)) {
    // على الموبايل: خليهم ياخدوا حجمهم الطبيعي
    content = Wrap(
      spacing: 12,
      runSpacing: 12,
      children: tiles.map((tile) {
        return IntrinsicWidth(child: tile);
      }).toList(),
    );
  } else {
    // على التابلت والديسكتوب: نستخدم MasonryGrid
    content = MasonryGridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      itemCount: tiles.length,
      itemBuilder: (context, index) {
        return tiles[index];
      },
    );
  }

  return Container(
    padding: const EdgeInsets.all(20),
    decoration: cardDecoration(const Color(0xFF7E72D6)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Job Details & Requirements",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        content,
      ],
    ),
  );
}
