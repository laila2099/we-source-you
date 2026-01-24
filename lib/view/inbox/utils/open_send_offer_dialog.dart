import 'package:flutter/material.dart';

import '../../../core/services/payments/hireme_service.dart';

Future<void> openSendOfferDialog(
  BuildContext context, {
  required String pricingType,
  required String conversationId,
}) async {
  final qtyCtrl = TextEditingController();
  final notesCtrl = TextEditingController();

  await showDialog(
    context: context,
    builder: (_) {
      return AlertDialog(
        title: const Text('Send Offer'),
        content: SizedBox(
          width: 520,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: qtyCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: pricingType == 'project'
                      ? 'project (total Amount)'
                      : 'Hours / days (integer)',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final qty = int.tryParse(qtyCtrl.text.trim());
              if (qty == null || qty <= 0) return;

              await HireMeService().sendOffer(
                conversationId: conversationId,
                quantity: pricingType == 'project' ? null : qty,
                totalAmount: (pricingType == 'project') ? qty.toDouble() : null,
                pricingType: pricingType,
                notes: notesCtrl.text.trim(),
              );

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Offer sent')));
              }
            },
            child: const Text('Send'),
          ),
        ],
      );
    },
  );

  qtyCtrl.dispose();
  notesCtrl.dispose();
}
