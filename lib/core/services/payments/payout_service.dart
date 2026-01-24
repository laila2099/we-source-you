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

  Future<Map<String, dynamic>> getPayoutSettings() async {
    final res = await FirebaseFunctions.instance
        .httpsCallable('getPayoutSettings')
        .call({});
    return Map<String, dynamic>.from(res.data);
  }

  Future<void> setDefaultPayoutProvider(String provider) async {
    await FirebaseFunctions.instance
        .httpsCallable('setDefaultPayoutProvider')
        .call({'provider': provider});
  }
}
