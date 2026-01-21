// core/services/payments/payment_service.dart
import 'dart:html' as html;

import 'package:cloud_functions/cloud_functions.dart';

import '../../payments/payment_context.dart';
import '../../payments/payment_provider.dart';

class PaymentService {
  PaymentService({FirebaseFunctions? functions})
    : _functions =
          functions ?? FirebaseFunctions.instanceFor(region: 'us-central1');

  final FirebaseFunctions _functions;

  /// ✅ Web checkout (Stripe/PayPal) — redirect
  Future<void> startWebCheckout({
    required PaymentProvider provider,
    required PaymentContext context,
    required String referenceId,
    required String successUrl,
    required String cancelUrl,
  }) async {
    if (provider == PaymentProvider.stripe) {
      final res = await _functions.httpsCallable('createCheckoutSession').call({
        'context': context.name,
        'referenceId': referenceId,
        'successUrl': successUrl,
        'cancelUrl': cancelUrl,
      });

      final data = Map<String, dynamic>.from(res.data as Map);
      final url = data['url'] as String?;
      if (url == null || url.isEmpty) {
        throw Exception('Stripe checkout: missing url');
      }
      html.window.location.href = url;
      return;
    }

    if (provider == PaymentProvider.paypal) {
      final res = await _functions.httpsCallable('createPayPalOrder').call({
        'context': context.name,
        'referenceId': referenceId,
        'returnUrl': successUrl,
        'cancelUrl': cancelUrl,
      });

      final data = Map<String, dynamic>.from(res.data as Map);
      final approveUrl = data['approveUrl'] as String?;
      if (approveUrl == null || approveUrl.isEmpty) {
        throw Exception('PayPal order: missing approveUrl');
      }
      html.window.location.href = approveUrl;
      return;
    }

    throw Exception('Unsupported provider: $provider');
  }

  /// ✅ Mobile PaymentIntent (future / optional)
  Future<Map<String, dynamic>> createPaymentIntent({
    required PaymentProvider provider,
    required PaymentContext context,
    required String referenceId,
  }) async {
    final res = await _functions.httpsCallable('createPaymentIntent').call({
      'provider': provider.name,
      'context': context.name,
      'referenceId': referenceId,
    });

    if (res.data == null) {
      throw Exception('createPaymentIntent: res.data is null');
    }
    return Map<String, dynamic>.from(res.data as Map);
  }
}
