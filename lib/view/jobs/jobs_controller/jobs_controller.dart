// import 'package:get/get.dart';
// import 'package:we_source_you/data/repositories/jobs_repository.dart';
// import 'package:we_source_you/model/job_card_model.dart';
// import 'package:we_source_you/model/job_post_model.dart';
// import 'package:we_source_you/model/job_search_model.dart';

// class JobsController extends GetxController {
//   final JobsRepository _repo = JobsRepository();
//   final featuredJobs = <JobCardModel>[].obs;

//   var allPosts = <JobPostModel>[].obs;
//   var jobsForCard = <JobCardModel>[].obs;
//   var jobsForSearch = <JobSearchModel>[].obs;
//   var isLoading = false.obs;

//   @override
//   void onInit() {
//     super.onInit();
//     fetchAllJobs();
//   }

//   Future<void> fetchAllJobs() async {
//     try {
//       isLoading.value = true;

//       // 1️⃣ Fetch all posts
//       final posts = await _repo.fetchJobs();
//       allPosts.value = posts;

//       // 2️⃣ Map to card models for UI
//       jobsForCard.value = posts.map((p) => JobCardModel.fromPost(p)).toList();

//       // 3️⃣ Map to search models for filtering
//       jobsForSearch.value = posts
//           .map((p) => JobSearchModel.fromPost(p))
//           .toList();

//       // 4️⃣ Take first 4 for featured jobs
//       featuredJobs.assignAll(
//         posts.take(4).map((p) => JobCardModel.fromPost(p)).toList(),
//       );
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   List<JobSearchModel> filterJobs({
//     String? title,
//     String? jobType,
//     int? minSalary,
//     List<String>? countries,
//     List<String>? mediaTypes,
//   }) {
//     return jobsForSearch.where((job) {
//       if (title != null && title.isNotEmpty && !job.title.contains(title)) {
//         return false;
//       }
//       if (jobType != null && jobType != 'Any' && job.jobType != jobType) {
//         return false;
//       }
//       if (minSalary != null && job.salary < minSalary) {
//         return false;
//       }
//       if (countries != null &&
//           countries.isNotEmpty &&
//           !countries.contains(job.country)) {
//         return false;
//       }
//       if (mediaTypes != null &&
//           mediaTypes.isNotEmpty &&
//           !mediaTypes.contains(job.mediaType)) {
//         return false;
//       }
//       return true;
//     }).toList();
//   }

//   void goBack() => Get.back();

//   void viewMoreJobs() => Get.toNamed('/all-jobs');
//   String avatarLetter(JobCardModel job) {
//     if (job.publisherName.isNotEmpty) {
//       return job.publisherName[0].toUpperCase();
//     }
//     return '?';
//   }

//   void applyForJob(JobCardModel job) {
//     Get.snackbar("Apply", "Applying for ${job.title} at ${job.publisherName}");
//   }
// }
import 'package:get/get.dart';
import 'package:we_source_you/data/repositories/jobs_repository.dart';
import 'package:we_source_you/model/job_card_model.dart';
import 'package:we_source_you/model/job_post_model.dart';
import 'package:we_source_you/model/job_search_model.dart';
import 'package:we_source_you/routes/app_routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class JobsController extends GetxController {
  final JobsRepository _repo = JobsRepository();
  final featuredJobs = <JobCardModel>[].obs;

  var allPosts = <JobPostModel>[].obs;
  var jobsForCard = <JobCardModel>[].obs;
  var jobsForSearch = <JobSearchModel>[].obs;
  var isLoading = false.obs;

  final String title = "صحفي لقاءات";
  final String priceRange = "\$1000 - \$3000";
  final List<String> skills = ["Live Broadcasting", "Interviewing"];
  final List<String> languages = ["English", "French", "Arabic"];

  // ✅ Visible list after filters/search
  final visibleCards = <JobCardModel>[].obs;

  // ✅ Stored filters
  String _searchQuery = '';
  String _jobType = 'Any';
  int? _minSalary;
  int? _maxSalary;
  List<String> _countries = [];
  List<String> _mediaTypes = [];
  String _location = '';

  @override
  void onInit() {
    super.onInit();
    fetchAllJobs();
  }

  Future<void> fetchAllJobs() async {
    try {
      isLoading.value = true;

      // 1️⃣ Fetch all posts
      final posts = await _repo.fetchJobs();
      allPosts.value = posts;

      // 2️⃣ Map to card models for UI
      jobsForCard.value = posts.map((p) => JobCardModel.fromPost(p)).toList();

      // 3️⃣ Map to search models for filtering
      jobsForSearch.value = posts
          .map((p) => JobSearchModel.fromPost(p))
          .toList();

      // 4️⃣ Take first 4 for featured jobs
      featuredJobs.assignAll(
        posts.take(4).map((p) => JobCardModel.fromPost(p)).toList(),
      );

      // 5️⃣ Initialize visible list
      _recomputeVisible();
    } finally {
      isLoading.value = false;
    }
  }

  // 🔍 Search text from search bar
  void updateSearchQuery(String query) {
    _searchQuery = query;
    _fetchFilteredFromRemote();
  }

  // 🔥 Production-ready filters (client-side for now)
  void applyAdvancedFilters({
    String? jobType,
    int? minSalary,
    int? maxSalary,
    List<String>? countries,
    List<String>? mediaTypes,
    String? location,
  }) {
    _jobType = jobType ?? _jobType;
    _minSalary = minSalary;
    _maxSalary = maxSalary;
    _countries = countries ?? _countries;
    _mediaTypes = mediaTypes ?? _mediaTypes;
    _location = location ?? _location;
    _fetchFilteredFromRemote();
  }

  // 🔄 Clear filters (keep data)
  void clearFilters() {
    _searchQuery = '';
    _jobType = 'Any';
    _minSalary = null;
    _maxSalary = null;
    _countries = [];
    _mediaTypes = [];
    _location = '';
    fetchAllJobs();
  }

  Future<void> _fetchFilteredFromRemote() async {
    try {
      isLoading.value = true;

      final posts = await _repo.fetchJobsWithFilters(
        search: _searchQuery,
        jobType: _jobType,
        minSalary: _minSalary,
        maxSalary: _maxSalary,
        countries: _countries,
        mediaTypes: _mediaTypes,
      );

      allPosts.value = posts;
      jobsForSearch.value = posts
          .map((p) => JobSearchModel.fromPost(p))
          .toList();
      jobsForCard.value = posts.map((p) => JobCardModel.fromPost(p)).toList();

      _recomputeVisible();
    } on FirebaseException catch (e) {
      Get.snackbar('Error', e.message ?? 'Filter error');
    } finally {
      isLoading.value = false;
    }
  }

  void _recomputeVisible() {
    final selectedJobType = _normalize(_jobType);
    final searchLower = _searchQuery.toLowerCase();
    final locationLower = _location.toLowerCase();

    final results = jobsForSearch.where((job) {
      if (searchLower.isNotEmpty &&
          !job.title.toLowerCase().contains(searchLower)) {
        return false;
      }

      // Job type match (case-insensitive, ignore spaces/dashes)
      if (selectedJobType.isNotEmpty &&
          selectedJobType != 'any' &&
          _normalize(job.jobType) != selectedJobType) {
        return false;
      }

      if (_minSalary != null && job.salary < _minSalary!) {
        return false;
      }

      if (_maxSalary != null && job.salary > _maxSalary!) {
        return false;
      }

      if (_countries.isNotEmpty && !_countries.contains(job.country)) {
        return false;
      }

      if (_mediaTypes.isNotEmpty && !_mediaTypes.contains(job.mediaType)) {
        return false;
      }

      if (_location.isNotEmpty &&
          !job.locationType.toLowerCase().contains(locationLower)) {
        return false;
      }

      return true;
    }).toList();

    visibleCards.assignAll(
      results.map((e) => JobCardModel.fromSearch(e)).toList(),
    );

    // Keep featured in sync (top 4)
    featuredJobs.assignAll(visibleCards.take(4).toList());
  }

  String _normalize(String value) =>
      value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

  void goBack() => Get.back();

  void viewMoreJobs() => Get.toNamed(AppRoutes.jobs);

  String avatarLetter(JobCardModel job) {
    if (job.publisherName.isNotEmpty) {
      return job.publisherName[0].toUpperCase();
    }
    return '?';
  }

  void applyForJob(JobCardModel job) {
    // Find the corresponding JobPostModel
    JobPostModel? jobPost;

    if (job.id != null) {
      // Try to find by id first
      try {
        jobPost = allPosts.firstWhere((post) => post.id == job.id);
      } catch (e) {
        // Not found by id, continue to search by other fields
      }
    }

    // If not found by id, try to match by title and publisher name
    if (jobPost == null) {
      try {
        jobPost = allPosts.firstWhere(
          (post) =>
              post.title == job.title && post.contactName == job.publisherName,
        );
      } catch (e) {
        // Not found
      }
    }

    if (jobPost != null) {
      // Navigate to job apply page with the job details
      Get.toNamed(AppRoutes.applyJob, arguments: jobPost);
    } else {
      Get.snackbar("Error", "Job details not found");
    }
  }
}
