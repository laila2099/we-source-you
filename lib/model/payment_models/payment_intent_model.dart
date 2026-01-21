import '../../core/payments/payment_context.dart';
import '../../core/payments/payment_provider.dart';

class AppPaymentIntent {
  final String id;
  final PaymentProvider provider;
  final PaymentContext context;
  final String referenceId; // itemId | contractId | hireId
  final double amount;
  final String currency;
  final String status; // created | requires_action | succeeded | failed
  final DateTime createdAt;

  AppPaymentIntent({
    required this.id,
    required this.provider,
    required this.context,
    required this.referenceId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.createdAt,
  });

  factory AppPaymentIntent.fromJson(String id, Map<String, dynamic> json) {
    return AppPaymentIntent(
      id: id,
      provider: PaymentProvider.values.byName(json['provider']),
      context: PaymentContext.values.byName(json['context']),
      referenceId: json['referenceId'],
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'],
      status: json['status'],
      createdAt: json['createdAt'].toDate(),
    );
  }
}
