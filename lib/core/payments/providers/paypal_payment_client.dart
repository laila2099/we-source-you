import 'package:cloud_functions/cloud_functions.dart';

import '../payment_context.dart';
import '../payment_provider.dart';
import '../payment_provider_client.dart';
import '../payment_start_result.dart';

class PayPalPaymentClient implements PaymentProviderClient {
  @override
  PaymentProvider get provider => PaymentProvider.paypal;

  final FirebaseFunctions functions;
  final String returnUrl;
  final String cancelUrl;

  PayPalPaymentClient({
    required this.functions,
    required this.returnUrl,
    required this.cancelUrl,
  });

  @override
  Future<PaymentStartResult> start({
    required PaymentContext context,
    required String referenceId,
  }) async {
    final res = await functions.httpsCallable('createPayPalOrder').call({
      'context': context.name,
      'referenceId': referenceId,
      'returnUrl': returnUrl,
      'cancelUrl': cancelUrl,
    });

    final data = Map<String, dynamic>.from(res.data as Map);
    return PaymentStartResult(
      provider: provider,
      paymentRef: data['orderId'] as String,
      redirectUrl: data['approveUrl'] as String?,
    );
  }
}
