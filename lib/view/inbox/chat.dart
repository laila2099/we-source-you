import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:we_source_you/view/inbox/widgets/chat_input.dart';

import '../../core/services/chat_service.dart';
import 'widgets/closed_contract_banner.dart';

class ChatPage extends StatefulWidget {
  final String conversationId;
  const ChatPage({super.key, required this.conversationId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  bool _marked = false;

  Future<void> _markAsRead() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await FirebaseFirestore.instance
        .collection('conversations')
        .doc(widget.conversationId)
        .update({'unread.$uid': 0});
  }

  @override
  Widget build(BuildContext context) {
    print('conversationId = "${widget.conversationId}"');

    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),

      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('conversations')
            .doc(widget.conversationId)
            .snapshots(),
        builder: (context, convSnap) {
          if (convSnap.hasError) {
            return Text('ERROR: ${convSnap.error}');
          }
          if (convSnap.hasData && !_marked) {
            _marked = true;
            _markAsRead(); // مرة واحدة
          }

          if (!convSnap.hasData) return const Text('geen data');
          final conv = convSnap.data!.data();
          if (conv == null) return const Text('open');
          print(conv?.values);

          final status = (conv!['status'] ?? 'open').toString();
          final contractId = conv!['contractId'] as String?;

          return Column(
            children: [
              if (status != 'open' && contractId != null)
                FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  future: FirebaseFirestore.instance
                      .collection('contracts')
                      .doc(contractId)
                      .get(),
                  builder: (context, contractSnap) {
                    if (!contractSnap.hasData) return const SizedBox();
                    final c = contractSnap.data!.data();
                    if (c == null) return const SizedBox();
                    return ClosedContractBanner(
                      contract: c,
                      onOpenDispute: () async {},
                    );
                  },
                ),
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: ChatService().watchMessages(widget.conversationId),
                  builder: (context, snap) {
                    if (snap.hasError) {
                      return Text('Messages error: ${snap.error}');
                    }
                    if (!snap.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final docs = snap.data!.docs;
                    if (docs.isEmpty) {
                      return const Center(child: Text('No messages yet'));
                    }

                    final uid = FirebaseAuth.instance.currentUser?.uid;

                    return ListView.builder(
                      reverse: true,
                      itemCount: docs.length,
                      itemBuilder: (context, i) {
                        final m = docs[i].data();
                        final text = (m['text'] ?? '').toString();
                        final senderId = (m['senderId'] ?? '').toString();
                        final mine = uid != null && senderId == uid;

                        return Align(
                          alignment: mine
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: mine
                                  ? Colors.blue.withOpacity(0.15)
                                  : Colors.grey.withOpacity(0.15),
                            ),
                            child: Text(text),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              ChatInput(
                conversationId: widget.conversationId,
                chat: ChatService(),
              ),
            ],
          );
        },
      ),
    );
  }
}
