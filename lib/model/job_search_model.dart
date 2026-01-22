import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:we_source_you/model/job_post_model.dart';

class JobSearchModel {
  final String title;
  final String publisherName;
  final String details;
  final DateTime postedDate;
  final double salary;
  final String locationType;
  final String country;
  final String mediaType;
  final String jobType;
  final String? id;
  final DateTime? startDate;
  final DateTime? endDate;

  JobSearchModel({
    required this.title,
    required this.publisherName,
    required this.details,
    required this.postedDate,
    required this.salary,
    required this.locationType,
    required this.country,
    required this.mediaType,
    required this.jobType,
    this.id,
    this.endDate,
    this.startDate,
  });

  factory JobSearchModel.fromPost(JobPostModel post) {
    return JobSearchModel(
      id: post.id,
      title: post.title,
      publisherName: post.contactName,
      details: post.description,
      postedDate: post.createdAt ?? DateTime.now(),
      salary: post.minSalary?.toDouble() ?? 0,
      locationType: post.jobLocationType.isNotEmpty
          ? post.jobLocationType
          : 'Remote',
      country: post.jobLocationType,
      mediaType: post.mediaTypes.isNotEmpty ? post.mediaTypes.first : 'Unknown',
      jobType: post.jobType,

      // ✅✅ تأكد من وجود هذين السطرين لنقل البيانات من Post إلى Search
      startDate: post.startDate,
      endDate: post.endDate,
    );
  }
  factory JobSearchModel.fromMap(Map<String, dynamic> data) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    return JobSearchModel(
      id: data['id'],
      title: data['title'] ?? '',
      publisherName: data['publisherName'] ?? '',
      details: data['details'] ?? '',
      postedDate: parseDate(data['postedDate']) ?? DateTime.now(),
      salary: (data['salary'] ?? 0).toDouble(),
      locationType: data['locationType'] ?? 'Remote',
      country: data['country'] ?? '',
      mediaType: data['mediaType'] ?? '',
      jobType: data['jobType'] ?? '',
      startDate: parseDate(data['startDate']), // ✅
      endDate: parseDate(data['endDate']), // ✅
    );
  }
}
