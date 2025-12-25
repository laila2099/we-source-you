import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:we_source_you/model/proposal_model.dart';
import 'package:we_source_you/model/notification_model.dart';
import 'package:we_source_you/model/job_post_model.dart';

class JobProposalsView extends StatefulWidget {
  final JobPostModel job;

  const JobProposalsView({required this.job, super.key});

  @override
  State<JobProposalsView> createState() => _JobProposalsViewState();
}

class _JobProposalsViewState extends State<JobProposalsView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    
    return FutureBuilder<DocumentSnapshot>(
      future: _firestore.collection('jobs').doc(widget.job.id).get(),
      builder: (context, jobSnapshot) {
        if (!jobSnapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        final jobData = jobSnapshot.data!.data() as Map<String, dynamic>?;
        final jobOwnerId = jobData?['userId'] as String?;
        final isJobOwner = user?.uid == jobOwnerId;

        return Scaffold(
      appBar: AppBar(
        title: const Text("Job Proposals"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('proposals')
            .where('jobId', isEqualTo: widget.job.id)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No proposals yet'),
            );
          }

          final proposals = snapshot.data!.docs.map((doc) {
            return ProposalModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
          }).toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: proposals.length,
            itemBuilder: (context, index) {
              final proposal = proposals[index];
              return _buildProposalCard(proposal, isJobOwner);
            },
          );
        },
      ),
    );
      },
    );
  }

  Widget _buildProposalCard(ProposalModel proposal, bool isJobOwner) {
    return FutureBuilder<DocumentSnapshot>(
      future: _firestore.collection('users').doc(proposal.userId).get(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) {
          return const SizedBox.shrink();
        }

        final userData = userSnapshot.data!.data() as Map<String, dynamic>? ?? {};
        final userName = (userData['fullName'] ??
            userData['name'] ??
            userData['companyName'] ??
            'Unknown User')
            .toString();
        final userEmail = userData['email']?.toString() ?? '';

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      child: Text(userName[0].toUpperCase()),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            userEmail,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(proposal.status),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  "Proposal:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  proposal.proposalText,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Submitted: ${_formatDate(proposal.createdAt)}",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    if (isJobOwner && proposal.status == 'pending')
                      Row(
                        children: [
                          TextButton(
                            onPressed: () => _viewProfile(proposal.userId),
                            child: const Text("View Profile"),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => _approveProposal(proposal),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            child: const Text(
                              "Approve",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: () => _rejectProposal(proposal),
                            child: const Text("Reject"),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;
    switch (status) {
      case 'approved':
        color = Colors.green;
        text = 'Approved';
        break;
      case 'rejected':
        color = Colors.red;
        text = 'Rejected';
        break;
      default:
        color = Colors.orange;
        text = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }


  void _viewProfile(String userId) {
    Get.toNamed('/profile/$userId');
  }

  Future<void> _approveProposal(ProposalModel proposal) async {
    try {
      // 1. Update proposal status
      await _firestore.collection('proposals').doc(proposal.id).update({
        'status': 'approved',
        'updatedAt': DateTime.now().toIso8601String(),
      });

      // 2. Get job details
      final jobDoc =
          await _firestore.collection('jobs').doc(proposal.jobId).get();
      final jobData = jobDoc.data();
      final jobTitle = jobData?['title'] ?? 'the job';

      // 3. Create notification for applicant
      final notification = NotificationModel(
        userId: proposal.userId,
        type: 'proposal_approved',
        title: 'Proposal Approved!',
        message: 'Your proposal for "$jobTitle" has been approved!',
        jobId: proposal.jobId,
        proposalId: proposal.id,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('notifications').add(notification.toMap());

      Get.snackbar(
        "Success",
        "Proposal approved and notification sent!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to approve proposal: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _rejectProposal(ProposalModel proposal) async {
    try {
      await _firestore.collection('proposals').doc(proposal.id).update({
        'status': 'rejected',
        'updatedAt': DateTime.now().toIso8601String(),
      });

      Get.snackbar(
        "Success",
        "Proposal rejected",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to reject proposal: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}

