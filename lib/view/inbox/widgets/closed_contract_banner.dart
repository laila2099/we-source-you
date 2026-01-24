import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/payments/conversation_status.dart';

class ClosedContractBanner extends StatelessWidget {
  final Map<String, dynamic> contract;
  final String conversationStatus; // open / closed / dispute_open
  final VoidCallback? onOpenDispute;

  const ClosedContractBanner({
    super.key,
    required this.contract,
    required this.conversationStatus,
    required this.onOpenDispute,
  });

  @override
  Widget build(BuildContext context) {
    final paidOutAt = contract['paidOutAt'] as Timestamp?;
    final disputeDeadline = contract['disputeDeadline'] as Timestamp?;
    final downloadDeadline = contract['downloadDeadline'] as Timestamp?;
    final status = (contract['status'] ?? '').toString();

    final type = (contract['type'] ?? '').toString();
    final pricingType = (contract['pricingType'] ?? '')
        .toString(); // hourly/daily/project
    final prepaidUnits = (contract['prepaidUnits'] ?? 0);
    final prepaidAmount = contract['prepaidAmount'];
    final agreement = (contract['agreement'] is Map)
        ? Map<String, dynamic>.from(contract['agreement'])
        : <String, dynamic>{};
    final agreementStatus = (agreement['status'] ?? 'none').toString();

    final now = DateTime.now();

    final paidOutDate = paidOutAt?.toDate();
    final disputeDate = disputeDeadline?.toDate();
    final downloadDate = downloadDeadline?.toDate();

    final canOpenDispute = disputeDate != null && now.isBefore(disputeDate);

    String fmt(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

    // =========================
    // 🟦 CASE: HIREME (OPEN CHAT)
    // =========================
    if (conversationStatus == ConversationStatus.open.name &&
        type == 'hireMe') {
      String title;
      if (pricingType == 'hourly') {
        title = 'HireMe — Hourly';
      } else if (pricingType == 'daily') {
        title = 'HireMe — Daily';
      } else {
        title = 'HireMe — Project';
      }

      // الحالة النصية
      String stateText;
      if (status == 'chatUnlocked') {
        stateText = (agreementStatus == 'offered')
            ? 'Status: waiting for your acceptance'
            : 'Status: waiting for offer';
      } else if (status == 'paymentPendingRemaining') {
        stateText = 'Status: waiting for remaining payment';
      } else if (status == 'funded' || status == 'inProgress') {
        stateText = 'Status: funded (work can start)';
      } else {
        stateText = 'Status: $status';
      }

      // prepaid line
      String prepaidText;
      if (pricingType == 'project') {
        prepaidText = 'Prepaid: ${prepaidAmount ?? '-'}';
      } else {
        prepaidText =
            'Prepaid: ${prepaidUnits == 0 ? 1 : prepaidUnits} ${pricingType == 'daily' ? 'day(s)' : 'hour(s)'}';
      }

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blueGrey.shade50,
          border: Border(bottom: BorderSide(color: Colors.blueGrey.shade200)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 6),
            Text(prepaidText, style: const TextStyle(color: Colors.black)),
            const SizedBox(height: 4),
            Text(stateText, style: const TextStyle(color: Colors.red)),
          ],
        ),
      );
    }

    // =========================
    // 🟥 CASE: DISPUTE OPEN
    // =========================

    if (conversationStatus == ConversationStatus.disputeOpen.name) {
      print(conversationStatus == ConversationStatus.disputeOpen.name);
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          border: Border(bottom: BorderSide(color: Colors.orange.shade400)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Dispute in progress',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.deepOrange,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'A dispute has been opened for this contract.\n'
              'Both parties can continue sending messages and evidence.\n'
              'Our support team will review the case.',
              style: TextStyle(color: Colors.black),
            ),
          ],
        ),
      );
    }

    // =========================
    // 🟨 CASE: CLOSED (NO DISPUTE)
    // =========================
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
                child: const Text('Open dispute'),
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
