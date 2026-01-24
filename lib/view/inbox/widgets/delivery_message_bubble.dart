import 'dart:html' as html;

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

class DeliveryMessageBubble extends StatelessWidget {
  final String conversationId;
  final Map<String, dynamic> message;
  final bool mine;
  final bool expired;

  const DeliveryMessageBubble({
    super.key,
    required this.conversationId,
    required this.message,
    required this.mine,
    required this.expired,
  });

  @override
  Widget build(BuildContext context) {
    final meta = (message['meta'] as Map?)?.cast<String, dynamic>() ?? {};
    final submissionType = (meta['submissionType'] ?? '').toString();
    final submissionData =
        (meta['submissionData'] as Map?)?.cast<String, dynamic>() ?? {};

    final files = (submissionType == 'files')
        ? (submissionData['files'] as List?)?.cast<Map>() ?? const []
        : const [];

    final isZip = submissionType == 'zip';

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: mine
              ? Colors.blue.withOpacity(0.12)
              : Colors.green.withOpacity(0.12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📦 Delivery',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            if (submissionType == 'text')
              Text((submissionData['text'] ?? '').toString()),

            if (submissionType == 'link')
              Text((submissionData['url'] ?? '').toString()),

            if (files.isNotEmpty) ...[
              const Text(
                'Files:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              ...List.generate(files.length, (i) {
                final f = files[i].cast<String, dynamic>();
                final name = (f['name'] ?? 'file_$i').toString();
                return Row(
                  children: [
                    const Icon(Icons.insert_drive_file, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(name, overflow: TextOverflow.ellipsis),
                    ),
                    TextButton(
                      onPressed: (!expired)
                          ? () => _download(context, fileIndex: i)
                          : null,
                      child: (expired)
                          ? Text('Download expired')
                          : Text('Download'),
                    ),
                  ],
                );
              }),
            ],

            if (isZip)
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () => (!expired)
                      ? () => _download(context, fileIndex: 0)
                      : null,
                  icon: const Icon(Icons.download),
                  label: (expired)
                      ? Text('Download expired')
                      : Text('Download ZIP'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _download(BuildContext context, {required int fileIndex}) async {
    try {
      final functions = FirebaseFunctions.instanceFor(region: 'us-central1');
      final res = await functions
          .httpsCallable('getDeliveryDownloadUrlByConversation')
          .call({'conversationId': conversationId, 'fileIndex': fileIndex});

      final data = Map<String, dynamic>.from(res.data as Map);
      final url = data['url'] as String?;
      if (url == null || url.isEmpty) throw Exception('Missing url');

      html.window.open(url, '_blank');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Download failed: $e')));
    }
  }
}
