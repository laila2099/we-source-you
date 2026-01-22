import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:we_source_you/core/constant/app_color.dart';
import 'package:we_source_you/core/constant/responsive_layout.dart';
import 'package:we_source_you/routes/app_routes.dart';
import 'package:we_source_you/view/auth/auth_controller/auth_controller.dart';
import 'package:we_source_you/view/profile/profile_cotroller/profile_controller.dart';
import 'package:we_source_you/model/job_post_model.dart';
import 'package:we_source_you/view/jobs/job_proposals/job_proposals_view.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:we_source_you/model/proposal_model.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final controller = Get.put(ProfileController());
  final authController = Get.find<AuthController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.lightBlue, AppColors.darkBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ResponsiveLayout(
          mobile: _buildMobile(context),
          tablet: _buildTablet(context),
          desktop: _buildDesktop(context),
        ),
      ),
    );
  }

  /// ---------------- MOBILE ----------------
  Widget _buildMobile(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: _cardDecoration(context),
        padding: const EdgeInsets.all(16),
        child: _buildProfileContent(context),
      ),
    );
  }

  /// ---------------- TABLET ----------------
  Widget _buildTablet(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 900),
        margin: const EdgeInsets.all(32),
        decoration: _cardDecoration(context),
        padding: const EdgeInsets.all(24),
        child: _buildProfileContent(context),
      ),
    );
  }

  /// ---------------- DESKTOP ----------------
  Widget _buildDesktop(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1100),
        margin: const EdgeInsets.all(40),
        decoration: _cardDecoration(context),
        padding: const EdgeInsets.all(32),
        child: _buildProfileContent(context),
      ),
    );
  }

  BoxDecoration _cardDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BoxDecoration(
      color: isDark ? Colors.grey[900] : Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  Widget _buildProfileContent(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton(
              onPressed: () {
                Get.toNamed(AppRoutes.kyc);
              },
              child: Text("Navigate"),
            ),
            if (authController.role.value == 'admin')
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        "Admin",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Get.toNamed(AppRoutes.adminDashboard);
                        },
                        child: Text("Go to DashBoard"),
                      ),
                    ],
                  ),
                ),
              ),
            // ---------------- Profile Info ----------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  iconSize: 18,
                  color: theme.textTheme.bodySmall?.color,
                  onPressed: controller.goBack,
                  icon: const Icon(Icons.arrow_back),
                ),
                Text(
                  controller.accountType.value == "individual"
                      ? "Personal Information"
                      : "Company Information",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: controller.isEditing.value
                      ? controller.saveProfile
                      : () => controller.isEditing.value = true,
                  child: Text(
                    controller.isEditing.value ? "Save" : "Edit",
                    style: const TextStyle(
                      color: AppColors.lightBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ---------------- FIELDS ----------------
            if (controller.accountType.value == "individual") ...[
              _profileField(
                "First Name",
                controller.fullNameCtrl,
                controller.isEditing,
              ),
              _profileField(
                "Email",
                controller.emailCtrl,
                controller.isEditing,
              ),
              _profileField(
                "Phone",
                controller.phoneCtrl,
                controller.isEditing,
              ),
              _profileField(
                "Country",
                controller.countryCtrl,
                controller.isEditing,
              ),
              const SizedBox(height: 20),
              _buildMediaWorkTypesSection(),
            ] else ...[
              _profileField(
                "Company Name",
                controller.companyNameCtrl,
                controller.isEditing,
              ),
              _profileField(
                "Email",
                controller.emailCtrl,
                controller.isEditing,
              ),
              _profileField(
                "Phone",
                controller.phoneCtrl,
                controller.isEditing,
              ),
              _profileField(
                "Country",
                controller.countryCtrl,
                controller.isEditing,
              ),
              _profileField(
                "Website",
                controller.websiteCtrl,
                controller.isEditing,
              ),
            ],

            const SizedBox(height: 24),

            // ---------------- Posted Jobs ----------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Posted Jobs",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => Get.toNamed('/post'),
                  child: const Text(
                    "Post New Job",
                    style: TextStyle(color: AppColors.lightBlue),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Obx(() {
              if (controller.isLoadingJobs.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.postedJobs.isEmpty) {
                return const Center(child: Text("No jobs posted yet"));
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.postedJobs.length,
                itemBuilder: (context, index) {
                  final job = controller.postedJobs[index];
                  return _buildJobCard(job);
                },
              );
            }),

            const SizedBox(height: 24),
            const Divider(),
            Obx(() {
              return Row(
                children: [
                  const Text("Available: "),
                  Switch(
                    value: controller.available.value,
                    onChanged: (val) => controller.toggleAvailability(val),
                  ),
                ],
              );
            }),

            const SizedBox(height: 16),

            // ---------------- User Proposals ----------------
            const Text(
              "My Proposals",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('proposals')
                  .where('userId', isEqualTo: controller.uid)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Error loading proposals: ${snapshot.error}",
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        "You have not submitted any proposals yet.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }

                final proposals = snapshot.data!.docs.map((doc) {
                  try {
                    return ProposalModel.fromMap(
                      doc.data() as Map<String, dynamic>,
                      doc.id,
                    );
                  } catch (e) {
                    return ProposalModel(
                      id: doc.id,
                      jobId: '',
                      userId: '',
                      proposalText: 'Error loading proposal',
                      createdAt: DateTime.now(),
                    );
                  }
                }).toList();

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: proposals.length,
                  itemBuilder: (context, index) {
                    final proposal = proposals[index];
                    return _buildUserProposalCard(proposal);
                  },
                );
              },
            ),

            const SizedBox(height: 24),
          ],
        ),
      );
    });
  }

  Widget _buildJobCard(JobPostModel job) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => controller.navigateToJob(job),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      job.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (job.isUrgent)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        "Urgent",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                job.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (job.minSalary != null && job.maxSalary != null)
                    Text(
                      "\$${job.minSalary!.toStringAsFixed(0)} - \$${job.maxSalary!.toStringAsFixed(0)} ${job.currency}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.lightBlue,
                      ),
                    ),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(
                    label: Text(job.jobType),
                    backgroundColor: Colors.blue.shade50,
                  ),
                  if (job.jobLocationType.isNotEmpty)
                    Chip(
                      label: Text(job.jobLocationType),
                      backgroundColor: Colors.green.shade50,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      Get.to(() => JobProposalsView(job: job));
                    },
                    icon: const Icon(Icons.people, size: 18),
                    label: const Text("View Proposals"),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.lightBlue,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserProposalCard(ProposalModel proposal) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('jobs')
              .doc(proposal.jobId)
              .get(),
          builder: (context, jobSnap) {
            if (!jobSnap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final jobData = jobSnap.data!.data() as Map<String, dynamic>?;
            final jobTitle = jobData?['title'] ?? 'Unknown Job';
            final jobImageUrl = jobData?['imageUrl'];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (jobImageUrl != null && jobImageUrl.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          jobImageUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.work,
                          size: 30,
                          color: Colors.grey,
                        ),
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            jobTitle,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            proposal.proposalText,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
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
                      DateFormat('MMM dd, yyyy').format(proposal.createdAt),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMediaWorkTypesSection() {
    return Obx(() {
      // دمج individualJob مع mediaWorkTypes بدون تكرار
      List<String> allJobs = [];
      if (controller.individualJob.value.isNotEmpty) {
        allJobs.add(controller.individualJob.value);
      }
      allJobs.addAll(
        controller.mediaWorkTypes.where(
          (type) => type != controller.individualJob.value,
        ),
      ); // بدون تكرار

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Job Types",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          if (controller.isEditing.value) ...[
            // Dropdown لاختيار الوظيفة الأساسية
            DropdownButtonFormField<String>(
              value: controller.individualJob.value.isEmpty
                  ? null
                  : controller.individualJob.value,
              items: const [
                DropdownMenuItem(value: "Producer", child: Text("منتج")),
                DropdownMenuItem(value: "Reporter", child: Text("مراسل")),
                DropdownMenuItem(
                  value: "TV Cameraman",
                  child: Text("مصور تلفزيوني"),
                ),
                DropdownMenuItem(
                  value: "Photographer",
                  child: Text("مصور ضوئي"),
                ),
                DropdownMenuItem(value: "Editor", child: Text("مونتير")),
                DropdownMenuItem(value: "Trainer", child: Text("مدرب")),
                DropdownMenuItem(
                  value: "Graphic Designer",
                  child: Text("مصمم غرافيك"),
                ),
                DropdownMenuItem(
                  value: "Media Lawyer",
                  child: Text("محامي مختص بالشأن الاعلامي"),
                ),
                DropdownMenuItem(value: "Voice Over", child: Text("فويس أوفر")),
                DropdownMenuItem(value: "Translator", child: Text("مترجم")),
                DropdownMenuItem(value: "Analyst", child: Text("محلل")),
              ],

              onChanged: (value) {
                controller.individualJob.value = value ?? '';

                if (value != null &&
                    !controller.mediaWorkTypes.contains(value)) {
                  controller.mediaWorkTypes.insert(0, value);
                }
              },

              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Select your job",
              ),
            ),

            const SizedBox(height: 12),

            // Dropdown لتخصص Analyst
            if (controller.individualJob.value == "Analyst") ...[
              const Text(
                "Analyst Specialty",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: controller.analystSpecialty.value.isEmpty
                    ? null
                    : controller.analystSpecialty.value,
                items: const [
                  DropdownMenuItem(
                    value: "Arabic Affairs",
                    child: Text("عربي"),
                  ),
                  DropdownMenuItem(
                    value: "Kurdish Affairs",
                    child: Text("كردي"),
                  ),
                  DropdownMenuItem(
                    value: "Persian Affairs",
                    child: Text("فارسي"),
                  ),
                ],
                onChanged: (value) =>
                    controller.analystSpecialty.value = value ?? '',
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Select specialty",
                ),
              ),
              const SizedBox(height: 12),
            ],

            // عرض كل الوظائف كـ Chips مع إمكانية الحذف
            if (allJobs.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: allJobs.map((type) {
                  String label = type;
                  if (type == "Analyst" &&
                      controller.analystSpecialty.value.isNotEmpty) {
                    label += " (${controller.analystSpecialty.value})";
                  }
                  return Chip(
                    label: Text(label),
                    onDeleted: () {
                      if (type == controller.individualJob.value) {
                        controller.individualJob.value = '';
                        controller.analystSpecialty.value = '';
                      } else {
                        controller.removeMediaWorkType(type);
                      }
                    },
                    deleteIcon: const Icon(Icons.close, size: 18),
                  );
                }).toList(),
              ),
          ] else ...[
            // عرض الوظائف بدون تعديل
            if (allJobs.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: allJobs.map((type) {
                  String label = type;
                  if (type == "Analyst" &&
                      controller.analystSpecialty.value.isNotEmpty) {
                    label += " (${controller.analystSpecialty.value})";
                  }
                  return Chip(label: Text(label));
                }).toList(),
              )
            else
              const Text(
                "No job types added",
                style: TextStyle(color: Colors.grey),
              ),
          ],
        ],
      );
    });
  }

  Widget _profileField(
    String label,
    TextEditingController ctrl,
    RxBool isEdit, {
    bool obscure = false,
    int maxLines = 1,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              return isEdit.value
                  ? TextField(
                      controller: ctrl,
                      obscureText: obscure,
                      maxLines: maxLines,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        obscure ? "*" * ctrl.text.length : ctrl.text,
                        style: TextStyle(
                          color: ctrl.text.isEmpty ? Colors.grey : null,
                        ),
                      ),
                    );
            }),
          ),
        ],
      ),
    );
  }
}
