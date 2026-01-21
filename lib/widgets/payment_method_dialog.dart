import 'package:flutter/material.dart';

import '../../../core/payments/payment_provider.dart';

Future<PaymentProvider?> showPaymentMethodDialog(BuildContext context) {
  return showDialog<PaymentProvider>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) {
      return AlertDialog(
        title: const Text('Choose payment method'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.credit_card),
              title: const Text('Credit / Debit Card'),
              subtitle: const Text('Stripe'),
              onTap: () => Navigator.pop(ctx, PaymentProvider.stripe),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet),
              title: const Text('PayPal'),
              subtitle: const Text('PayPal'),
              onTap: () => Navigator.pop(ctx, PaymentProvider.paypal),
            ),
          ],
        ),
      );
    },
  );
}
