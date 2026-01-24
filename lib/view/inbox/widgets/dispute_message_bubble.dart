import 'dart:html' as html;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

class DisputeMessageBubble extends StatelessWidget {
  final String conversationId;
  final Map<String, dynamic> message;
  final bool mine;
  final bool expired;

  /// لازم فيها clientId + freelancerId
  final Map<String, dynamic>? contract;

  const DisputeMessageBubble({
    super.key,
    required this.conversationId,
    required this.message,
    required this.mine,
    required this.contract,
    required this.expired,
  });

  @override
  Widget build(BuildContext context) {
    final text = (message['text'] ?? '').toString();

    final meta = (message['meta'] is Map)
        ? Map<String, dynamic>.from(message['meta'])
        : <String, dynamic>{};

    final atts = (meta['attachments'] is List)
        ? List.from(meta['attachments'])
        : const [];

    final senderId = (message['senderId'] ?? '').toString();

    // ---- role detection (no trust in meta.role) ----
    final clientId = (contract?['clientId'] ?? '').toString();
    final freelancerId = (contract?['freelancerId'] ?? '').toString();

    final role = _roleOf(senderId, clientId, freelancerId);
    final roleLabel = _roleLabel(role);
    final roleColor = _roleColor(role);

    // optional timestamp
    final ts = message['createdAt'] as Timestamp?;
    final timeText = (ts != null)
        ? '${ts.toDate().hour.toString().padLeft(2, '0')}:${ts.toDate().minute.toString().padLeft(2, '0')}'
        : '';

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.all(10),
        constraints: const BoxConstraints(maxWidth: 520),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: mine
              ? Colors.orange.withOpacity(0.12)
              : Colors.orange.withOpacity(0.08),
          border: Border.all(color: roleColor.withOpacity(0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // header (role + time)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('⚠️', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Text(
                  'Dispute',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: roleColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: roleColor.withOpacity(0.35)),
                  ),
                  child: Text(
                    roleLabel,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: roleColor,
                    ),
                  ),
                ),
                if (timeText.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Text(
                    timeText,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                  ),
                ],
              ],
            ),

            if (text.isNotEmpty) ...[const SizedBox(height: 6), Text(text)],

            if (atts.isNotEmpty) ...[
              const SizedBox(height: 10),
              ...atts.map((a) {
                final m = (a is Map)
                    ? Map<String, dynamic>.from(a)
                    : <String, dynamic>{};

                final name = (m['name'] ?? 'file').toString();
                final fileRef = (m['fileRef'] ?? '').toString();
                if (fileRef.isEmpty) return const SizedBox.shrink();

                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.attach_file, size: 18),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(name, overflow: TextOverflow.ellipsis),
                      ),
                      TextButton(
                        onPressed: (expired)
                            ? null
                            : () async {
                                final functions = FirebaseFunctions.instanceFor(
                                  region: 'us-central1',
                                );

                                final res = await functions
                                    .httpsCallable(
                                      'getDisputeAttachmentUrlByConversation',
                                    )
                                    .call({
                                      'conversationId': conversationId,
                                      'fileRef': fileRef,
                                      'filename': name,
                                    });

                                final data = Map<String, dynamic>.from(
                                  res.data as Map,
                                );
                                final url = data['url'] as String?;
                                if (url != null && url.isNotEmpty) {
                                  html.window.open(url, '_blank');
                                }
                              },
                        child: (expired)
                            ? Text('Download expired')
                            : Text('Download'),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  String _roleOf(String senderId, String clientId, String freelancerId) {
    if (senderId.isEmpty) return 'support';
    if (senderId == clientId) return 'client';
    if (senderId == freelancerId) return 'freelancer';
    return 'support';
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'client':
        return 'Client';
      case 'freelancer':
        return 'Freelancer';
      default:
        return 'Support';
    }
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'client':
        return Colors.blueGrey;
      case 'freelancer':
        return Colors.purple;
      default:
        return Colors.red;
    }
  }
}
