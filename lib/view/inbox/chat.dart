import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/payments/contract_status.dart';
import '../../core/payments/conversation_status.dart';
import '../../core/services/chat_service.dart';
import '../../core/services/payments/contract_service.dart';
import 'widgets/chat_input.dart';
import 'widgets/closed_contract_banner.dart';
import 'widgets/contract_action_bar.dart';
import 'widgets/delivery_message_bubble.dart';
import 'widgets/dispute_message_bubble.dart';

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
    print(uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('conversations')
            .doc(widget.conversationId)
            .snapshots(),
        builder: (context, convSnap) {
          if (convSnap.hasError) return Text('ERROR: ${convSnap.error}');
          if (!convSnap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final conv = convSnap.data!.data();
          if (conv == null) {
            return const Center(child: Text('Conversation missing'));
          }

          if (!_marked) {
            _marked = true;
            _markAsRead();
          }

          final conversationStatus = (conv['status'] ?? 'open').toString();
          final contractId = conv['contractId'] as String?;

          // إذا ما في contractId (حالة نادرة) خلّي الشات يشتغل رسائل فقط
          final contractStream = (contractId == null)
              ? null
              : FirebaseFirestore.instance
                    .collection('contracts')
                    .doc(contractId)
                    .snapshots();

          return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: contractStream,
            builder: (context, contractSnap) {
              final contract = contractSnap.data?.data(); // ممكن null
              final contractStatus = contract?['status'] ?? '';

              final downloadDeadline =
                  contract?['downloadDeadline'] as Timestamp?;
              final deadline = downloadDeadline?.toDate();
              final expired =
                  (deadline == null &&
                      contractStatus != ContractStatus.paidOut.name)
                  ? false
                  : DateTime.now().isAfter(deadline!);

              return Column(
                children: [
                  // banner فوق فقط إذا الشات مو open + عندنا contract
                  if (contract != null &&
                          conversationStatus != ConversationStatus.open.name ||
                      (conversationStatus == ConversationStatus.open.name &&
                          contractStatus == ContractStatus.chatUnlocked.name))
                    ClosedContractBanner(
                      contract: contract!,
                      onOpenDispute: () async {
                        await ContractService().openDisputeByConversation(
                          conversationId: widget.conversationId,
                          reason: 'Opened from chat banner',
                        );
                      },
                      conversationStatus: conversationStatus,
                    ),

                  Expanded(
                    child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: ChatService().watchMessages(
                        widget.conversationId,
                      ),
                      builder: (context, msgSnap) {
                        if (msgSnap.hasError) {
                          return Text('Messages error: ${msgSnap.error}');
                        }
                        if (!msgSnap.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final docs = msgSnap.data!.docs;
                        if (docs.isEmpty) {
                          return const Center(child: Text('No messages yet'));
                        }

                        final uid = FirebaseAuth.instance.currentUser?.uid;

                        return ListView.builder(
                          reverse: true,
                          itemCount: docs.length,
                          itemBuilder: (context, i) {
                            final m = docs[i].data();

                            final senderId = (m['senderId'] ?? '').toString();
                            final mine = uid != null && senderId == uid;

                            final type = (m['type'] ?? 'text').toString();

                            // ✅ 1) رسالة تسليم (ملفات / zip / link / text delivery)
                            if (type == 'delivery') {
                              return DeliveryMessageBubble(
                                conversationId: widget.conversationId,
                                message: m,
                                mine: mine,
                                expired: expired,
                              );
                            }
                            if (type == 'dispute') {
                              return DisputeMessageBubble(
                                mine: mine,
                                message: m,
                                contract: contract!,
                                conversationId: widget.conversationId,
                                expired: expired,
                              );
                            }

                            // ✅ 2) رسالة عادية (نص)
                            final text = (m['text'] ?? '').toString();
                            print(contractStatus);
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

                  // ✅ Action bar يعتمد conversationId + contract snapshot
                  if (conversationStatus == ConversationStatus.open.name ||
                      conversationStatus ==
                          ConversationStatus.disputeOpen.name ||
                      contractStatus == ContractStatus.payoutQueued.name)
                    ContractActionBar(
                      conversationStatus: conversationStatus,
                      contract: contract,
                      conversationId: widget.conversationId,
                    ),

                  /*  if (conversationStatus == 'dispute_open')
                    DisputeInput(conversationId: widget.conversationId)
                  else*/
                  ChatInput(
                    conversationId: widget.conversationId,
                    chat: ChatService(),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
