import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:we_source_you/model/job_post_model.dart';
import 'package:we_source_you/model/payment_models.dart';
import 'package:we_source_you/model/proposal_model.dart';
import 'package:we_source_you/model/team_model.dart';
import 'package:we_source_you/view/team/team_profile.dart';

class JobProposalsView extends StatelessWidget {
  final JobPostModel job;

  const JobProposalsView({required this.job, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Proposals for ${job.title}"),
        centerTitle: true,
      ),
      body: job.id == null || job.id!.isEmpty
          ? const Center(child: Text("Invalid job ID"))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('proposals')
                  .where('jobId', isEqualTo: job.id)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text("Error loading proposals: ${snapshot.error}"),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text("No proposals submitted for this job yet."),
                  );
                }

                final proposals = snapshot.data!.docs.map((doc) {
                  return ProposalModel.fromMap(
                    doc.data() as Map<String, dynamic>,
                    doc.id,
                  );
                }).toList();

                return ListView.builder(
                  itemCount: proposals.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final proposal = proposals[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              proposal.proposalText,
                              style: const TextStyle(fontSize: 16),
                            ),

                            const SizedBox(height: 12),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _statusChip(proposal.status),
                                Text(
                                  DateFormat(
                                    'MMM dd, yyyy',
                                  ).format(proposal.createdAt),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            Row(
                              children: [
                                /// -------- View Profile --------
                                Expanded(
                                  child: OutlinedButton.icon(
                                    icon: const Icon(Icons.person),
                                    label: const Text("View Profile"),
                                    onPressed: () async {
                                      _openTeamProfile(proposal.userId);
                                    },
                                  ),
                                ),

                                const SizedBox(width: 8),

                                /// -------- Reject --------
                                if (proposal.status == 'pending')
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      onPressed: () {
                                        _updateProposalStatus(
                                          proposal.id,
                                          'rejected',
                                        );
                                      },
                                      child: const Text("Reject"),
                                    ),
                                  ),

                                const SizedBox(width: 8),

                                /// -------- Approve --------
                                if (proposal.status == 'pending')
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                      ),
                                      onPressed: () {
                                        _showProposalPaymentSheet(proposal);
                                      },
                                      child: const Text("Approve"),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

Widget _statusChip(String status) {
  Color bg;
  Color text;

  switch (status) {
    case 'approved':
      bg = Colors.green.shade100;
      text = Colors.green.shade800;
      break;
    case 'rejected':
      bg = Colors.red.shade100;
      text = Colors.red.shade800;
      break;
    default:
      bg = Colors.orange.shade100;
      text = Colors.orange.shade800;
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      status.toUpperCase(),
      style: TextStyle(fontWeight: FontWeight.bold, color: text, fontSize: 12),
    ),
  );
}

Future<void> _updateProposalStatus(String proposalId, String status) async {
  await FirebaseFirestore.instance
      .collection('proposals')
      .doc(proposalId)
      .update({'status': status, 'updatedAt': FieldValue.serverTimestamp()});
}

Future<void> _openTeamProfile(String userId) async {
  try {
    final doc = await FirebaseFirestore.instance
        .collection('team')
        .doc(userId)
        .get();

    if (!doc.exists) {
      Get.snackbar('Error', 'Profile not found');
      return;
    }

    final member = TeamModel.fromMap(doc.data()!);

    Get.to(() => TeamProfileView(member: member));
  } catch (e) {
    Get.snackbar('Error', 'Failed to load profile');
  }
}

// في ملف JobProposalsView.dart

Future<void> _showProposalPaymentSheet(ProposalModel proposal) async {
  // 1. التأكد من وجود مبلغ صالح
  final jobDoc = await FirebaseFirestore.instance
      .collection('jobs')
      .doc(proposal.jobId)
      .get();
  if (!jobDoc.exists) return;

  final jobData = jobDoc.data()!;
  // الأولوية للسعر الموجود في البروبوزال إذا كان موجوداً، وإلا ميزانية الوظيفة
  // (يفضل أن يكون البروبوزال يحتوي على السعر المتفق عليه 'bidAmount')
  final double amount = (proposal.amount ?? jobData['budget'] ?? 0.0)
      .toDouble();

  if (amount <= 0) {
    Get.snackbar('Error', 'Invalid job amount');
    return;
  }

  // 2. حقن الكونترولر إذا لم يكن موجوداً
  // if (!Get.isRegistered<PaymentController>()) {
  //   Get.put(PaymentController());
  // }

  // 3. إظهار الـ Sheet الجديد
  Get.bottomSheet(
    PaymentSummarySheet(
      title: jobData['title'] ?? 'Job Proposal',
      subtitle: proposal.proposalText,
      amount: amount,
      proposalId: proposal.id ?? '',
      jobId: proposal.jobId,
      teamId: proposal.userId,
    ),
    isScrollControlled: true,
  );
}

class PaymentSummarySheet extends StatelessWidget {
  final String title;
  final String subtitle;
  final double amount;
  // بيانات نحتاجها للدفع
  final String proposalId;
  final String jobId;
  final String teamId;

  const PaymentSummarySheet({
    super.key,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.proposalId,
    required this.jobId,
    required this.teamId,
  });

  @override
  Widget build(BuildContext context) {
    // استدعاء الكونترولر الذي بنيناه سابقاً
    // final PaymentController controller = Get.find<PaymentController>();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(width: 40, height: 4, color: Colors.grey[300]),
          ),
          const SizedBox(height: 20),

          Text(
            "Confirm Payment",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey),
          ),

          const Divider(height: 30),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total Amount",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                "\$${amount.toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),
          Text(
            "Select Payment Method",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 10),

          // --- Stripe Button ---
          _PaymentMethodTile(
            icon: Icons.credit_card,
            label: "Credit Card (Stripe)",
            color: Colors.deepPurple,
            onTap: () {
              // _handlePayment(controller, PaymentMethod.stripe);
            },
          ),

          const SizedBox(height: 10),

          // --- PayPal Button ---
          _PaymentMethodTile(
            icon: Icons.paypal,
            label: "PayPal",
            color: Colors.blue,
            onTap: () {
              // _handlePayment(controller, PaymentMethod.paypal);
            },
          ),
        ],
      ),
    );
  }

  void _handlePayment(
    // PaymentController controller,
    PaymentMethod method,
  ) async {
    // 1. إغلاق الـ Sheet لتجنب التكرار
    // Get.back();
    //
    // // 2. استدعاء دالة الدفع من الكونترولر
    // final result = await controller.initiateMarketplacePayment(
    //   type: MarketItemType.proposal, // نوع الدفع
    //   method: method,
    //   proposalId: proposalId,
    //   jobId: jobId,
    //   amount: amount,
    //   // يمكن إضافة hireType إذا كان متوفراً
    // );
    //
    // // 3. التعامل مع النتيجة (الكونترولر يقوم بالدفع والحجز)
    // if (result.success) {
    //   // هنا يتم توجيه المستخدم للشات لأن الدفع تم حجزه بنجاح
    //   // ويتم تحديث حالة الـ Proposal في الباك إند عبر الـ Webhook
    //   Get.snackbar(
    //     "Success",
    //     "Funds secured! Opening chat...",
    //     backgroundColor: Colors.green,
    //     colorText: Colors.white,
    //   );
    //
    //   // التوجيه إلى صفحة الشات
    //   // Get.to(() => ChatScreen(jobId: jobId));
    // }
  }
}

class _PaymentMethodTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _PaymentMethodTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(width: 15),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
