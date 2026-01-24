import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

import '../../../core/services/payments/contract_service.dart';
import '../../../core/services/payments/payout_service.dart';
import 'open_payout_setup_dialog.dart';

Future<void> confirmCloseWithPayoutCheck(
  BuildContext context, {
  required String payoutId,
  required String conversationId,
}) async {
  final service = PayoutService();

  final methods = await service.getPayoutSettings();
  // expected:
  // { payoutDefault: 'paypal'|'stripe'|null, methods:{paypal:true/false, stripe:true/false}, paypalEmail?, stripeConnectAccountId? }

  final m = Map<String, dynamic>.from(methods);

  final def = (m['payoutDefault'] ?? '').toString();
  final methodsMap = (m['payoutProfile'] is Map)
      ? Map<String, dynamic>.from(m['payoutProfile'])
      : {};
  final hasPaypal = methodsMap['paypal']['email'].toString().isNotEmpty == true;
  final hasStripe =
      methodsMap['stripe']['stripeConnectAccountId'].toString().isNotEmpty ==
      true;
  if (!hasPaypal && !hasStripe) {
    openPayoutSetupDialog(context);
    return;
  }

  String currentLabel = 'Not set';
  if (def == 'paypal' && hasPaypal) {
    final email = (m['email'] ?? '').toString();
    currentLabel = email.isNotEmpty ? 'PayPal ($email)' : 'PayPal';
  } else if (def == 'stripe' && hasStripe) {
    final acct = (m['stripeConnectAccountId'] ?? '').toString();
    currentLabel = acct.isNotEmpty ? 'Stripe ($acct)' : 'Stripe';
  } else {
    currentLabel = hasPaypal ? 'PayPal' : 'Stripe';
  }

  // 2) Dialog تأكيد
  final go = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Confirm close'),
      content: Text(
        'Payout method: $currentLabel\n\n'
        'After you confirm close, the payout will be prepared. '
        'Then you can send it using “Send payout”.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, false);
            // payout settings
            // Get.to(() => PayoutSettingsPage());
          },
          child: const Text('Change'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Continue'),
        ),
      ],
    ),
  );

  if (go != true) return;

  try {
    await ContractService().confirmCloseByConversation(
      conversationId: conversationId,
    );

    await ContractService().sendPayout(payoutId: payoutId);

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Payout sent')));
    }
  } on FirebaseFunctionsException catch (e) {
    final msg = (e.message ?? '').toLowerCase();

    if (e.code == 'failed-precondition' &&
        msg.contains('payout setup required')) {
      if (!context.mounted) return;

      final didSetup = await openPayoutSetupDialog(context);
      if (didSetup == true) {
        // retry confirm close
        await ContractService().confirmCloseByConversation(
          conversationId: conversationId,
        );

        await ContractService().sendPayout(payoutId: payoutId);

        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Payout sent')));
        }
      }
      return;
    }

    rethrow;
  }
}
