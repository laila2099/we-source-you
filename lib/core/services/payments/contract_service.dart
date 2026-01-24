import 'package:cloud_functions/cloud_functions.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ContractService {
  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(
    region: 'us-central1',
  );

  Future<void> submitDeliveryByConversation({
    required String conversationId,
    required String submissionType,
    required Map<String, dynamic> submissionData,
  }) async {
    await _functions.httpsCallable('submitDeliveryByConversation').call({
      'conversationId': conversationId,
      'submissionType': submissionType,
      'submissionData': submissionData,
    });
  }

  Future<void> approveDeliveryByConversation({
    required String conversationId,
  }) async {
    await _functions.httpsCallable('approveDeliveryByConversation').call({
      'conversationId': conversationId,
    });
  }

  Future<void> confirmCloseByConversation({
    required String conversationId,
  }) async {
    await _functions.httpsCallable('confirmCloseByConversation').call({
      'conversationId': conversationId,
    });
  }

  Future<String> openDisputeByConversation({
    required String conversationId,
    required String reason,
  }) async {
    final res = await _functions
        .httpsCallable('openDisputeByConversation')
        .call({'conversationId': conversationId, 'reason': reason});
    final data = Map<String, dynamic>.from(res.data);
    return (data['disputeId'] ?? '').toString();
  }

  Future<String> getDeliveryDownloadUrlByConversation({
    required String conversationId,
    int fileIndex = 0,
  }) async {
    final res = await _functions
        .httpsCallable('getDeliveryDownloadUrlByConversation')
        .call({'conversationId': conversationId, 'fileIndex': fileIndex});

    final data = Map<String, dynamic>.from(res.data as Map);
    final url = data['url'] as String?;
    if (url == null || url.isEmpty) throw Exception('Missing signed url');
    return url;
  }

  /// Web upload: files bytes موجودة بـ PlatformFile.bytes
  Future<List<Map<String, dynamic>>> uploadDeliveryFilesWeb({
    required String conversationId,
    required List<PlatformFile> files,
  }) async {
    final storage = FirebaseStorage.instance;

    final uploaded = <Map<String, dynamic>>[];

    for (final f in files) {
      final bytes = f.bytes;
      if (bytes == null) {
        throw Exception('File bytes are null (use withData:true)');
      }

      final safeName = f.name.replaceAll('/', '_');
      final path =
          'deliveries/$conversationId/${DateTime.now().millisecondsSinceEpoch}_$safeName';

      final ref = storage.ref(path);
      await ref.putData(bytes);

      uploaded.add({'fileRef': path, 'name': f.name, 'size': f.size});
    }

    return uploaded;
  }

  Future<List<Map<String, dynamic>>> uploadDisputeEvidenceFilesWeb({
    required String conversationId,
    required List<PlatformFile> files,
  }) async {
    final storage = FirebaseStorage.instance;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('Not logged in');

    final uploaded = <Map<String, dynamic>>[];

    for (final f in files) {
      final bytes = f.bytes;
      if (bytes == null) {
        throw Exception('File bytes are null (use withData:true)');
      }

      final safeName = f.name.replaceAll('/', '_');

      // disputes/{conversationId}/{uid}/timestamp_filename
      final path =
          'disputes/$conversationId/$uid/${DateTime.now().millisecondsSinceEpoch}_$safeName';

      final ref = storage.ref(path);
      await ref.putData(bytes);

      uploaded.add({'fileRef': path, 'name': f.name, 'size': f.size});
    }

    return uploaded;
  }

  Future<void> submitDisputeMessageByConversation({
    required String conversationId,
    required String text,
    required List<Map<String, dynamic>> attachments,
  }) async {
    final functions = FirebaseFunctions.instanceFor(region: 'us-central1');
    await functions.httpsCallable('submitDisputeMessageByConversation').call({
      'conversationId': conversationId,
      'text': text,
      'attachments': attachments,
    });
  }

  Future<void> rejectDeliveryByConversation({
    required String conversationId,
    String reason = '',
  }) async {
    final fn = FirebaseFunctions.instance;
    await fn.httpsCallable('rejectDeliveryByConversation').call({
      'conversationId': conversationId,
      'reason': reason,
    });
  }

  Future<void> sendPayout({required String payoutId}) async {
    await FirebaseFunctions.instance.httpsCallable('sendPayout').call({
      'payoutId': payoutId,
    });
  }
}
