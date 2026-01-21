import 'package:cloud_functions/cloud_functions.dart';

class ProposalService {
  ProposalService({FirebaseFunctions? functions})
    : _functions =
          functions ?? FirebaseFunctions.instanceFor(region: 'us-central1');

  final FirebaseFunctions _functions;

  Future<String> acceptProposal(String proposalId) async {
    final res = await _functions.httpsCallable('acceptProposal').call({
      'proposalId': proposalId,
    });
    print("res");

    final data = Map<String, dynamic>.from(res.data as Map);
    final contractId = data['contractId'] as String?;
    if (contractId == null || contractId.isEmpty) {
      throw Exception('acceptProposal: missing contractId');
    }
    return contractId;
  }
}
