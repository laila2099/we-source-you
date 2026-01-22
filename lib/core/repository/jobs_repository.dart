import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:we_source_you/model/job_post_model.dart';

class JobsRepository {
  final _db = FirebaseFirestore.instance;

  Future<void> addJob(JobPostModel post) async {
    await _db.collection('jobs').add(post.toMap());
  }

  Future<List<JobPostModel>> fetchJobs() async {
    final snapshot = await _db.collection('jobs').get();
    return snapshot.docs.map((e) {
      final data = e.data();
      return _mapDoc(e.id, data);
    }).toList();
  }

  Future<List<JobPostModel>> fetchJobsWithFilters({
    String? search,
    String? jobType,
    int? minSalary,
    int? maxSalary,
    List<String>? countries,
    List<String>? mediaTypes,
  }) async {
    Query query = _db.collection('jobs');

    if (search != null && search.isNotEmpty) {
      // Range query on title (requires Firestore index)
      query = query
          .where('title', isGreaterThanOrEqualTo: search)
          .where('title', isLessThanOrEqualTo: '$search\uf8ff');
    }

    if (minSalary != null) {
      query = query.where('minSalary', isGreaterThanOrEqualTo: minSalary);
    }

    if (maxSalary != null) {
      query = query.where('minSalary', isLessThanOrEqualTo: maxSalary);
    }

    if (countries != null && countries.isNotEmpty) {
      query = query.where('locations', arrayContainsAny: countries);
    }

    if (mediaTypes != null && mediaTypes.isNotEmpty) {
      query = query.where('mediaTypes', arrayContainsAny: mediaTypes);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((e) => _mapDoc(e.id, e.data() as Map<String, dynamic>))
        .toList();
  }

  JobPostModel _mapDoc(String id, Map<String, dynamic> data) {
    // نضيف الـ id للـ data map قبل إرسالها
    data['id'] = id;
    return JobPostModel.fromMap(data);
  }
}
