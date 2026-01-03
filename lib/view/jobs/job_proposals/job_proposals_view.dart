import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:we_source_you/model/job_post_model.dart';
import 'package:we_source_you/model/proposal_model.dart';
import 'package:intl/intl.dart';

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
      body: StreamBuilder<QuerySnapshot>(
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
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: proposal.status == 'approved'
                                  ? Colors.green.shade100
                                  : proposal.status == 'rejected'
                                  ? Colors.red.shade100
                                  : Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              proposal.status.toUpperCase(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: proposal.status == 'approved'
                                    ? Colors.green.shade800
                                    : proposal.status == 'rejected'
                                    ? Colors.red.shade800
                                    : Colors.orange.shade800,
                                fontSize: 12,
                              ),
                            ),
                          ),
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
