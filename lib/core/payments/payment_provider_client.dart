import 'payment_context.dart';
import 'payment_provider.dart';
import 'payment_start_result.dart';

abstract class PaymentProviderClient {
  PaymentProvider get provider;

  Future<PaymentStartResult> start({
    required PaymentContext context,
    required String referenceId,
  });
}
