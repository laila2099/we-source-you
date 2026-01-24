import 'package:cloud_functions/cloud_functions.dart';

import '../../payments/payment_context.dart';
import '../../payments/payment_provider.dart';
import 'payment_service.dart';

class HireMeService {
  final FirebaseFunctions _fn = FirebaseFunctions.instanceFor(
    region: 'us-central1',
  );
  final PaymentService _paymentService = PaymentService();

  Future<String> createHireMeContract({
    required String freelancerId,
    required String pricingType, // 'hourly' | 'daily' | 'project'
  }) async {
    final res = await _fn.httpsCallable('createHireMeContract').call({
      'freelancerId': freelancerId,
      'pricingType': pricingType,
    });
    return (res.data['contractId'] as String);
  }

  Future<void> startInitialPayWeb({
    required String contractId,
    required PaymentProvider provider,
    required String baseUrl,
  }) async {
    final successUrl = '$baseUrl/#/payment-success?contractId=$contractId';
    final cancelUrl = '$baseUrl/#/payment-cancel?contractId=$contractId';

    await _paymentService.startWebCheckout(
      provider: provider,
      context: PaymentContext.hireMe,
      referenceId: contractId,
      successUrl: successUrl,
      cancelUrl: cancelUrl,
    );
  }

  /// ✅ مثل acceptAndPayWeb تبع proposal:
  /// 1) create contract
  /// 2) start checkout
  Future<void> hireAndPayWeb({
    required String freelancerId,
    required String pricingType,
    required PaymentProvider provider,
    required String baseUrl,
  }) async {
    print(freelancerId);
    final contractId = await createHireMeContract(
      freelancerId: freelancerId,
      pricingType: pricingType,
    );

    print(freelancerId);

    await startInitialPayWeb(
      contractId: contractId,
      provider: provider,
      baseUrl: baseUrl,
    );
  }

  Future<void> sendOffer({
    required String conversationId,
    int? quantity,
    double? totalAmount,
    String? pricingType,
    String? notes,
  }) async {
    await _fn.httpsCallable('sendHireOfferByConversation').call({
      'conversationId': conversationId,
      'quantity': quantity,
      'totalAmount': totalAmount,
      'notes': notes,
    });
  }

  /// 1) accept offer => flips contract to paymentPendingRemaining + sets remainingDue
  /// 2) start checkout for remaining
  Future<void> acceptAndPayRemainingWeb({
    required String conversationId,
    required PaymentProvider provider,
    required String baseUrl,
  }) async {
    final res = await _fn
        .httpsCallable('acceptHireOfferPrepareRemainingPayment')
        .call({'conversationId': conversationId});

    final contractId = (res.data['contractId'] as String);

    final successUrl = '$baseUrl/#/payment-success?contractId=$contractId';
    final cancelUrl = '$baseUrl/#/payment-cancel?contractId=$contractId';

    await _paymentService.startWebCheckout(
      provider: provider,
      context: PaymentContext.hireMe,
      referenceId: contractId,
      successUrl: successUrl,
      cancelUrl: cancelUrl,
    );
  }

  Future<void> cancelNoAgreement({required String conversationId}) async {
    await _fn.httpsCallable('cancelHireNoAgreementByConversation').call({
      'conversationId': conversationId,
    });
  }

  Future<void> rejectOffer({
    required String conversationId,
    String reason = '',
  }) async {
    final fn = FirebaseFunctions.instance;
    await fn.httpsCallable('rejectHireOfferByConversation').call({
      'conversationId': conversationId,
      'reason': reason,
    });
  }
}
