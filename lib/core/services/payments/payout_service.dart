import 'package:cloud_functions/cloud_functions.dart';

class PayoutService {
  final FirebaseFunctions _functions;

  PayoutService({FirebaseFunctions? functions})
    : _functions =
          functions ?? FirebaseFunctions.instanceFor(region: 'us-central1');

  Future<String?> sendPayout(String payoutId) async {
    final res = await _functions.httpsCallable('sendPayout').call({
      'payoutId': payoutId,
    });

    final data = Map<String, dynamic>.from(res.data as Map);
    // يرجع providerPayoutRef (transferId أو payoutBatchId)
    return data['providerPayoutRef'] as String?;
  }
}
