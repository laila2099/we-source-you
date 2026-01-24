import 'package:cloud_functions/cloud_functions.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/payments/contract_status.dart';
import '../../../core/payments/conversation_status.dart';
import '../../../core/payments/payment_provider.dart';
import '../../../core/services/payments/contract_service.dart';
import '../../../core/services/payments/hireme_service.dart';
import '../../../core/services/payments/payout_service.dart';
import '../../../core/services/payments/payout_setup_service.dart';

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
              onPressed: () =>
                  _openSendOfferDialog(context, pricingType: pricingType),
            ),

          if (canAcceptOffer)
            ElevatedButton.icon(
              icon: const Icon(Icons.payment),
              label: const Text('Accept & Pay Remaining'),
              onPressed: () async {
                await HireMeService().acceptAndPayRemainingWeb(
                  conversationId: conversationId,
                  provider: PaymentProvider.stripe,
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
              onPressed: () => _openRejectOfferDialog(context),
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
              onPressed: () => _openSubmitDialog(context),
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
              onPressed: () => _openRejectDialog(context),
            ),

          if (canConfirmClose)
            ElevatedButton.icon(
              icon: const Icon(Icons.lock),
              label: const Text('Confirm close'),
              onPressed: () =>
                  _confirmCloseWithPayoutCheck(context, payoutId: payoutId),

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
              onPressed: () => _openDisputeEvidenceDialog(context),
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

  // ============================
  // HireMe: Send Offer Dialog
  // ============================
  Future<void> _openSendOfferDialog(
    BuildContext context, {
    required String pricingType,
  }) async {
    final qtyCtrl = TextEditingController();
    final notesCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Send Offer'),
          content: SizedBox(
            width: 520,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: qtyCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: pricingType == 'project'
                        ? 'project (total Amount)'
                        : 'Hours / days (integer)',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final qty = int.tryParse(qtyCtrl.text.trim());
                if (qty == null || qty <= 0) return;

                await HireMeService().sendOffer(
                  conversationId: conversationId,
                  quantity: pricingType == 'project' ? null : qty,
                  totalAmount: (pricingType == 'project')
                      ? qty.toDouble()
                      : null,
                  pricingType: pricingType,
                  notes: notesCtrl.text.trim(),
                );

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Offer sent')));
                }
              },
              child: const Text('Send'),
            ),
          ],
        );
      },
    );

    qtyCtrl.dispose();
    notesCtrl.dispose();
  }

  // ============================
  // Submit Delivery Dialog
  // ============================
  Future<void> _openSubmitDialog(BuildContext context) async {
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

  // ============================
  // Dispute evidence dialog
  // ============================
  Future<void> _openDisputeEvidenceDialog(BuildContext context) async {
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

  // ============================
  // Reject dialog
  // ============================
  Future<void> _openRejectDialog(BuildContext context) async {
    final reasonCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Reject delivery'),
          content: SizedBox(
            width: 520,
            child: TextField(
              controller: reasonCtrl,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Reason (optional)'),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await ContractService().rejectDeliveryByConversation(
                  conversationId: conversationId,
                  reason: reasonCtrl.text.trim(),
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Delivery rejected')),
                  );
                }
              },
              child: const Text('Reject'),
            ),
          ],
        );
      },
    );

    reasonCtrl.dispose();
  }

  Future<void> _openRejectOfferDialog(BuildContext context) async {
    final reasonCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Reject offer'),
          content: SizedBox(
            width: 520,
            child: TextField(
              controller: reasonCtrl,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Reason (optional)'),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await HireMeService().rejectOffer(
                  conversationId: conversationId,
                  reason: reasonCtrl.text.trim(),
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Offer rejected')),
                  );
                }
              },
              child: const Text('Reject'),
            ),
          ],
        );
      },
    );

    reasonCtrl.dispose();
  }

  Future<bool> _openPayoutSetupDialog(BuildContext context) async {
    final result = await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Payout setup required'),
          content: const SizedBox(
            width: 520,
            child: Text(
              'Before we can transfer your earnings, choose a payout method.',
            ),
          ),
          actions: [
            OutlinedButton(
              onPressed: () async {
                // PayPal setup: ask email
                Navigator.pop(context);
                await _openPayPalEmailDialog(context);
              },
              child: const Text('Setup PayPal'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                final baseUrl = Uri.base.origin;
                await PayoutSetupService().openStripeOnboarding(
                  baseUrl: baseUrl,
                );
              },
              child: const Text('Setup Stripe'),
            ),
          ],
        );
      },
    );
    return result == true;
  }

  Future<bool> _openPayPalEmailDialog(BuildContext context) async {
    final emailCtrl = TextEditingController();

    final result = await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('PayPal payout email'),
          content: SizedBox(
            width: 520,
            child: TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: 'PayPal email'),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final email = emailCtrl.text.trim();
                if (email.isEmpty) return;

                await PayoutSetupService().setPayoutProfilePayPal(email: email);

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Payout profile saved')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    emailCtrl.dispose();
    return result == true;
  }

  Future<void> _confirmCloseWithPayoutCheck(
    BuildContext context, {
    required String payoutId,
  }) async {
    final service = PayoutService();

    final methods = await service.getPayoutSettings();
    // expected:
    // { payoutDefault: 'paypal'|'stripe'|null, methods:{paypal:true/false, stripe:true/false}, paypalEmail?, stripeConnectAccountId? }

    final m = Map<String, dynamic>.from(methods);

    final def = (m['payoutDefault'] ?? '').toString();
    final methodsMap = (m['payoutProfile'] is Map)
        ? Map<String, dynamic>.from(m['payoutProfile'])
        : {};
    final hasPaypal =
        methodsMap['paypal']['email'].toString().isNotEmpty == true;
    final hasStripe =
        methodsMap['stripe']['stripeConnectAccountId'].toString().isNotEmpty ==
        true;
    if (!hasPaypal && !hasStripe) {
      _openPayoutSetupDialog(context);
      return;
    }

    String currentLabel = 'Not set';
    if (def == 'paypal' && hasPaypal) {
      final email = (m['email'] ?? '').toString();
      currentLabel = email.isNotEmpty ? 'PayPal ($email)' : 'PayPal';
    } else if (def == 'stripe' && hasStripe) {
      final acct = (m['stripeConnectAccountId'] ?? '').toString();
      currentLabel = acct.isNotEmpty ? 'Stripe ($acct)' : 'Stripe';
    } else {
      currentLabel = hasPaypal ? 'PayPal' : 'Stripe';
    }

    // 2) Dialog تأكيد
    final go = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm close'),
        content: Text(
          'Payout method: $currentLabel\n\n'
          'After you confirm close, the payout will be prepared. '
          'Then you can send it using “Send payout”.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
              // payout settings
              // Get.to(() => PayoutSettingsPage());
            },
            child: const Text('Change'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );

    if (go != true) return;

    try {
      await ContractService().confirmCloseByConversation(
        conversationId: conversationId,
      );

      await ContractService().sendPayout(payoutId: payoutId);

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Payout sent')));
      }
    } on FirebaseFunctionsException catch (e) {
      final msg = (e.message ?? '').toLowerCase();

      if (e.code == 'failed-precondition' &&
          msg.contains('payout setup required')) {
        if (!context.mounted) return;

        final didSetup = await _openPayoutSetupDialog(context);
        if (didSetup == true) {
          // retry confirm close
          await ContractService().confirmCloseByConversation(
            conversationId: conversationId,
          );

          await ContractService().sendPayout(payoutId: payoutId);

          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Payout sent')));
          }
        }
        return;
      }

      rethrow;
    }
  }
}
