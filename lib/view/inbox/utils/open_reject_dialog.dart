import 'package:flutter/material.dart';

import '../../../core/services/payments/contract_service.dart';

Future<void> openRejectDialog(
  BuildContext context, {
  required String conversationId,
}) async {
  final reasonCtrl = TextEditingController();

  await showDialog(
    context: context,
    builder: (_) {
      return AlertDialog(
        title: const Text('Reject delivery'),
        content: SizedBox(
          width: 520,
          child: TextField(
            controller: reasonCtrl,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Reason (optional)'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await ContractService().rejectDeliveryByConversation(
                conversationId: conversationId,
                reason: reasonCtrl.text.trim(),
              );
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Delivery rejected')),
                );
              }
            },
            child: const Text('Reject'),
          ),
        ],
      );
    },
  );

  reasonCtrl.dispose();
}
