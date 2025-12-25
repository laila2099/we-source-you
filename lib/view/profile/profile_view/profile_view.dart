// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:we_source_you/core/constant/app_color.dart';
// import 'package:we_source_you/view/profile/profile_cotroller/profile_controller.dart';

// class ProfileView extends StatelessWidget {
//   ProfileView({super.key});
//   final controller = Get.put(ProfileController());

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Profile"),
//         centerTitle: true,
//         leading: IconButton(
//           iconSize: 18,
//           color: theme.textTheme.bodySmall?.color,
//           onPressed: controller.goBack,
//           icon: const Icon(Icons.arrow_back),
//         ),
//         actions: [
//           Obx(() {
//             return TextButton(
//               onPressed: () {
//                 if (controller.isEditing.value) {
//                   controller.saveProfile();
//                 } else {
//                   controller.isEditing.value = true;
//                 }
//               },
//               child: Text(
//                 controller.isEditing.value ? "Save" : "Edit",
//                 style: const TextStyle(color: Colors.white),
//               ),
//             );
//           }),
//         ],
//       ),
//       body: Obx(() {
//         if (controller.isLoading.value) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         return SingleChildScrollView(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             children: [
//               _profileField(
//                 "First Name",
//                 controller.firstNameCtrl,
//                 controller.isEditing,
//               ),
//               _profileField(
//                 "Last Name",
//                 controller.lastNameCtrl,
//                 controller.isEditing,
//               ),
//               _profileField(
//                 "Email",
//                 controller.emailCtrl,
//                 controller.isEditing,
//               ),
//               _profileField(
//                 "Phone",
//                 controller.phoneCtrl,
//                 controller.isEditing,
//               ),
//               _profileField("City", controller.cityCtrl, controller.isEditing),
//               const SizedBox(height: 16),

//               // --- Password Row ---
//               Row(
//                 children: [
//                   SizedBox(
//                     width: 120,
//                     child: const Text(
//                       "Password",
//                       style: TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                   ),

//                   const SizedBox(width: 8),
//                   TextButton(
//                     onPressed: () {
//                       // Navigate to Change Password page
//                     },
//                     child: const Text(
//                       'Forgot?',
//                       style: TextStyle(color: AppColors.darkBlue, fontSize: 13),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         );
//       }),
//     );
//   }

//   Widget _profileField(
//     String label,
//     TextEditingController ctrl,
//     RxBool isEdit, {
//     bool obscure = false,
//   }) {
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         children: [
//           SizedBox(
//             width: 120,
//             child: Text(
//               label,
//               style: const TextStyle(fontWeight: FontWeight.bold),
//             ),
//           ),
//           Expanded(
//             child: Obx(() {
//               return isEdit.value
//                   ? TextField(
//                       controller: ctrl,
//                       obscureText: obscure,
//                       decoration: const InputDecoration(
//                         border: OutlineInputBorder(),
//                       ),
//                     )
//                   : Text(obscure ? "*" * ctrl.text.length : ctrl.text);
//             }),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:we_source_you/core/constant/app_color.dart';
import 'package:we_source_you/view/profile/profile_cotroller/profile_controller.dart';
import 'package:we_source_you/model/job_post_model.dart';
import 'package:we_source_you/view/jobs/job_proposals/job_proposals_view.dart';
import 'package:intl/intl.dart';

class ProfileView extends StatelessWidget {
  ProfileView({super.key});
  final controller = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
        leading: IconButton(
          iconSize: 18,
          color: theme.textTheme.bodySmall?.color,
          onPressed: controller.goBack,
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          Obx(() {
            return TextButton(
              onPressed: () {
                if (controller.isEditing.value) {
                  controller.saveProfile();
                } else {
                  controller.isEditing.value = true;
                }
              },
              child: Text(
                controller.isEditing.value ? "Save" : "Edit",
                style: const TextStyle(color: Colors.white),
              ),
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Information Section
              Text(
                controller.accountType.value == "individual"
                    ? "Personal Information"
                    : "Company Information",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              if (controller.accountType.value == "individual") ...[
                _profileField(
                  "First Name",
                  controller.firstNameCtrl,
                  controller.isEditing,
                ),
                _profileField(
                  "Last Name",
                  controller.lastNameCtrl,
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
                  "City",
                  controller.cityCtrl,
                  controller.isEditing,
                ),
                const SizedBox(height: 8),
                // Media Work Types (Multiple)
                _buildMediaWorkTypesSection(),
                _profileField(
                  "Social Links",
                  controller.socialLinksCtrl,
                  controller.isEditing,
                ),
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
                  "City",
                  controller.cityCtrl,
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
                _profileField(
                  "Description",
                  controller.descriptionCtrl,
                  controller.isEditing,
                  maxLines: 3,
                ),
              ],

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              // Posted Jobs Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Posted Jobs",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Get.toNamed('/post'),
                    child: const Text("Post New Job"),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Obx(() {
                if (controller.isLoadingJobs.value) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (controller.postedJobs.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text("No jobs posted yet"),
                    ),
                  );
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

              const SizedBox(height: 16),

              // Password Section
              const Divider(),
              const SizedBox(height: 16),
              Row(
                children: [
                  SizedBox(
                    width: 120,
                    child: const Text(
                      "Password",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      // Navigate to Change Password page
                    },
                    child: const Text(
                      'Forgot?',
                      style: TextStyle(color: AppColors.darkBlue, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildMediaWorkTypesSection() {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Job Types",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (controller.isEditing.value) ...[
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.mediaWorkTypeCtrl,
                    decoration: const InputDecoration(
                      hintText: "Add job type...",
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => controller.addMediaWorkType(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: controller.addMediaWorkType,
                  color: AppColors.lightBlue,
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.mediaWorkTypes.map((type) {
              return Chip(
                label: Text(type),
                onDeleted: controller.isEditing.value
                    ? () => controller.removeMediaWorkType(type)
                    : null,
                deleteIcon: const Icon(Icons.close, size: 18),
              );
            }).toList(),
          ),
          if (controller.mediaWorkTypes.isEmpty && !controller.isEditing.value)
            const Text(
              "No job types added",
              style: TextStyle(color: Colors.grey),
            ),
        ],
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
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
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
                  if (job.deadline != null)
                    Text(
                      "Deadline: ${DateFormat('MMM dd, yyyy').format(job.deadline!)}",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
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
                  if (job.locations.isNotEmpty)
                    Chip(
                      label: Text(job.locations.first),
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
