enum PaymentMethod { stripe, paypal }

enum MarketItemType { media, hiring, proposal }

class PaymentResult {
  final bool success;
  final String? message;
  final String? transactionId; // paymentIntentId or orderId

  PaymentResult({required this.success, this.message, this.transactionId});
}

class PaypalOrderResponse {
  final String orderId;
  final String? approvalUrl;

  PaypalOrderResponse({required this.orderId, this.approvalUrl});

  factory PaypalOrderResponse.fromMap(Map<String, dynamic> map) {
    return PaypalOrderResponse(
      orderId: map['orderId'] ?? '',
      approvalUrl: map['approvalUrl'],
    );
  }
}

class StripeEscrowResponse {
  final String clientSecret;
  final String paymentIntentId;

  StripeEscrowResponse({
    required this.clientSecret,
    required this.paymentIntentId,
  });

  factory StripeEscrowResponse.fromMap(Map<String, dynamic> map) {
    return StripeEscrowResponse(
      clientSecret: map['clientSecret'] ?? '',
      paymentIntentId: map['paymentIntentId'] ?? '',
    );
  }
}
