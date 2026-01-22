import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:we_source_you/model/job_post_model.dart';
import 'package:we_source_you/model/proposal_model.dart';
import 'package:we_source_you/model/notification_model.dart';
import 'package:we_source_you/routes/app_routes.dart';
import 'package:we_source_you/core/constant/responsive_layout.dart';
import 'package:we_source_you/view/jobs/apply_job/widgets/build_header.dart';
import 'package:we_source_you/view/jobs/apply_job/widgets/build_requirements.dart';
import 'package:we_source_you/view/jobs/apply_job/widgets/helper_widgets.dart';

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
      return errorScaffold("No job data provided");
    }

    if (args is JobPostModel) {
      return _buildScaffold(context, args);
    }

    if (args is String) {
      return FutureBuilder<DocumentSnapshot>(
        future: _firestore.collection('jobs').doc(args).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return loadingScaffold();
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return errorScaffold("Job not found");
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          print("Firebase Raw Data (createdAt): ${data['createdAt']}");

          final job = JobPostModel.fromMap(data);
          job.id = snapshot.data!.id;

          return _buildScaffold(context, job);
        },
      );
    }

    return errorScaffold("Invalid job argument");
  }

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

  Widget _buildContent(JobPostModel job, User? user) {
    return Column(
      children: [
        buildHeader(job),
        const SizedBox(height: 24),
        buildRequirements(job, context),
        const SizedBox(height: 24),
        buildApplySection(job, user),
      ],
    );
  }

  Widget buildApplySection(JobPostModel job, User? user) {
    if (user == null) {
      return warningBox(
        "You must be signed in to apply",
        "Sign In",
        () => Get.toNamed(AppRoutes.signin),
      );
    }

    if (user.uid == job.userId) {
      return infoBox("You cannot apply to your own job.");
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
            onPressed: _isSubmitting ? null : () => submitProposal(job, user),
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

  Future<void> submitProposal(JobPostModel job, User user) async {
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

      final docRef = FirebaseFirestore.instance.collection('proposals').doc();

      final proposal = ProposalModel(
        id: docRef.id,
        jobId: job.id!,
        userId: user.uid,
        jobOwnerId: ownerId,
        proposalText: _proposalController.text.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await docRef.set(proposal.toMap());

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
                proposalId: docRef.id,
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
}
