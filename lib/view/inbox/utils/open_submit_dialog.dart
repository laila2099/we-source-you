import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../core/services/payments/contract_service.dart';

Future<void> openSubmitDialog(
  BuildContext context, {
  required String conversationId,
}) async {
  final textCtrl = TextEditingController();
  final linkCtrl = TextEditingController();

  String mode = 'text'; // text | link | files
  List<PlatformFile> pickedFiles = [];

  await showDialog(
    context: context,
    builder: (_) {
      return AlertDialog(
        title: const Text('Submit delivery'),
        content: SizedBox(
          width: 520,
          child: StatefulBuilder(
            builder: (context, setState) {
              Future<void> pickFiles() async {
                final result = await FilePicker.platform.pickFiles(
                  allowMultiple: true,
                  withData: true, // مهم للويب
                );
                if (result == null) return;
                setState(() => pickedFiles = result.files);
              }

              Widget filesList() {
                if (pickedFiles.isEmpty) {
                  return const Text('No files selected yet.');
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    ...pickedFiles.map((f) {
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
                          IconButton(
                            tooltip: 'Remove',
                            onPressed: () {
                              setState(() => pickedFiles.remove(f));
                            },
                            icon: const Icon(Icons.close, size: 18),
                          ),
                        ],
                      );
                    }),
                  ],
                );
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: mode,
                    items: const [
                      DropdownMenuItem(value: 'text', child: Text('Text')),
                      DropdownMenuItem(value: 'link', child: Text('Link')),
                      DropdownMenuItem(value: 'files', child: Text('Files')),
                    ],
                    onChanged: (v) => setState(() => mode = v ?? 'text'),
                  ),
                  const SizedBox(height: 12),

                  if (mode == 'text')
                    TextField(
                      controller: textCtrl,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Delivery text',
                      ),
                    ),

                  if (mode == 'link')
                    TextField(
                      controller: linkCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Delivery link',
                      ),
                    ),

                  if (mode == 'files') ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ElevatedButton.icon(
                        onPressed: pickFiles,
                        icon: const Icon(Icons.attach_file),
                        label: const Text('Pick files'),
                      ),
                    ),
                    filesList(),
                  ],
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
              Navigator.pop(context);
              final service = ContractService();
              final isLoading = true;

              if (mode == 'text') {
                final text = textCtrl.text.trim();
                if (text.isEmpty) return;
                await service.submitDeliveryByConversation(
                  conversationId: conversationId,
                  submissionType: 'text',
                  submissionData: {'text': text},
                );
              } else if (mode == 'link') {
                final link = linkCtrl.text.trim();
                if (link.isEmpty) return;
                await service.submitDeliveryByConversation(
                  conversationId: conversationId,
                  submissionType: 'link',
                  submissionData: {'url': link},
                );
              } else {
                if (pickedFiles.isEmpty) return;

                final uploaded = await service.uploadDeliveryFilesWeb(
                  conversationId: conversationId,
                  files: pickedFiles,
                );

                await service.submitDeliveryByConversation(
                  conversationId: conversationId,
                  submissionType: 'files',
                  submissionData: {'files': uploaded},
                );
              }

              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Submitted')));
            },
            child: const Text('Submit'),
          ),
        ],
      );
    },
  );

  textCtrl.dispose();
  linkCtrl.dispose();
}
