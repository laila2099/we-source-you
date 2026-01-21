import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/services/payments/payment_service.dart';
import '../core/services/payments/proposal_actions.dart';
import '../core/services/payments/proposal_service.dart';
import '../view/inbox/chat.dart';

class PaymentSuccessPage extends StatelessWidget {
  const PaymentSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    final contractId = Get.parameters['contractId'];
    if (contractId == null || contractId.isEmpty) {
      return const Scaffold(body: Center(child: Text('Missing contractId')));
    }
    final actions = ProposalActions(ProposalService(), PaymentService());

    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnap) {
        if (authSnap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: Text('Restoring session...')),
          );
        }
        if (authSnap.data == null) {
          return const Scaffold(
            body: Center(child: Text('Session expired. Please login.')),
          );
        }

        return StreamBuilder<String>(
          stream: actions.waitForConversationId(contractId),
          builder: (context, snap) {
            if (snap.hasError) {
              return Scaffold(
                body: Center(child: Text('Error: ${snap.error}')),
              );
            }
            if (!snap.hasData) {
              return const Scaffold(
                body: Center(child: Text('Confirming payment...')),
              );
            }

            final conversationId = snap.data!;
            print(conversationId);
            return ChatPage(conversationId: conversationId);
          },
        );
      },
    );
  }
}
