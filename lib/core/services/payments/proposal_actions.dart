// core/utils/proposal_actions.dart
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../payments/payment_context.dart';
import '../../payments/payment_provider.dart';
import 'payment_service.dart';
import 'proposal_service.dart';

class ProposalActions {
  final ProposalService _proposalService;
  final PaymentService _paymentService;
  final FirebaseFirestore _db;

  ProposalActions(
    this._proposalService,
    this._paymentService, {
    FirebaseFirestore? db,
  }) : _db = db ?? FirebaseFirestore.instance;

  /// 1) accept proposal -> get contractId
  /// 2) start checkout redirect (web)
  Future<void> acceptAndPayWeb({
    required String proposalId,
    required PaymentProvider provider,
    required String baseUrl, // مثال: http://localhost:51405
  }) async {
    final contractId = await _proposalService.acceptProposal(proposalId);

    final successUrl = '$baseUrl/#/payment-success?contractId=$contractId';
    final cancelUrl = '$baseUrl/#/payment-cancel?contractId=$contractId';

    print(contractId);

    await _paymentService.startWebCheckout(
      provider: provider,
      context: PaymentContext.jobContract,
      referenceId: contractId,
      successUrl: successUrl,
      cancelUrl: cancelUrl,
    );
  }

  /// يستعمل داخل PaymentSuccessPage:
  /// يرجع conversationId لما يصير funded
  Stream<String> waitForConversationId(String contractId) async* {
    final docStream = _db.collection('contracts').doc(contractId).snapshots();

    await for (final snap in docStream) {
      final data = snap.data();
      print(data);
      if (data == null) continue;

      final status = data['status'];
      final conversationId = data['conversationId'];

      if (status == 'funded' &&
          conversationId is String &&
          conversationId.isNotEmpty) {
        print(conversationId);
        yield conversationId;
        return;
      }
    }
  }
}
