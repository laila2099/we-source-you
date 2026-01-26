import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:we_source_you/core/constant/app_color.dart';
import 'package:we_source_you/core/constant/responsive_layout.dart';
import 'package:we_source_you/routes/app_routes.dart';
import 'package:we_source_you/view/auth/auth_controller/auth_controller.dart';
import 'package:we_source_you/view/notifications/notifications_view.dart';
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
            if (controller.isProfileIncomplete)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100, // لون هادئ للفت الانتباه
                  border: Border(
                    left: BorderSide(color: Colors.amber.shade900, width: 4),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.amber.shade900,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "Please complete your profile verification to go live (Rates, KYC, and Payout).",
                        style: TextStyle(
                          color: Color(0xFF7F5F01),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
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
              const SizedBox(height: 10),

              _buildRatesSection(),
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
              _buildRatesSection(),
            ],

            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    foregroundColor: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.color,
                  ),
                  onPressed: () {
                    Get.toNamed(AppRoutes.payoutSettings);
                  },
                  child: Text(
                    "Payout Settings",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: 5),
                IconButton(
                  icon: Icon(Icons.arrow_forward_ios),
                  iconSize: 12,
                  onPressed: () {
                    Get.toNamed(AppRoutes.payoutSettings);
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),
            // ---------------- KYC Status ----------------
            Obx(() {
              final status = controller.kycStatus.value.trim().toLowerCase();

              return Wrap(
                // استخدمنا Wrap بدلاً من Row لضمان عدم حدوث Overflow في الشاشات الصغيرة
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text(
                    "KYC Status",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 12),

                  if (status == 'rejected') ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "REJECTED ❌",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                      onPressed: () => Get.toNamed(AppRoutes.kyc),
                      child: const Text("Re-submit KYC"),
                    ),
                  ] else if (status.isEmpty)
                    ElevatedButton(
                      onPressed: () => Get.toNamed(AppRoutes.kyc),
                      child: const Text("Start KYC Verification"),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: status == 'approved'
                            ? Colors.green.shade100
                            : Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          color: status == 'approved'
                              ? Colors.green.shade800
                              : Colors.blue.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              );
            }),
            const SizedBox(height: 16),

            Obx(() {
              return Row(
                children: [
                  const Text("Available: "),
                  Switch(
                    value: controller.available.value,
                    onChanged: controller.canBeAvailable
                        ? (val) => controller.toggleAvailability(val)
                        : null, // disabled if rates are missing
                  ),
                ],
              );
            }),
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

  Widget _buildRatesSection() {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Rates :", style: TextStyle(fontWeight: FontWeight.bold)),
          _profileField(
            "Hourly Rate",
            TextEditingController()
              ..text = controller.hourlyRate.value.toString(),
            controller.isEditing,
            maxLines: 1,
            onChanged: (val) =>
                controller.hourlyRate.value = double.tryParse(val) ?? 0,
          ),
          _profileField(
            "Daily Rate",
            TextEditingController()
              ..text = controller.dailyRate.value.toString(),
            controller.isEditing,
            maxLines: 1,
            onChanged: (val) =>
                controller.dailyRate.value = double.tryParse(val) ?? 0,
          ),
          _profileField(
            "Project Rate",
            TextEditingController()
              ..text = controller.projectRate.value.toString(),
            controller.isEditing,
            maxLines: 1,
            onChanged: (val) =>
                controller.projectRate.value = double.tryParse(val) ?? 0,
          ),
        ],
      );
    });
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
                    // ... جزء الصورة يبقى كما هو ...
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
                      _buildPlaceholderIcon(),

                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  jobTitle,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              // عرض السعر هنا بخط بارز ولون مميز
                              Text(
                                "\$${proposal.bidAmount}", // تأكد أن حقل السعر اسمه price في الموديل
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(
                                    0xFFE8744F,
                                  ), // نفس لون زر التقديم
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
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
                // السطر السفلي (الحالة والتاريخ)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(
                          proposal.status,
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        proposal.status.toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(proposal.status),
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

  // دالة مساعدة للألوان لجعل الكود أنظف
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green.shade800;
      case 'rejected':
        return Colors.red.shade800;
      default:
        return Colors.orange.shade800;
    }
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
                value: controller.analystSpecialty.isEmpty
                    ? null
                    : controller.analystSpecialty.first,
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
                onChanged: (value) {
                  if (value != null) {
                    controller.analystSpecialty.value = [
                      value,
                    ]; // تعيين القيمة كعنصر وحيد في مصفوفة
                  }
                },
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
                      controller.analystSpecialty.isNotEmpty) {
                    label += " (${controller.analystSpecialty.join(', ')})";
                  }
                  return Chip(
                    label: Text(label),
                    onDeleted: () {
                      if (type == controller.individualJob.value) {
                        controller.individualJob.value = '';
                        controller.analystSpecialty
                            .clear(); // مسح المصفوفة                      } else {
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

  Widget _buildPlaceholderIcon() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.work, size: 30, color: Colors.grey),
    );
  }

  Widget _profileField(
    String label,
    TextEditingController ctrl,
    RxBool isEdit, {
    bool obscure = false,
    int maxLines = 1,
    Function(String)? onChanged,
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
                      onChanged: onChanged,
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
