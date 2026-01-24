import 'package:flutter/material.dart';

import '../../../core/services/payments/payout_setup_service.dart';
import 'open_paypal_email_dialog.dart';

Future<bool> openPayoutSetupDialog(BuildContext context) async {
  final result = await showDialog(
    context: context,
    builder: (_) {
      return AlertDialog(
        title: const Text('Payout setup required'),
        content: const SizedBox(
          width: 520,
          child: Text(
            'Before we can transfer your earnings, choose a payout method.',
          ),
        ),
        actions: [
          OutlinedButton(
            onPressed: () async {
              // PayPal setup: ask email
              Navigator.pop(context);
              await openPayPalEmailDialog(context);
            },
            child: const Text('Setup PayPal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final baseUrl = Uri.base.origin;
              await PayoutSetupService().openStripeOnboarding(baseUrl: baseUrl);
            },
            child: const Text('Setup Stripe'),
          ),
        ],
      );
    },
  );
  return result == true;
}
