// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:we_source_you/view/jobs/jobs_controller/jobs_controller.dart';

// class JobApply extends GetView<JobsController> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xFFF8F9FB),
//       appBar: AppBar(
//         title: Text("Job Details"),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 0.5,
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             _buildHeaderSection(),
//             SizedBox(height: 20),
//             _buildRequirementsGrid(),
//             SizedBox(height: 20),
//             _buildApplySection(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildHeaderSection() {
//     return Container(
//       padding: EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(15),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.end, // For Arabic alignment
//         children: [
//           Text(
//             controller.title,
//             style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//           ),
//           SizedBox(height: 10),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               _statusBadge("published", Colors.green),
//               SizedBox(width: 10),
//               Icon(Icons.access_time, size: 16, color: Colors.grey),
//               Text(" Posted 11/29/2025", style: TextStyle(color: Colors.grey)),
//             ],
//           ),
//           SizedBox(height: 20),
//           Container(
//             width: double.infinity,
//             padding: EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: Color(0xFFEDF2F7),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Text(
//               controller.priceRange,
//               style: TextStyle(
//                 fontSize: 22,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black87,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildRequirementsGrid() {
//     return Container(
//       padding: EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Color(0xFF7E72D6), // The purple background
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Column(
//         children: [
//           Text(
//             "Key Job Requirements",
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           SizedBox(height: 20),
//           GridView.count(
//             shrinkWrap: true,
//             physics: NeverScrollableScrollPhysics(),
//             crossAxisCount: 2,
//             mainAxisSpacing: 15,
//             crossAxisSpacing: 15,
//             childAspectRatio: 1.2,
//             children: [
//               RequirementTile(
//                 icon: Icons.sell,
//                 title: "Required Skills",
//                 tags: controller.skills,
//               ),
//               RequirementTile(
//                 icon: Icons.work,
//                 title: "Media Work Types",
//                 tags: ["Reporter"],
//               ),
//               RequirementTile(
//                 icon: Icons.language,
//                 title: "Required Languages",
//                 tags: controller.languages,
//               ),
//               RequirementTile(
//                 icon: Icons.location_on,
//                 title: "Job Locations",
//                 tags: ["Madrid"],
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildApplySection() {
//     return ElevatedButton(
//       style: ElevatedButton.styleFrom(
//         backgroundColor: const Color(0xFFE8744F),
//         minimumSize: const Size(double.infinity, 55),
//         // Fix: Wrap the radius in a RoundedRectangleBorder
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       ),
//       onPressed: () {
//         // Add your GetX logic here, e.g., controller.applyForJob();
//       },
//       child: const Text(
//         "Apply for the job",
//         style: TextStyle(fontSize: 18, color: Colors.white),
//       ),
//     );
//   }

//   Widget _statusBadge(String text, Color color) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Text(
//         text,
//         style: TextStyle(color: color, fontWeight: FontWeight.bold),
//       ),
//     );
//   }
// }

// class RequirementTile extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final List<String> tags;

//   const RequirementTile({
//     required this.icon,
//     required this.title,
//     required this.tags,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.15),
//         borderRadius: BorderRadius.circular(15),
//         border: Border.all(color: Colors.white.withOpacity(0.2)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(icon, color: Colors.white, size: 18),
//               SizedBox(width: 8),
//               Expanded(
//                 child: Text(
//                   title,
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.w600,
//                     fontSize: 13,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           Spacer(),
//           Wrap(
//             spacing: 4,
//             runSpacing: 4,
//             children: tags.map((t) => _chip(t)).toList(),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _chip(String label) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.3),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Text(label, style: TextStyle(color: Colors.white, fontSize: 11)),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:we_source_you/model/job_post_model.dart';
import 'package:we_source_you/model/proposal_model.dart';
import 'package:we_source_you/model/notification_model.dart';
import 'package:we_source_you/routes/app_routes.dart';

class JobApply extends StatefulWidget {
  @override
  State<JobApply> createState() => _JobApplyState();
}

class _JobApplyState extends State<JobApply> {
  final TextEditingController _proposalController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _proposalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final arguments = Get.arguments;
    
    // Handle different argument types
    if (arguments == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Job Details")),
        body: const Center(child: Text("No job data provided")),
      );
    }
    
    if (arguments is JobPostModel) {
      return _buildScaffold(arguments);
    } else if (arguments is String) {
      // If argument is job ID, fetch from Firestore
      return FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('jobs').doc(arguments).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              appBar: AppBar(title: const Text("Job Details")),
              body: const Center(child: CircularProgressIndicator()),
            );
          }
          
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Scaffold(
              appBar: AppBar(title: const Text("Job Details")),
              body: const Center(child: Text("Job not found")),
            );
          }
          
          try {
            final data = snapshot.data!.data() as Map<String, dynamic>?;
            if (data == null) {
              return Scaffold(
                appBar: AppBar(title: const Text("Job Details")),
                body: const Center(child: Text("Invalid job data")),
              );
            }
            
            final job = JobPostModel.fromMap(data);
            job.id = snapshot.data!.id;
            
            return _buildScaffold(job);
          } catch (e) {
            return Scaffold(
              appBar: AppBar(title: const Text("Job Details")),
              body: Center(child: Text("Error loading job: $e")),
            );
          }
        },
      );
    }
    
    return Scaffold(
      appBar: AppBar(title: const Text("Job Details")),
      body: Center(
        child: Text("Invalid job data type: ${arguments.runtimeType}"),
      ),
    );
  }

  Widget _buildScaffold(JobPostModel job) {
    final user = _auth.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: const Text("Job Details"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildHeaderSection(job),
            const SizedBox(height: 20),
            _buildRequirementsGrid(job),
            const SizedBox(height: 20),
            _buildApplySection(job, user),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(JobPostModel job) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            job.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _statusBadge("published", Colors.green),
              const SizedBox(width: 10),
              const Icon(Icons.access_time, size: 16, color: Colors.grey),
              Text(
                " Posted ${job.deadline != null ? "${job.deadline!.day}/${job.deadline!.month}/${job.deadline!.year}" : ''}",
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFEDF2F7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "\$${job.minSalary ?? 0} - \$${job.maxSalary ?? 0} ${job.currency}",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementsGrid(JobPostModel job) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF7E72D6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text(
            "Key Job Requirements",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 15,
            crossAxisSpacing: 15,
            childAspectRatio: 1.2,
            children: [
              RequirementTile(
                icon: Icons.sell,
                title: "Required Skills",
                tags: job.skills,
              ),
              RequirementTile(
                icon: Icons.work,
                title: "Media Work Types",
                tags: job.mediaTypes,
              ),
              RequirementTile(
                icon: Icons.language,
                title: "Required Languages",
                tags: job.languages,
              ),
              RequirementTile(
                icon: Icons.location_on,
                title: "Job Locations",
                tags: job.locations,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildApplySection(JobPostModel job, User? user) {
    if (user == null) {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange),
            ),
            child: Column(
              children: [
                const Icon(Icons.warning, color: Colors.orange, size: 40),
                const SizedBox(height: 10),
                const Text(
                  "You must be signed in to apply for this job",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Get.toNamed(AppRoutes.signin);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE8744F),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                  ),
                  child: const Text(
                    "Sign In",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Your Proposal",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _proposalController,
          maxLines: 8,
          decoration: InputDecoration(
            hintText: "Write your proposal here...",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE8744F),
              minimumSize: const Size(double.infinity, 55),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _isSubmitting ? null : () => _submitProposal(job, user),
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    "Apply for the job",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _submitProposal(JobPostModel job, User user) async {
    if (job.id == null || job.id!.isEmpty) {
      Get.snackbar(
        "Error",
        "Cannot submit proposal: missing job id",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (_proposalController.text.trim().isEmpty) {
      Get.snackbar(
        "Error",
        "Please write your proposal",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // 1. Get job owner (userId from job)
      final jobDoc = await _firestore.collection('jobs').doc(job.id).get();
      final jobOwnerId = jobDoc.data()?['userId'] as String?;

      // 2. Create proposal
      final proposal = ProposalModel(
        jobId: job.id!,
        userId: user.uid,
        jobOwnerId: jobOwnerId,
        proposalText: _proposalController.text.trim(),
        createdAt: DateTime.now(),
      );

      // 3. Save proposal to Firestore
      final proposalRef = await _firestore
          .collection('proposals')
          .add(proposal.toMap());

      if (jobOwnerId != null && jobOwnerId.isNotEmpty) {
        // 4. Get applicant's name
        final applicantDoc =
            await _firestore.collection('users').doc(user.uid).get();
        final applicantData = applicantDoc.data() ?? {};
        final applicantName = (applicantData['fullName'] ?? applicantData['name'] ?? applicantData['companyName'] ?? 'Someone').toString();

        // 6. Create notification for job owner
        final notification = NotificationModel(
          userId: jobOwnerId,
          type: 'proposal_received',
          title: 'New Proposal Received',
          message: '$applicantName has submitted a proposal for "${job.title}"',
          jobId: job.id,
          proposalId: proposalRef.id,
          createdAt: DateTime.now(),
        );

        await _firestore
            .collection('notifications')
            .add(notification.toMap());
      }

      Get.snackbar(
        "Success",
        "Your proposal has been submitted successfully!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      _proposalController.clear();
      Get.back();
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to submit proposal: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Widget _statusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class RequirementTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> tags;

  const RequirementTile({
    required this.icon,
    required this.title,
    required this.tags,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: tags.map((t) => _chip(t)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 11),
      ),
    );
  }
}
