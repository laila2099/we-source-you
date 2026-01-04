// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:we_source_you/model/job_post_model.dart';
// import 'package:we_source_you/model/proposal_model.dart';
// import 'package:we_source_you/model/notification_model.dart';
// import 'package:we_source_you/routes/app_routes.dart';

// class JobApply extends StatefulWidget {
//   @override
//   State<JobApply> createState() => _JobApplyState();
// }

// class _JobApplyState extends State<JobApply> {
//   final TextEditingController _proposalController = TextEditingController();
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   bool _isSubmitting = false;

//   @override
//   void dispose() {
//     _proposalController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final arguments = Get.arguments;

//     // Handle different argument types
//     if (arguments == null) {
//       return Scaffold(
//         appBar: AppBar(title: const Text("Job Details")),
//         body: const Center(child: Text("No job data provided")),
//       );
//     }

//     if (arguments is JobPostModel) {
//       return _buildScaffold(arguments);
//     } else if (arguments is String) {
//       // If argument is job ID, fetch from Firestore
//       return FutureBuilder<DocumentSnapshot>(
//         future: FirebaseFirestore.instance
//             .collection('jobs')
//             .doc(arguments)
//             .get(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Scaffold(
//               appBar: AppBar(title: const Text("Job Details")),
//               body: const Center(child: CircularProgressIndicator()),
//             );
//           }

//           if (!snapshot.hasData || !snapshot.data!.exists) {
//             return Scaffold(
//               appBar: AppBar(title: const Text("Job Details")),
//               body: const Center(child: Text("Job not found")),
//             );
//           }

//           try {
//             final data = snapshot.data!.data() as Map<String, dynamic>?;
//             if (data == null) {
//               return Scaffold(
//                 appBar: AppBar(title: const Text("Job Details")),
//                 body: const Center(child: Text("Invalid job data")),
//               );
//             }

//             final job = JobPostModel.fromMap(data);
//             job.id = snapshot.data!.id;

//             return _buildScaffold(job);
//           } catch (e) {
//             return Scaffold(
//               appBar: AppBar(title: const Text("Job Details")),
//               body: Center(child: Text("Error loading job: $e")),
//             );
//           }
//         },
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(title: const Text("Job Details")),
//       body: Center(
//         child: Text("Invalid job data type: ${arguments.runtimeType}"),
//       ),
//     );
//   }

//   Widget _buildScaffold(JobPostModel job) {
//     final user = _auth.currentUser;

//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FB),
//       appBar: AppBar(
//         title: const Text("Job Details"),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 0.5,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             _buildHeaderSection(job),
//             const SizedBox(height: 20),
//             _buildRequirementsGrid(job),
//             const SizedBox(height: 20),
//             _buildApplySection(job, user),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildHeaderSection(JobPostModel job) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(15),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           Text(
//             job.title,
//             style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 10),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               _statusBadge("published", Colors.green),
//               const SizedBox(width: 10),
//               const Icon(Icons.access_time, size: 16, color: Colors.grey),
//               Text(
//                 " Posted ${job.deadline != null ? "${job.deadline!.day}/${job.deadline!.month}/${job.deadline!.year}" : ''}",
//                 style: const TextStyle(color: Colors.grey),
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: const Color(0xFFEDF2F7),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Text(
//               "\$${job.minSalary ?? 0} - \$${job.maxSalary ?? 0} ${job.currency}",
//               style: const TextStyle(
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

//   Widget _buildRequirementsGrid(JobPostModel job) {
//     // Helper widget for lists (Chips)
//     Widget listTile(String title, List<String> items, {IconData? icon}) {
//       if (items.isEmpty) return const SizedBox.shrink();
//       return Container(
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: Colors.white.withOpacity(0.15),
//           borderRadius: BorderRadius.circular(15),
//           border: Border.all(color: Colors.white.withOpacity(0.2)),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 if (icon != null) Icon(icon, color: Colors.white, size: 18),
//                 if (icon != null) const SizedBox(width: 8),
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.w600,
//                     fontSize: 13,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 6),
//             Wrap(
//               spacing: 6,
//               runSpacing: 4,
//               children: items
//                   .map(
//                     (t) => Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 10,
//                         vertical: 4,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.3),
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: Text(
//                         t,
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 11,
//                         ),
//                       ),
//                     ),
//                   )
//                   .toList(),
//             ),
//           ],
//         ),
//       );
//     }

//     // Helper widget for single info
//     Widget infoTile(String title, String value) {
//       if (value.isEmpty) return const SizedBox.shrink();
//       return Container(
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: Colors.white.withOpacity(0.15),
//           borderRadius: BorderRadius.circular(15),
//           border: Border.all(color: Colors.white.withOpacity(0.2)),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               title,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.w600,
//                 fontSize: 13,
//               ),
//             ),
//             const SizedBox(height: 6),
//             Text(
//               value,
//               style: const TextStyle(color: Colors.white, fontSize: 12),
//             ),
//           ],
//         ),
//       );
//     }

//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: const Color(0xFF7E72D6),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             "Job Details & Requirements",
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 20),
//           GridView(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 2,
//               mainAxisSpacing: 15,
//               crossAxisSpacing: 15,
//               childAspectRatio: 1.2,
//             ),
//             children: [
//               listTile("Skills", job.skills, icon: Icons.sell),
//               listTile("Media Work Types", job.mediaTypes, icon: Icons.work),
//               listTile("Languages", job.languages, icon: Icons.language),
//               listTile("Locations", job.locations, icon: Icons.location_on),
//               listTile("Benefits", job.benefits, icon: Icons.card_giftcard),
//               listTile("Categories", job.categories, icon: Icons.category),
//               listTile("Tags", job.tags, icon: Icons.tag),
//               // Scalar info
//               infoTile("Experience Level", job.experienceLevel),
//               infoTile("Job Type", job.jobType),
//               infoTile("Positions Available", job.numPositions.toString()),
//               infoTile(
//                 "Portfolio Required",
//                 job.portfolioRequired ? "Yes" : "No",
//               ),
//               infoTile("Can Travel", job.canTravel ? "Yes" : "No"),
//               infoTile("Has Camera", job.hasCamera ? "Yes" : "No"),
//               infoTile("Has Audio", job.hasAudio ? "Yes" : "No"),
//               infoTile("Currency", job.currency),
//               infoTile("Salary Period", job.period),
//               infoTile("Project Details", job.projectDetails),
//               infoTile(
//                 "Start Date",
//                 job.startDate != null
//                     ? "${job.startDate!.day}/${job.startDate!.month}/${job.startDate!.year}"
//                     : "",
//               ),
//               infoTile(
//                 "End Date",
//                 job.endDate != null
//                     ? "${job.endDate!.day}/${job.endDate!.month}/${job.endDate!.year}"
//                     : "",
//               ),
//               infoTile(
//                 "Deadline",
//                 job.deadline != null
//                     ? "${job.deadline!.day}/${job.deadline!.month}/${job.deadline!.year}"
//                     : "",
//               ),
//               infoTile("Additional Info", job.additionalInfo),
//               infoTile("Contact Name", job.contactName),
//               infoTile("Contact Email", job.contactEmail),
//               infoTile("Contact Phone", job.contactPhone),
//               infoTile("Contact Method", job.contactMethod),
//               infoTile("Urgent", job.isUrgent ? "Yes" : "No"),
//               infoTile("Featured", job.isFeatured ? "Yes" : "No"),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildApplySection(JobPostModel job, User? user) {
//     // 1️⃣ المستخدم غير مسجل
//     if (user == null) {
//       return Container(
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           color: Colors.orange.shade50,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: Colors.orange),
//         ),
//         child: Column(
//           children: [
//             const Icon(Icons.warning, color: Colors.orange, size: 40),
//             const SizedBox(height: 10),
//             const Text(
//               "You must be signed in to apply for this job",
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 Get.toNamed(AppRoutes.signin);
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFFE8744F),
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 30,
//                   vertical: 15,
//                 ),
//               ),
//               child: const Text(
//                 "Sign In",
//                 style: TextStyle(fontSize: 16, color: Colors.white),
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     // 2️⃣ منع صاحب الوظيفة من تقديم بروبوزال لنفسه
//     if (user.uid == job.userId) {
//       return Container(
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           color: Colors.grey.shade200,
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: const Center(
//           child: Text(
//             "You cannot submit a proposal for your own job.",
//             style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//           ),
//         ),
//       );
//     }

//     // 3️⃣ المستخدم مسجل وليس صاحب الوظيفة → عرض الفورم لتقديم البروپوزال
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           "Your Proposal",
//           style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 12),
//         TextField(
//           controller: _proposalController,
//           maxLines: 8,
//           decoration: InputDecoration(
//             hintText: "Write your proposal here...",
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//             filled: true,
//             fillColor: Colors.white,
//           ),
//         ),
//         const SizedBox(height: 20),
//         SizedBox(
//           width: double.infinity,
//           child: ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFFE8744F),
//               minimumSize: const Size(double.infinity, 55),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//             onPressed: _isSubmitting ? null : () => _submitProposal(job, user),
//             child: _isSubmitting
//                 ? const SizedBox(
//                     height: 20,
//                     width: 20,
//                     child: CircularProgressIndicator(
//                       strokeWidth: 2,
//                       valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                     ),
//                   )
//                 : const Text(
//                     "Apply for the job",
//                     style: TextStyle(fontSize: 18, color: Colors.white),
//                   ),
//           ),
//         ),
//       ],
//     );
//   }

//   Future<void> _submitProposal(JobPostModel job, User user) async {
//     if (job.id == null || job.id!.isEmpty) {
//       Get.snackbar(
//         "Error",
//         "Cannot submit proposal: missing job id",
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//       return;
//     }

//     if (_proposalController.text.trim().isEmpty) {
//       Get.snackbar(
//         "Error",
//         "Please write your proposal",
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//       return;
//     }

//     setState(() {
//       _isSubmitting = true;
//     });

//     try {
//       // 1. Get job owner
//       final jobDoc = await _firestore.collection('jobs').doc(job.id).get();
//       final jobOwnerId = jobDoc.data()?['userId'] as String?;

//       // 2. Create proposal with status and updatedAt
//       final now = DateTime.now();
//       final proposal = ProposalModel(
//         id: '', // سيتم تعيينه بعد الإضافة
//         jobId: job.id!,
//         userId: user.uid,
//         jobOwnerId: jobOwnerId,
//         proposalText: _proposalController.text.trim(),
//         status: 'pending',
//         createdAt: now,
//         updatedAt: now,
//       );

//       // 3. Save proposal to Firestore
//       final proposalRef = await _firestore
//           .collection('proposals')
//           .add(proposal.toMap());

//       // 4. Update id field in ProposalModel (optional)
//       // proposal.id = proposalRef.id; // إذا أردت استخدامه لاحقاً

//       // 5. Create notification for job owner
//       if (jobOwnerId != null && jobOwnerId.isNotEmpty) {
//         final applicantDoc = await _firestore
//             .collection('users')
//             .doc(user.uid)
//             .get();
//         final applicantData = applicantDoc.data() ?? {};
//         final applicantName =
//             (applicantData['fullName'] ??
//                     applicantData['name'] ??
//                     applicantData['companyName'] ??
//                     'Someone')
//                 .toString();

//         final notification = NotificationModel(
//           userId: jobOwnerId,
//           type: 'proposal_received',
//           title: 'New Proposal Received',
//           message: '$applicantName has submitted a proposal for "${job.title}"',
//           jobId: job.id,
//           proposalId: proposalRef.id,
//           createdAt: DateTime.now(),
//         );

//         await _firestore.collection('notifications').add(notification.toMap());
//       }

//       Get.snackbar(
//         "Success",
//         "Proposal submitted successfully!",
//         backgroundColor: Colors.green,
//         colorText: Colors.white,
//       );
//       _proposalController.clear();
//     } catch (e) {
//       Get.snackbar(
//         "Error",
//         "Failed to submit proposal: $e",
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     } finally {
//       setState(() {
//         _isSubmitting = false;
//       });
//     }
//   }

//   Widget _statusBadge(String text, Color color) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(12),
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
//               const SizedBox(width: 8),
//               Expanded(
//                 child: Text(
//                   title,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.w600,
//                     fontSize: 13,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const Spacer(),
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
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.3),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Text(
//         label,
//         style: const TextStyle(color: Colors.white, fontSize: 11),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:we_source_you/model/job_post_model.dart';
import 'package:we_source_you/model/proposal_model.dart';
import 'package:we_source_you/model/notification_model.dart';
import 'package:we_source_you/routes/app_routes.dart';
import 'package:we_source_you/core/constant/responsive_layout.dart';

class JobApply extends StatefulWidget {
  const JobApply({super.key});

  @override
  State<JobApply> createState() => _JobApplyState();
}

class _JobApplyState extends State<JobApply> {
  final _proposalController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  bool _isSubmitting = false;

  @override
  void dispose() {
    _proposalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;

    if (args == null) {
      return _errorScaffold("No job data provided");
    }

    if (args is JobPostModel) {
      return _buildScaffold(context, args);
    }

    if (args is String) {
      return FutureBuilder<DocumentSnapshot>(
        future: _firestore.collection('jobs').doc(args).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _loadingScaffold();
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return _errorScaffold("Job not found");
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final job = JobPostModel.fromMap(data)..id = snapshot.data!.id;

          return _buildScaffold(context, job);
        },
      );
    }

    return _errorScaffold("Invalid job argument");
  }

  // ---------------------------------------------------------------------------
  // Scaffold + Responsive Layout
  // ---------------------------------------------------------------------------

  Widget _buildScaffold(BuildContext context, JobPostModel job) {
    final user = _auth.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: const Text("Job Details"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: ResponsiveLayout(
        mobile: _buildMobile(job, user),
        tablet: _buildTablet(job, user),
        desktop: _buildDesktop(job, user),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Responsive Builders
  // ---------------------------------------------------------------------------

  Widget _buildMobile(JobPostModel job, User? user) {
    return _scrollWrapper(
      margin: const EdgeInsets.all(16),
      child: _buildContent(job, user),
    );
  }

  Widget _buildTablet(JobPostModel job, User? user) {
    return _scrollWrapper(
      margin: const EdgeInsets.all(32),
      maxWidth: 900,
      child: _buildContent(job, user),
    );
  }

  Widget _buildDesktop(JobPostModel job, User? user) {
    return _scrollWrapper(
      margin: const EdgeInsets.all(40),
      maxWidth: 1100,
      child: _buildContent(job, user),
    );
  }

  Widget _scrollWrapper({
    required Widget child,
    required EdgeInsets margin,
    double? maxWidth,
  }) {
    return SingleChildScrollView(
      child: Center(
        child: Container(
          margin: margin,
          constraints: maxWidth != null
              ? BoxConstraints(maxWidth: maxWidth)
              : null,
          child: child,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Main Content
  // ---------------------------------------------------------------------------

  Widget _buildContent(JobPostModel job, User? user) {
    return Column(
      children: [
        _buildHeader(job),
        const SizedBox(height: 24),
        _buildRequirements(job),
        const SizedBox(height: 24),
        _buildApplySection(job, user),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Header
  // ---------------------------------------------------------------------------

  Widget _buildHeader(JobPostModel job) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(Colors.white),
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
              _statusBadge("Published", Colors.green),
              const SizedBox(width: 10),
              if (job.deadline != null)
                Text(
                  "Posted ${_formatDate(job.deadline)}",
                  style: const TextStyle(color: Colors.grey),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: _cardDecoration(const Color(0xFFEDF2F7)),
            child: Text(
              "\$${job.minSalary ?? 0} - \$${job.maxSalary ?? 0} ${job.currency}",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Requirements (Responsive Grid)
  // ---------------------------------------------------------------------------

  Widget _buildRequirements(JobPostModel job) {
    final List<Widget> tiles = [];

    void addList(String title, List<String> items, IconData icon) {
      if (items.isNotEmpty) {
        tiles.add(_listTile(title, items, icon));
      }
    }

    void addInfo(String title, String value) {
      if (value.trim().isNotEmpty) {
        tiles.add(_infoTile(title, value));
      }
    }

    void addBool(String title, bool value) {
      tiles.add(_infoTile(title, value ? "Yes" : "No"));
    }

    addList("Skills", job.skills, Icons.sell);
    addList("Media Types", job.mediaTypes, Icons.work);
    addList("Languages", job.languages, Icons.language);
    addList("Locations", job.locations, Icons.location_on);
    addList("Benefits", job.benefits, Icons.card_giftcard);
    addList("Categories", job.categories, Icons.category);
    addList("Tags", job.tags, Icons.tag);

    addInfo("Experience Level", job.experienceLevel);
    addInfo("Job Type", job.jobType);
    addInfo("Positions", job.numPositions.toString());
    addInfo("Currency", job.currency);
    addInfo("Salary Period", job.period);
    addInfo("Project Details", job.projectDetails);
    addInfo("Additional Info", job.additionalInfo);
    addInfo("Contact Name", job.contactName);
    addInfo("Contact Email", job.contactEmail);
    addInfo("Contact Phone", job.contactPhone);
    addInfo("Contact Method", job.contactMethod);

    if (job.startDate != null) {
      addInfo("Start Date", _formatDate(job.startDate));
    }
    if (job.endDate != null) {
      addInfo("End Date", _formatDate(job.endDate));
    }
    if (job.deadline != null) {
      addInfo("Deadline", _formatDate(job.deadline));
    }

    addBool("Portfolio Required", job.portfolioRequired);
    addBool("Can Travel", job.canTravel);
    addBool("Has Camera", job.hasCamera);
    addBool("Has Audio", job.hasAudio);
    addBool("Urgent", job.isUrgent);
    addBool("Featured", job.isFeatured);

    if (tiles.isEmpty) return const SizedBox.shrink();

    final crossAxisCount = ResponsiveLayout.isDesktop(context)
        ? 3
        : ResponsiveLayout.isTablet(context)
        ? 2
        : 1;

    Widget content;

    if (ResponsiveLayout.isMobile(context)) {
      // على الموبايل: خليهم ياخدوا حجمهم الطبيعي
      content = Wrap(
        spacing: 12,
        runSpacing: 12,
        children: tiles.map((tile) {
          return IntrinsicWidth(child: tile);
        }).toList(),
      );
    } else {
      // على التابلت والديسكتوب: نستخدم MasonryGrid
      content = MasonryGridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        itemCount: tiles.length,
        itemBuilder: (context, index) {
          return tiles[index];
        },
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(const Color(0xFF7E72D6)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Job Details & Requirements",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          content,
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Apply Section
  // ---------------------------------------------------------------------------

  Widget _buildApplySection(JobPostModel job, User? user) {
    if (user == null) {
      return _warningBox(
        "You must be signed in to apply",
        "Sign In",
        () => Get.toNamed(AppRoutes.signin),
      );
    }

    if (user.uid == job.userId) {
      return _infoBox("You cannot apply to your own job.");
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Your Proposal",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _proposalController,
          maxLines: 8,
          decoration: InputDecoration(
            hintText: "Write your proposal here...",
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : () => _submitProposal(job, user),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE8744F),
              minimumSize: const Size.fromHeight(55),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isSubmitting
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    "Apply for the job",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Submit Proposal
  // ---------------------------------------------------------------------------

  Future<void> _submitProposal(JobPostModel job, User user) async {
    if (_proposalController.text.trim().isEmpty) {
      Get.snackbar(
        "Error",
        "Proposal is required",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final jobDoc = await _firestore.collection('jobs').doc(job.id).get();
      final ownerId = jobDoc.data()?['userId'];

      final proposal = ProposalModel(
        jobId: job.id!,
        userId: user.uid,
        jobOwnerId: ownerId,
        proposalText: _proposalController.text.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final ref = await _firestore
          .collection('proposals')
          .add(proposal.toMap());

      if (ownerId != null) {
        await _firestore
            .collection('notifications')
            .add(
              NotificationModel(
                userId: ownerId,
                type: 'proposal_received',
                title: 'New Proposal',
                message: 'New proposal submitted for "${job.title}"',
                jobId: job.id,
                proposalId: ref.id,
                createdAt: DateTime.now(),
              ).toMap(),
            );
      }

      Get.snackbar(
        "Success",
        "Proposal submitted",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      _proposalController.clear();
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Widget _listTile(String title, List<String> items, IconData icon) {
    return _glassTile(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(spacing: 6, runSpacing: 4, children: items.map(_chip).toList()),
        ],
      ),
    );
  }

  Widget _infoTile(String title, String value) {
    return _glassTile(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _glassTile(Widget child) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: _cardDecoration(Colors.white.withOpacity(0.15)),
      child: child,
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 11),
      ),
    );
  }

  Widget _statusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  String _formatDate(DateTime? d) =>
      d == null ? "" : "${d.day}/${d.month}/${d.year}";

  BoxDecoration _cardDecoration(Color color) =>
      BoxDecoration(color: color, borderRadius: BorderRadius.circular(15));

  Widget _errorScaffold(String msg) => Scaffold(
    appBar: AppBar(title: const Text("Job Details")),
    body: Center(child: Text(msg)),
  );

  Widget _loadingScaffold() =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));

  Widget _warningBox(String text, String button, VoidCallback onTap) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(Colors.orange.shade50),
      child: Column(
        children: [
          Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ElevatedButton(onPressed: onTap, child: Text(button)),
        ],
      ),
    );
  }

  Widget _infoBox(String text) => Container(
    padding: const EdgeInsets.all(20),
    decoration: _cardDecoration(Colors.grey.shade200),
    child: Center(child: Text(text)),
  );
}
