import 'payment_provider.dart';

class PaymentStartResult {
  final PaymentProvider provider;

  /// Reference on provider side:
  /// - Stripe: paymentIntentId or checkoutSessionId
  /// - PayPal: orderId
  final String paymentRef;

  /// For Web redirect flows (Stripe Checkout / PayPal approve URL)
  final String? redirectUrl;

  /// For mobile-native flows (Stripe PaymentSheet)
  final String? clientSecret;

  const PaymentStartResult({
    required this.provider,
    required this.paymentRef,
    this.redirectUrl,
    this.clientSecret,
  });

  bool get isRedirectFlow => redirectUrl != null;
  bool get isClientSecretFlow => clientSecret != null;
}
