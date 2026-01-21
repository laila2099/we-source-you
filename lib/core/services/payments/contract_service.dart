import 'package:cloud_functions/cloud_functions.dart';

class ContractService {
  ContractService({FirebaseFunctions? functions})
    : _functions =
          functions ?? FirebaseFunctions.instanceFor(region: 'us-central1');

  final FirebaseFunctions _functions;

  Future<void> submitDelivery({
    required String contractId,
    required String submissionType, // 'file' | 'link' | 'text'
    required dynamic
    submissionData, // Map / String / anything JSON-serializable
  }) async {
    final res = await _functions.httpsCallable('submitDelivery').call({
      'contractId': contractId,
      'submissionType': submissionType,
      'submissionData': submissionData,
    });

    final data = (res.data is Map)
        ? Map<String, dynamic>.from(res.data as Map)
        : null;
    if (data != null && data['ok'] == false) {
      throw Exception('submitDelivery failed: $data');
    }
  }

  Future<void> approveDelivery({required String contractId}) async {
    final res = await _functions.httpsCallable('approveDelivery').call({
      'contractId': contractId,
    });

    final data = (res.data is Map)
        ? Map<String, dynamic>.from(res.data as Map)
        : null;
    if (data != null && data['ok'] == false) {
      throw Exception('approveDelivery failed: $data');
    }
  }

  Future<void> confirmClose({required String contractId}) async {
    final res = await _functions.httpsCallable('confirmClose').call({
      'contractId': contractId,
    });

    final data = (res.data is Map)
        ? Map<String, dynamic>.from(res.data as Map)
        : null;
    if (data != null && data['ok'] == false) {
      throw Exception('confirmClose failed: $data');
    }
  }

  /// غالباً ما بتحتاجيه بالـ UI (confirmClose بيناديه)
  Future<String?> releasePayout({required String contractId}) async {
    final res = await _functions.httpsCallable('releasePayout').call({
      'contractId': contractId,
    });

    final data = Map<String, dynamic>.from(res.data as Map);
    return data['payoutId'] as String?;
  }
}
