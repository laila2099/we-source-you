// import 'package:we_source_you/model/job_post_model.dart';

// class JobSearchModel {
//   final String id;
//   final String title;
//   final String country;
//   final String jobType;
//   final int salary;
//   final String mediaType;

//   JobSearchModel({
//     required this.id,
//     required this.title,
//     required this.country,
//     required this.jobType,
//     required this.salary,
//     required this.mediaType,
//   });

//   factory JobSearchModel.fromPost(JobPostModel post) {
//     return JobSearchModel(
//       id: post.id ?? '',
//       title: post.title,
//       country: post.locations.isNotEmpty ? post.locations.first : 'Remote',
//       jobType: post.jobType,
//       salary: post.minSalary?.toInt() ?? 0,
//       mediaType: post.mediaTypes.isNotEmpty ? post.mediaTypes.first : '',
//     );
//   }
// }
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
  });

  factory JobSearchModel.fromPost(JobPostModel post) {
    return JobSearchModel(
      title: post.title,
      publisherName: post.contactName,
      details: post.description,
      postedDate: post.startDate ?? DateTime.now(),
      salary: post.minSalary?.toDouble() ?? 0,
      locationType: post.jobLocationType.isNotEmpty
          ? post.jobLocationType
          : 'Remote',
      country: post.jobLocationType.isNotEmpty
          ? post.jobLocationType
          : 'Remote',
      mediaType: post.mediaTypes.isNotEmpty ? post.mediaTypes.first : 'Unknown',
      jobType: post.jobType,
    );
  }
}
