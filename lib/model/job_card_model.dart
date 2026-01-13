import 'package:we_source_you/model/job_post_model.dart';
import 'package:we_source_you/model/job_search_model.dart';

class JobCardModel {
  final String? id; // معرف الوظيفة
  final String title; // اسم الوظيفة
  final String publisherName; // اسم الشركة أو الشخص الناشر
  final String details; // تفاصيل الوظيفة
  final DateTime postedDate; // تاريخ النشر
  final double budgetRange; // الميزانية
  final String locationType; // "Remote" أو "On-site"

  JobCardModel({
    this.id,
    required this.title,
    required this.publisherName,
    required this.details,
    required this.postedDate,
    required this.budgetRange,
    required this.locationType,
  });

  factory JobCardModel.fromPost(JobPostModel post) {
    return JobCardModel(
      id: post.id,
      title: post.title,
      publisherName: post.contactName,
      details: post.description,
      postedDate: post.startDate ?? DateTime.now(),
      budgetRange: post.minSalary?.toDouble() ?? 0,
      locationType: post.jobLocationType.isNotEmpty
          ? post.jobLocationType
          : 'Remote',
    );
  }
  factory JobCardModel.fromSearch(JobSearchModel job) {
    return JobCardModel(
      id: null, // JobSearchModel doesn't have id, will need to match by other fields
      title: job.title,
      publisherName: job.publisherName,
      details: job.details,
      locationType: job.locationType,
      budgetRange: job.salary.toDouble(),
      postedDate: job.postedDate,
    );
  }
}
