import 'package:flutter/material.dart';

import '../../../core/services/payments/payout_setup_service.dart';

Future<bool> openPayPalEmailDialog(BuildContext context) async {
  final emailCtrl = TextEditingController();

  final result = await showDialog(
    context: context,
    builder: (_) {
      return AlertDialog(
        title: const Text('PayPal payout email'),
        content: SizedBox(
          width: 520,
          child: TextField(
            controller: emailCtrl,
            decoration: const InputDecoration(labelText: 'PayPal email'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = emailCtrl.text.trim();
              if (email.isEmpty) return;

              await PayoutSetupService().setPayoutProfilePayPal(email: email);

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Payout profile saved')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );

  emailCtrl.dispose();
  return result == true;
}
