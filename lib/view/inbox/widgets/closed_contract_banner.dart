import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ClosedContractBanner extends StatelessWidget {
  final Map<String, dynamic> contract;
  final VoidCallback? onOpenDispute;

  const ClosedContractBanner({
    super.key,
    required this.contract,
    required this.onOpenDispute,
  });

  @override
  Widget build(BuildContext context) {
    final paidOutAt = contract['paidOutAt'] as Timestamp?;
    final disputeDeadline = contract['disputeDeadline'] as Timestamp?;
    final downloadDeadline = contract['downloadDeadline'] as Timestamp?;

    final now = DateTime.now();

    final paidOutDate = paidOutAt?.toDate();
    final disputeDate = disputeDeadline?.toDate();
    final downloadDate = downloadDeadline?.toDate();

    final canOpenDispute = disputeDate != null && now.isBefore(disputeDate);

    String fmt(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.amber.shade300)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contract closed',
            style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black),
          ),
          const SizedBox(height: 8),

          if (paidOutDate != null)
            Text('This contract was closed on ${fmt(paidOutDate)}.'),

          if (disputeDate != null)
            Text('You can open a dispute until ${fmt(disputeDate)}.'),

          if (downloadDate != null)
            Text('Downloads are available until ${fmt(downloadDate)}.'),

          const SizedBox(height: 10),

          Row(
            children: [
              ElevatedButton(
                onPressed: canOpenDispute ? onOpenDispute : null,
                child: const Text(
                  'Open dispute',
                  style: TextStyle(color: Colors.black54),
                ),
              ),
              const SizedBox(width: 10),
              if (!canOpenDispute && disputeDate != null)
                Text(
                  'Dispute window has expired.',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
