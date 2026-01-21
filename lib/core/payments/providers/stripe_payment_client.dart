import 'package:cloud_functions/cloud_functions.dart';

import '../payment_context.dart';
import '../payment_provider.dart';
import '../payment_provider_client.dart';
import '../payment_start_result.dart';

class StripePaymentClient implements PaymentProviderClient {
  @override
  PaymentProvider get provider => PaymentProvider.stripe;

  final FirebaseFunctions functions;
  final bool isWeb;
  final String successUrl;
  final String cancelUrl;

  StripePaymentClient({
    required this.functions,
    required this.isWeb,
    required this.successUrl,
    required this.cancelUrl,
  });

  @override
  Future<PaymentStartResult> start({
    required PaymentContext context,
    required String referenceId,
  }) async {
    if (isWeb) {
      final res = await functions.httpsCallable('createCheckoutSession').call({
        'context': context.name,
        'referenceId': referenceId,
        'successUrl': successUrl,
        'cancelUrl': cancelUrl,
      });

      final data = Map<String, dynamic>.from(res.data as Map);
      return PaymentStartResult(
        provider: provider,
        paymentRef: (data['sessionId'] ?? '') as String,
        redirectUrl: data['url'] as String?,
      );
    }

    final res = await functions.httpsCallable('createPaymentIntent').call({
      'provider': 'stripe',
      'context': context.name,
      'referenceId': referenceId,
    });

    final data = Map<String, dynamic>.from(res.data as Map);
    return PaymentStartResult(
      provider: provider,
      paymentRef: data['paymentIntentId'] as String,
      clientSecret: data['clientSecret'] as String?,
    );
  }
}
