import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/payments/contract_status.dart';
import '../../../core/payments/conversation_status.dart';
import '../../../core/services/payments/contract_service.dart';
import '../../../core/services/payments/hireme_service.dart';
import '../../../widgets/payment_method_dialog.dart';
import '../utils/confirm_close_with_payout_check.dart';
import '../utils/open_dispute_evidence_dialog.dart';
import '../utils/open_reject_dialog.dart';
import '../utils/open_reject_offer_dialog.dart';
import '../utils/open_send_offer_dialog.dart';
import '../utils/open_submit_dialog.dart';

class ContractActionBar extends StatelessWidget {
  final String conversationId;
  final String conversationStatus; // open/closed/dispute_open
  final Map<String, dynamic>? contract;

  const ContractActionBar({
    super.key,
    required this.conversationId,
    required this.conversationStatus,
    required this.contract,
  });

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    print(uid);
    if (uid == null) return const SizedBox.shrink();

    final isOpen = conversationStatus == ConversationStatus.open.name;
    final isDispute = conversationStatus == ConversationStatus.disputeOpen.name;

    if (contract == null) return const SizedBox.shrink();

    final status = (contract!['status'] ?? '').toString();
    final clientId = (contract!['clientId'] ?? '').toString();
    final freelancerId = (contract!['freelancerId'] ?? '').toString();
    final type = (contract!['type'] ?? '').toString();
    final pricingType = (contract!['pricingType'] ?? '').toString();

    final payoutId = (contract?['payoutId'] ?? '').toString();

    final isClient = uid == clientId;
    final isFreelancer = uid == freelancerId;

    final agreement = (contract!['agreement'] is Map)
        ? Map<String, dynamic>.from(contract!['agreement'])
        : <String, dynamic>{};

    final agreementStatus = (agreement['status'] ?? 'none').toString();

    // -------------------------
    // Existing contract buttons
    // -------------------------
    final canSubmit =
        isFreelancer &&
        (status == ContractStatus.funded.name ||
            status == ContractStatus.inProgress.name);

    final canApprove = isClient && status == ContractStatus.submitted.name;

    final canConfirmClose =
        isFreelancer && status == ContractStatus.deliveryApproved.name;

    final canDispute =
        isClient &&
        (status == ContractStatus.submitted.name ||
            status == ContractStatus.deliveryApproved.name) &&
        !isDispute;

    final canSendEvidence = isDispute;

    // -------------------------
    // HireMe buttons
    // -------------------------
    final isHireMe = type == 'hireMe';
    final isChatUnlocked = status == ContractStatus.chatUnlocked.name;
    final isPendingRemaining =
        status == ContractStatus.paymentPendingRemaining.name;

    final canSendOffer =
        isFreelancer &&
        isHireMe &&
        isChatUnlocked &&
        agreementStatus != 'offered' &&
        agreementStatus != 'accepted';

    final canAcceptOffer =
        isClient && isHireMe && isChatUnlocked && agreementStatus == 'offered';

    final canCancelNoAgreement =
        isClient && isHireMe && isChatUnlocked && agreementStatus != 'accepted';

    final showWaitingPayment = isHireMe && isPendingRemaining;
    final canReject = isClient && status == ContractStatus.submitted.name;
    final canRejectOffer =
        isClient && isHireMe && isChatUnlocked && agreementStatus == 'offered';

    final canSendPayout =
        isFreelancer &&
        payoutId.isNotEmpty &&
        status == ContractStatus.payoutQueued.name;

    if (!isOpen && !isDispute && !canSendPayout) return const SizedBox.shrink();

    if (!canSendOffer &&
        !canAcceptOffer &&
        !canCancelNoAgreement &&
        !showWaitingPayment &&
        !canSubmit &&
        !canApprove &&
        !canConfirmClose &&
        !canDispute &&
        !canSendEvidence &&
        !canReject &&
        !canRejectOffer &&
        !canSendPayout) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.03),
        border: Border(top: BorderSide(color: Colors.black.withOpacity(0.08))),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          // =======================
          // HireMe – قبل الشغل
          // =======================
          if (canSendOffer)
            ElevatedButton.icon(
              icon: const Icon(Icons.local_offer),
              label: const Text('Send Offer'),
              onPressed: () => openSendOfferDialog(
                context,
                pricingType: pricingType,
                conversationId: conversationId,
              ),
            ),

          if (canAcceptOffer)
            ElevatedButton.icon(
              icon: const Icon(Icons.payment),
              label: const Text('Accept & Pay Remaining'),
              onPressed: () async {
                final provider = await showPaymentMethodDialog(context);
                if (provider == null) {
                  return;
                }

                await HireMeService().acceptAndPayRemainingWeb(
                  conversationId: conversationId,
                  provider: provider,
                  baseUrl: Uri.base.origin,
                );
                // ال redirect رح يصير بالويب، بس نترك snack خفيف
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Redirecting to payment...')),
                  );
                }
              },
            ),

          if (canRejectOffer)
            OutlinedButton.icon(
              icon: const Icon(Icons.close),
              label: const Text('Reject offer'),
              onPressed: () => openRejectOfferDialog(
                context,
                conversationId: conversationId,
              ),
            ),

          if (canCancelNoAgreement)
            OutlinedButton.icon(
              icon: const Icon(Icons.close),
              label: const Text('No agreement'),
              onPressed: () async {
                await HireMeService().cancelNoAgreement(
                  conversationId: conversationId,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Closed: first payment is treated as consultation (non-refundable)',
                      ),
                    ),
                  );
                }
              },
            ),

          if (showWaitingPayment)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                'Waiting for remaining payment to complete...',
                style: TextStyle(color: Colors.orange),
              ),
            ),

          // =======================
          // Existing delivery flow
          // =======================
          if (canSubmit)
            ElevatedButton.icon(
              icon: const Icon(Icons.upload_file),
              label: const Text('Submit delivery'),
              onPressed: () =>
                  openSubmitDialog(context, conversationId: conversationId),
            ),

          if (canApprove)
            ElevatedButton.icon(
              icon: const Icon(Icons.check_circle),
              label: const Text('Approve delivery'),
              onPressed: () async {
                await ContractService().approveDeliveryByConversation(
                  conversationId: conversationId,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Delivery approved')),
                  );
                }
              },
            ),

          if (canReject)
            OutlinedButton.icon(
              icon: const Icon(Icons.close),
              label: const Text('Reject delivery'),
              onPressed: () =>
                  openRejectDialog(context, conversationId: conversationId),
            ),

          if (canConfirmClose)
            ElevatedButton.icon(
              icon: const Icon(Icons.lock),
              label: const Text('Confirm close'),
              onPressed: () => confirmCloseWithPayoutCheck(
                context,
                payoutId: payoutId,
                conversationId: conversationId,
              ),

              /*onPressed: () async {
                try {
                  await ContractService().confirmCloseByConversation(
                    conversationId: conversationId,
                  );

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Contract closed & payout recorded'),
                      ),
                    );
                  }
                } on FirebaseFunctionsException catch (e) {
                  final msg = (e.message ?? '').toLowerCase();

                  if (e.code == 'failed-precondition' &&
                      msg.contains('payout setup required')) {
                    if (!context.mounted) return;

                    final didSetup = await _openPayoutSetupDialog(context);
                    if (didSetup == true) {
                      // ✅ retry confirm close
                      await ContractService().confirmCloseByConversation(
                        conversationId: conversationId,
                      );

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Contract closed & payout recorded'),
                          ),
                        );
                      }
                    }
                    return;
                  }

                  rethrow;
                }
              },*/
            ),

          if (canDispute)
            OutlinedButton.icon(
              icon: const Icon(Icons.report),
              label: const Text('Open dispute'),
              onPressed: () async {
                await ContractService().openDisputeByConversation(
                  conversationId: conversationId,
                  reason: 'Opened by user',
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Dispute opened')),
                  );
                }
              },
            ),

          if (canSendEvidence)
            OutlinedButton.icon(
              icon: const Icon(Icons.attach_file),
              label: const Text('Send evidence'),
              onPressed: () => openDisputeEvidenceDialog(
                context,
                conversationId: conversationId,
              ),
            ),

          if (canSendPayout)
            ElevatedButton.icon(
              icon: const Icon(Icons.payments),
              label: const Text('Send payout'),
              onPressed: () async {
                await ContractService().sendPayout(payoutId: payoutId);

                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Payout sent')));
                }
              },
            ),
        ],
      ),
    );
  }
}
