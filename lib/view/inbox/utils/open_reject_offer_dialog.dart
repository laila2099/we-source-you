import 'package:flutter/material.dart';

import '../../../core/services/payments/hireme_service.dart';

Future<void> openRejectOfferDialog(
  BuildContext context, {
  required String conversationId,
}) async {
  final reasonCtrl = TextEditingController();

  await showDialog(
    context: context,
    builder: (_) {
      return AlertDialog(
        title: const Text('Reject offer'),
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
              await HireMeService().rejectOffer(
                conversationId: conversationId,
                reason: reasonCtrl.text.trim(),
              );
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Offer rejected')));
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
