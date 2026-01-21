import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/services/chat_service.dart';

class ChatInput extends StatefulWidget {
  final String conversationId;
  final ChatService chat;
  const ChatInput({
    super.key,
    required this.conversationId,
    required this.chat,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final ctrl = TextEditingController();
  bool sending = false;

  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: Text('Please login to send messages'),
      );
    }

    final convRef = FirebaseFirestore.instance
        .collection('conversations')
        .doc(widget.conversationId);

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: convRef.snapshots(),
      builder: (context, snap) {
        final status = snap.data?.data()?['status']?.toString() ?? 'open';

        final isOpen = status == 'open';

        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: ctrl,
                    enabled: isOpen,
                    onSubmitted: (_) => isOpen ? _send(context) : null,

                    decoration: InputDecoration(
                      hintText: isOpen
                          ? 'Type a message...'
                          : 'Chat is read-only',
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: isOpen ? () => _send(context) : null,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _send(BuildContext context) async {
    final text = ctrl.text.trim();
    if (text.isEmpty) return;

    setState(() => sending = true);
    try {
      await widget.chat.sendText(
        conversationId: widget.conversationId,
        text: text,
      );
      ctrl.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }
}
