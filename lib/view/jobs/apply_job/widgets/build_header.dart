import 'package:flutter/material.dart';
import 'package:we_source_you/model/job_post_model.dart';
import 'package:we_source_you/view/jobs/apply_job/widgets/helper_widgets.dart';

Widget buildHeader(JobPostModel job) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: cardDecoration(Colors.white),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          job.title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        // داخل _buildHeader
        Row(
          children: [
            if (job.createdAt != null) ...[
              statusBadgeFromDate(job.createdAt, Colors.green),
              const SizedBox(width: 10),
              Text(
                "Posted ${formatDate(job.createdAt)}",
                style: const TextStyle(color: Colors.grey),
              ),
            ] else ...[
              // إذا كان نول، نظهر مؤشر تحميل صغير أو نص مؤقت
              const SizedBox(
                width: 15,
                height: 15,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 10),
              const Text(
                "Loading date...",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: cardDecoration(const Color(0xFFEDF2F7)),
          child: Text(
            "\$${job.minSalary ?? 0} - \$${job.maxSalary ?? 0} ${job.currency}",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );
}
