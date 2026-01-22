import 'package:we_source_you/model/job_post_model.dart';
import 'package:we_source_you/model/job_search_model.dart';

class JobCardModel {
  final String? id;
  final String title;
  final String publisherName;
  final String details;
  final DateTime postedDate;
  final double budgetRange;
  final String locationType;
  final DateTime? startDate;
  final DateTime? endDate;

  JobCardModel({
    this.id,
    required this.title,
    required this.publisherName,
    required this.details,
    required this.postedDate,
    required this.budgetRange,
    required this.locationType,
    this.startDate,
    this.endDate,
  });

  factory JobCardModel.fromPost(JobPostModel post) {
    return JobCardModel(
      id: post.id,
      title: post.title,

      publisherName: post.contactName,
      details: post.description,
      postedDate: post.createdAt ?? DateTime.now(),
      budgetRange: post.minSalary?.toDouble() ?? 0,
      locationType: post.jobLocationType.isNotEmpty
          ? post.jobLocationType
          : 'Remote',
      startDate: post.startDate,
      endDate: post.endDate,
    );
  }
  factory JobCardModel.fromSearch(JobSearchModel job) {
    return JobCardModel(
      id: job.id,
      title: job.title,
      publisherName: job.publisherName,
      details: job.details,
      locationType: job.locationType,
      budgetRange: job.salary.toDouble(),
      postedDate: job.postedDate,
      startDate: job.startDate,
      endDate: job.endDate,
    );
  }
}
