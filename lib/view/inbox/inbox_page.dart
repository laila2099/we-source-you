import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'chat.dart';

class InboxPage extends StatelessWidget {
  const InboxPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Please sign in.')));
    }

    final stream = FirebaseFirestore.instance
        .collection('conversations')
        .where('participants', arrayContains: uid)
        .snapshots();

    return Scaffold(
      appBar: AppBar(title: const Text('Inbox')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: stream,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snap.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('No conversations yet.'));
          }

          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final doc = docs[i];
              final c = doc.data();

              final status = (c['status'] ?? 'open').toString();
              final contractId = (c['contractId'] ?? '').toString();

              // optional fields (if you store them)
              final lastText = (c['lastMessageText'] ?? '').toString();
              final lastAt = c['lastMessageAt'] as Timestamp?;
              final subtitle = lastText.isNotEmpty
                  ? lastText
                  : (contractId.isNotEmpty ? 'Contract: $contractId' : '');
              final uid = FirebaseAuth.instance.currentUser!.uid;
              final unreadMap =
                  (c['unread'] as Map?)?.cast<String, dynamic>() ?? {};
              final unreadCount = (unreadMap[uid] ?? 0) as num;

              return ListTile(
                title: const Text('Conversation'),
                subtitle: Text(lastText),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (unreadCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          unreadCount.toInt().toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    _StatusChip(status: status),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatPage(conversationId: doc.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final label = switch (status) {
      'closed' => 'Closed',
      'disputeOpen' => 'Dispute',
      _ => 'Open',
    };

    return Chip(label: Text(label));
  }
}
