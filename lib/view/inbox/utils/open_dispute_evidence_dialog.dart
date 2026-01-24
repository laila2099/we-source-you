import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../core/services/payments/contract_service.dart';

Future<void> openDisputeEvidenceDialog(
  BuildContext context, {
  required String conversationId,
}) async {
  final textCtrl = TextEditingController();
  List<PlatformFile> pickedFiles = [];

  await showDialog(
    context: context,
    builder: (_) {
      return AlertDialog(
        title: const Text('Dispute evidence'),
        content: SizedBox(
          width: 520,
          child: StatefulBuilder(
            builder: (context, setState) {
              Future<void> pickFiles() async {
                final result = await FilePicker.platform.pickFiles(
                  allowMultiple: true,
                  withData: true, // للويب
                );
                if (result == null) return;
                setState(() => pickedFiles = result.files);
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: textCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Message (optional)',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton.icon(
                      onPressed: pickFiles,
                      icon: const Icon(Icons.attach_file),
                      label: const Text('Pick evidence files'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (pickedFiles.isEmpty) const Text('No files selected.'),
                  if (pickedFiles.isNotEmpty)
                    Column(
                      children: pickedFiles.map((f) {
                        final kb = (f.size / 1024).toStringAsFixed(1);
                        return Row(
                          children: [
                            const Icon(Icons.insert_drive_file, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                f.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text('$kb KB'),
                          ],
                        );
                      }).toList(),
                    ),
                ],
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final service = ContractService();

              final uploaded = pickedFiles.isEmpty
                  ? <Map<String, dynamic>>[]
                  : await service.uploadDisputeEvidenceFilesWeb(
                      conversationId: conversationId,
                      files: pickedFiles,
                    );

              await service.submitDisputeMessageByConversation(
                conversationId: conversationId,
                text: textCtrl.text.trim(),
                attachments: uploaded,
              );

              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Send'),
          ),
        ],
      );
    },
  );

  textCtrl.dispose();
}
