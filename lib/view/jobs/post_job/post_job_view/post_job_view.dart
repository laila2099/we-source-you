import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:we_source_you/core/constant/responsive_layout.dart';
import 'package:we_source_you/routes/app_routes.dart';
import 'package:we_source_you/view/auth/auth_controller/auth_controller.dart';
import 'package:we_source_you/view/jobs/post_job/post_job_controller/post_job_controller.dart';
import 'package:we_source_you/widgets/glass_morphism.dart';

// class JobPostScreen extends StatelessWidget {
//   final JobPostController controller = Get.put(JobPostController());

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: const Text(
//           "Post a Job",
//           style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back),
//           color: Colors.black,
//           onPressed: () {
//             Get.back();
//           },
//         ),
//       ),
//       body: Column(
//         children: [
//           _buildStepperHeader(),
//           Expanded(
//             child: Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(16),
//               // The main container background similar to screenshots
//               decoration: const BoxDecoration(color: Colors.white),
//               child: Obx(() => _buildCurrentStep(controller.currentStep.value)),
//             ),
//           ),
//           _buildBottomControls(),
//         ],
//       ),
//     );
//   }

//   // --- HEADER STEPPER ---
//   Widget _buildStepperHeader() {
//     final steps = [
//       "Basics",
//       "Details",
//       "Requirements",
//       "Skills & Languages",
//       "Additional Info",
//       "Review & Submit",
//     ];
//     return Container(
//       height: 70,
//       child: ListView.separated(
//         padding: const EdgeInsets.symmetric(horizontal: 16),
//         scrollDirection: Axis.horizontal,
//         itemCount: steps.length,
//         separatorBuilder: (_, __) => const SizedBox(width: 8),
//         itemBuilder: (context, index) {
//           return Obx(() {
//             bool isActive = controller.currentStep.value == index;
//             return Container(
//               width: 100,
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: isActive ? const Color(0xFFEF6C6C) : Colors.white,
//                 border: Border.all(color: Colors.grey.shade300),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     "${index + 1}.",
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: isActive ? Colors.white : Colors.black87,
//                     ),
//                   ),
//                   Text(
//                     steps[index],
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: isActive ? Colors.white : Colors.black87,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ],
//               ),
//             );
//           });
//         },
//       ),
//     );
//   }

//   // --- STEP CONTENT SWITCHER ---
//   Widget _buildCurrentStep(int index) {
//     // The Purple Card Container
//     return Container(
//       decoration: BoxDecoration(
//         color: const Color(0xFF6C63FF).withOpacity(0.9), // Purple shade
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
//       ),
//       padding: const EdgeInsets.all(20),
//       child: SingleChildScrollView(
//         child: Column(
//           children: [
//             // Dynamic Title based on step
//             Text(
//               _getStepTitle(index),
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 22,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               _getStepSubtitle(index),
//               textAlign: TextAlign.center,
//               style: const TextStyle(color: Colors.white70, fontSize: 14),
//             ),
//             const SizedBox(height: 20),

//             // Render specific step widget
//             if (index == 0) _Step1Basics(controller),
//             if (index == 1) _Step2Details(controller),
//             if (index == 2) _Step3Requirements(controller),
//             if (index == 3) _Step4Skills(controller),
//             if (index == 4) _Step5Additional(controller),
//             if (index == 5) _Step6Review(controller),
//           ],
//         ),
//       ),
//     );
//   }

//   String _getStepTitle(int index) {
//     const titles = [
//       "Job Basics",
//       "Job Details",
//       "Job Requirements",
//       "Skills & Languages",
//       "Additional Information",
//       "Review Your Job Posting",
//     ];
//     return titles[index];
//   }

//   String _getStepSubtitle(int index) {
//     const subs = [
//       "Let's start with the essential information about your job posting",
//       "Provide detailed information about compensation, timeline, and project scope",
//       "Specify equipment needs, contact information, and additional requirements",
//       "",
//       "Add benefits, tags, categories, and special job flags",
//       "",
//     ];
//     return subs[index];
//   }

//   // --- BOTTOM BUTTONS ---
//   Widget _buildBottomControls() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           OutlinedButton(
//             onPressed: controller.prevStep,
//             child: const Text("Back", style: TextStyle(color: Colors.black)),
//           ),
//           Obx(
//             () => Text(
//               "Step ${controller.currentStep.value + 1}/6 - Submitting: No",
//               style: const TextStyle(color: Colors.grey),
//             ),
//           ),
//           Obx(() {
//             final auth = Get.find<AuthController>();
//             final loggedIn = auth.isLoggedIn.value;

//             // زر الخطوة الأخيرة
//             if (controller.currentStep.value == 5) {
//               return ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFFEF6C6C),
//                 ),
//                 onPressed: controller.isSubmitting.value
//                     ? null
//                     : () async {
//                         if (loggedIn) {
//                           // تحقق من الحقول المطلوبة
//                           if (controller.titleController.text.isEmpty ||
//                               controller.skillsList.isEmpty ||
//                               controller.contactEmailController.text.isEmpty) {
//                             Get.snackbar(
//                               "Required Fields Missing",
//                               "Please fill Title, Skills, and Contact Email before posting.",
//                               backgroundColor: Colors.red,
//                               colorText: Colors.white,
//                               snackPosition: SnackPosition.BOTTOM,
//                             );
//                             return;
//                           }
//                           // إرسال الوظيفة
//                           controller.submitJob();
//                         } else {
//                           // حفظ خطوة المستخدم الحالية للرجوع بعد تسجيل الدخول
//                           auth.box.write(
//                             'pendingStep',
//                             controller.currentStep.value,
//                           );

//                           // الانتقال لصفحة تسجيل الدخول وانتظار النتيجة
//                           await Get.toNamed(AppRoutes.signin);

//                           // بعد تسجيل الدخول، تحديث الحالة إذا تم تسجيل الدخول فعلياً
//                           if (auth.isLoggedIn.value) {
//                             final step = auth.box.read('pendingStep') ?? 0;
//                             controller.goToStep(step);
//                           }
//                         }
//                       },
//                 child: controller.isSubmitting.value
//                     ? const SizedBox(
//                         width: 20,
//                         height: 20,
//                         child: CircularProgressIndicator(color: Colors.white),
//                       )
//                     : Text(loggedIn ? "Post Job" : "Sign in to Post Job"),
//               );
//             }

//             // باقي الخطوات
//             return ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFFEF6C6C),
//               ),
//               onPressed: controller.nextStep,
//               child: const Text("Next"),
//             );
//           }),
//         ],
//       ),
//     );
//   }
// }

// InputDecoration customInputDecor(String hint) {
//   return InputDecoration(
//     filled: true,
//     fillColor: Colors.white.withOpacity(0.9),
//     hintText: hint,
//     border: OutlineInputBorder(
//       borderRadius: BorderRadius.circular(8),
//       borderSide: BorderSide.none,
//     ),
//     contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//   );
// }

// // --- STEP WIDGETS ---

// class _Step1Basics extends StatelessWidget {
//   final JobPostController c;
//   _Step1Basics(this.c);

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         GlassContainer(
//           title: "Job Title *",
//           child: TextField(
//             controller: c.titleController,
//             decoration: customInputDecor("e.g. Senior Flutter Dev"),
//           ),
//         ),
//         GlassContainer(
//           title: "Job Description *",
//           child: TextField(
//             controller: c.descController,
//             maxLines: 4,
//             decoration: customInputDecor("Enter description..."),
//           ),
//         ),
//         Row(
//           children: [
//             Expanded(
//               child: GlassContainer(
//                 title: "Experience Level",
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 12),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.9),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Obx(
//                     () => DropdownButtonHideUnderline(
//                       child: DropdownButton<String>(
//                         value: c.experienceLevel.value,
//                         items: ["Entry Level", "Mid Level", "Senior"]
//                             .map(
//                               (e) => DropdownMenuItem(value: e, child: Text(e)),
//                             )
//                             .toList(),
//                         onChanged: (v) => c.experienceLevel.value = v!,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 10),
//             Expanded(
//               child: GlassContainer(
//                 title: "Job Type",
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 12),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.9),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Obx(
//                     () => DropdownButtonHideUnderline(
//                       child: DropdownButton<String>(
//                         value: c.jobType.value,
//                         items: const ["Freelance", "Full-Time", "Part-Time", "Contract"]
//                             .map(
//                               (e) => DropdownMenuItem(value: e, child: Text(e)),
//                             )
//                             .toList(),
//                         onChanged: (v) => c.jobType.value = v!,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }

// class _Step2Details extends StatelessWidget {
//   final JobPostController c;
//   _Step2Details(this.c);

//   Future<void> _pickDate(BuildContext context, Rxn<DateTime> target) async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2020),
//       lastDate: DateTime(2030),
//     );
//     if (picked != null) target.value = picked;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         GlassContainer(
//           title: "Salary Range",
//           child: Row(
//             children: [
//               Expanded(
//                 child: TextField(
//                   controller: c.minSalaryController,
//                   decoration: customInputDecor("Min amount"),
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: TextField(
//                   controller: c.maxSalaryController,
//                   decoration: customInputDecor("Max amount"),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         GlassContainer(
//           title: "Project Details",
//           child: TextField(
//             controller: c.projectDetailsController,
//             maxLines: 3,
//             decoration: customInputDecor("Scope, deliverables..."),
//           ),
//         ),
//         Row(
//           children: [
//             Expanded(
//               child: GlassContainer(
//                 title: "Start Date",
//                 child: InkWell(
//                   onTap: () => _pickDate(context, c.startDate),
//                   child: Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.9),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Obx(
//                       () => Text(
//                         c.startDate.value == null
//                             ? "Select Date"
//                             : DateFormat(
//                                 'MM/dd/yyyy',
//                               ).format(c.startDate.value!),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 10),
//             Expanded(
//               child: GlassContainer(
//                 title: "End Date",
//                 child: InkWell(
//                   onTap: () => _pickDate(context, c.endDate),
//                   child: Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.9),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Obx(
//                       () => Text(
//                         c.endDate.value == null
//                             ? "Select Date"
//                             : DateFormat('MM/dd/yyyy').format(c.endDate.value!),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }

// class _Step3Requirements extends StatelessWidget {
//   final JobPostController c;
//   _Step3Requirements(this.c);

//   Widget _buildCheckItem(String label, RxBool value) {
//     return Expanded(
//       child: Obx(
//         () => InkWell(
//           onTap: () => value.value = !value.value,
//           child: Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(
//                 color: value.value ? Colors.white : Colors.transparent,
//               ),
//             ),
//             child: Row(
//               children: [
//                 Icon(
//                   value.value ? Icons.check_circle : Icons.circle_outlined,
//                   color: Colors.white,
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Text(
//                     label,
//                     style: const TextStyle(color: Colors.white, fontSize: 12),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         GlassContainer(
//           title: "Equipment Requirements",
//           child: Column(
//             children: [
//               Row(
//                 children: [
//                   _buildCheckItem("Has Camera", c.hasCamera),
//                   const SizedBox(width: 10),
//                   _buildCheckItem("Has Audio", c.hasAudio),
//                 ],
//               ),
//               const SizedBox(height: 10),
//               Row(
//                 children: [
//                   _buildCheckItem("Can Travel", c.canTravel),
//                   const SizedBox(width: 10),
//                   _buildCheckItem("Portfolio Req.", c.portfolioRequired),
//                 ],
//               ),
//             ],
//           ),
//         ),
//         GlassContainer(
//           title: "Contact Information",
//           child: Column(
//             children: [
//               TextField(
//                 controller: c.contactNameController,
//                 decoration: customInputDecor("Contact Name"),
//               ),
//               const SizedBox(height: 10),
//               TextField(
//                 controller: c.contactEmailController,
//                 decoration: customInputDecor("Contact Email *"),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _Step4Skills extends StatelessWidget {
//   final JobPostController c;
//   _Step4Skills(this.c);

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         GlassContainer(
//           title: "Required Skills",
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               TextField(
//                 controller: c.skillInputController,
//                 decoration: customInputDecor("Type skill & Enter"),
//                 onSubmitted: (_) =>
//                     c.addItemToList(c.skillInputController, c.skillsList),
//               ),
//               const SizedBox(height: 10),
//               Obx(
//                 () => Wrap(
//                   spacing: 8,
//                   children: c.skillsList
//                       .map(
//                         (e) => Chip(
//                           label: Text(e),
//                           onDeleted: () => c.removeItem(c.skillsList, e),
//                         ),
//                       )
//                       .toList(),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         GlassContainer(
//           title: "Locations",
//           child: TextField(
//             controller: c.locationController,
//             decoration: customInputDecor("Type location & Enter"),
//             onSubmitted: (_) =>
//                 c.addItemToList(c.locationController, c.locationList),
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _Step5Additional extends StatelessWidget {
//   final JobPostController c;
//   _Step5Additional(this.c);

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         GlassContainer(
//           title: "Benefits",
//           child: TextField(
//             controller: c.benefitsController,
//             maxLines: 3,
//             decoration: customInputDecor(
//               "Enter benefits separated by commas...",
//             ),
//           ),
//         ),
//         GlassContainer(
//           title: "Job Flags",
//           child: Row(
//             children: [
//               Expanded(
//                 child: Obx(
//                   () => CheckboxListTile(
//                     title: const Text(
//                       "Urgent Job",
//                       style: TextStyle(color: Colors.white),
//                     ),
//                     value: c.isUrgent.value,
//                     onChanged: (v) => c.isUrgent.value = v!,
//                   ),
//                 ),
//               ),
//               Expanded(
//                 child: Obx(
//                   () => CheckboxListTile(
//                     title: const Text(
//                       "Featured Job",
//                       style: TextStyle(color: Colors.white),
//                     ),
//                     value: c.isFeatured.value,
//                     onChanged: (v) => c.isFeatured.value = v!,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _Step6Review extends StatelessWidget {
//   final JobPostController c;
//   _Step6Review(this.c);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: SingleChildScrollView(
//         // أضفنا سكرول لتجنب مشاكل المساحة
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // العنوان الرئيسي مع الحالة
//             Obx(
//               () => Container(
//                 padding: const EdgeInsets.all(16),
//                 color: const Color(0xFFE55F5F),
//                 width: double.infinity,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // هنا نستخدم .text لأنها مراقبة تلقائياً أو نستخدم .value إذا كان obs
//                     Text(
//                       c.titleController.text.isEmpty
//                           ? "No Title"
//                           : c.titleController.text,
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 5),
//                     Row(
//                       children: [
//                         _reviewChip(c.jobType.value), // .value مهمة هنا
//                         const SizedBox(width: 5),
//                         _reviewChip(c.experienceLevel.value),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             const SizedBox(height: 20),
//             const Text(
//               "Project Details",
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black,
//               ),
//             ),
//             const Divider(),

//             // تأكد أن كل Obx يحتوي على متغير .value بداخل نطاقه
//             Obx(() => _infoRow("Positions:", "${c.numPositions.value}")),
//             Obx(
//               () => _infoRow(
//                 "Salary:",
//                 "${c.minSalaryController.text} - ${c.maxSalaryController.text} ${c.currency.value}",
//               ),
//             ),
//             Obx(
//               () => _infoRow(
//                 "Start Date:",
//                 c.startDate.value == null
//                     ? "Flexible"
//                     : DateFormat('yyyy-MM-dd').format(c.startDate.value!),
//               ),
//             ),

//             const SizedBox(height: 20),
//             const Text(
//               "Skills",
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black,
//               ),
//             ),
//             const Divider(),

//             // عرض القائمة
//             Obx(
//               () => Wrap(
//                 spacing: 8,
//                 children: c.skillsList
//                     .map((skill) => Chip(label: Text(skill)))
//                     .toList(),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _reviewChip(String label) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//       decoration: BoxDecoration(
//         color: Colors.white24,
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Text(
//         label,
//         style: const TextStyle(color: Colors.white, fontSize: 12),
//       ),
//     );
//   }

//   Widget _infoRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(label, style: const TextStyle(color: Colors.grey)),
//           Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
//         ],
//       ),
//     );
//   }
// }
class JobPostScreen extends StatelessWidget {
  final JobPostController controller = Get.put(JobPostController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Post a Job",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.black,
          onPressed: () => Get.back(),
        ),
      ),
      body: ResponsiveLayout(
        mobile: _buildMobile(context),
        tablet: _buildTablet(context),
        desktop: _buildDesktop(context),
      ),
    );
  }

  BoxDecoration _cardDecoration(BuildContext context) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
    );
  }

  Widget _buildMobile(BuildContext context) {
    return Padding(
      padding: ResponsiveLayout.screenPadding(context),
      child: Column(
        children: [
          _buildStepperHeader(),
          const SizedBox(height: 16),
          Expanded(
            child: Obx(() => _buildCurrentStep(controller.currentStep.value)),
          ),
          _buildBottomControls(),
        ],
      ),
    );
  }

  Widget _buildTablet(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 900),
        decoration: _cardDecoration(context),
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.all(32),
        child: Column(
          children: [
            _buildStepperHeader(),
            const SizedBox(height: 20),
            Expanded(
              child: Obx(() => _buildCurrentStep(controller.currentStep.value)),
            ),
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktop(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1100),
        decoration: _cardDecoration(context),
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.all(40),
        child: Column(
          children: [
            _buildStepperHeader(),
            const SizedBox(height: 24),
            Expanded(
              child: Obx(() => _buildCurrentStep(controller.currentStep.value)),
            ),
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  // --- HEADER STEPPER ---
  Widget _buildStepperHeader() {
    final steps = [
      "Basics",
      "Details",
      "Requirements",
      "Skills & Languages",
      "Additional Info",
      "Review & Submit",
    ];
    return Container(
      height: 70,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: steps.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return Obx(() {
            bool isActive = controller.currentStep.value == index;
            return Container(
              width: 100,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFFEF6C6C) : Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${index + 1}.",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isActive ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    steps[index],
                    style: TextStyle(
                      fontSize: 12,
                      color: isActive ? Colors.white : Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          });
        },
      ),
    );
  }

  // --- CURRENT STEP CONTENT ---
  Widget _buildCurrentStep(int index) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF6C63FF).withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              _getStepTitle(index),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getStepSubtitle(index),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 20),
            if (index == 0) _Step1Basics(controller),
            if (index == 1) _Step2Details(controller),
            if (index == 2) _Step3Requirements(controller),
            if (index == 3) _Step4Skills(controller),
            if (index == 4) _Step5Additional(controller),
            if (index == 5) _Step6Review(controller),
          ],
        ),
      ),
    );
  }

  String _getStepTitle(int index) {
    const titles = [
      "Job Basics",
      "Job Details",
      "Job Requirements",
      "Skills & Languages",
      "Additional Information",
      "Review Your Job Posting",
    ];
    return titles[index];
  }

  String _getStepSubtitle(int index) {
    const subs = [
      "Let's start with the essential information about your job posting",
      "Provide detailed information about compensation, timeline, and project scope",
      "Specify equipment needs, contact information, and additional requirements",
      "",
      "Add benefits, tags, categories, and special job flags",
      "",
    ];
    return subs[index];
  }

  // --- BOTTOM BUTTONS ---
  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          OutlinedButton(
            onPressed: controller.prevStep,
            child: const Text("Back", style: TextStyle(color: Colors.black)),
          ),
          Obx(
            () => Text(
              "Step ${controller.currentStep.value + 1}/6 - Submitting: No",
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Obx(() {
            final auth = Get.find<AuthController>();
            final loggedIn = auth.isLoggedIn.value;

            if (controller.currentStep.value == 5) {
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF6C6C),
                ),
                onPressed: controller.isSubmitting.value
                    ? null
                    : () async {
                        if (loggedIn) {
                          if (controller.titleController.text.isEmpty ||
                              controller.skillsList.isEmpty ||
                              controller.contactEmailController.text.isEmpty) {
                            Get.snackbar(
                              "Required Fields Missing",
                              "Please fill Title, Skills, and Contact Email before posting.",
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                              snackPosition: SnackPosition.BOTTOM,
                            );
                            return;
                          }
                          controller.submitJob();
                        } else {
                          auth.box.write(
                            'pendingStep',
                            controller.currentStep.value,
                          );
                          await Get.toNamed(AppRoutes.signin);
                          if (auth.isLoggedIn.value) {
                            final step = auth.box.read('pendingStep') ?? 0;
                            controller.goToStep(step);
                          }
                        }
                      },
                child: controller.isSubmitting.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : Text(loggedIn ? "Post Job" : "Sign in to Post Job"),
              );
            }

            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF6C6C),
              ),
              onPressed: controller.nextStep,
              child: const Text("Next"),
            );
          }),
        ],
      ),
    );
  }
}

class _Step1Basics extends StatelessWidget {
  final JobPostController c;
  _Step1Basics(this.c);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GlassContainer(
          title: "Job Title *",
          child: TextField(
            controller: c.titleController,
            decoration: customInputDecor("e.g. Senior Flutter Dev"),
          ),
        ),
        GlassContainer(
          title: "Job Description *",
          child: TextField(
            controller: c.descController,
            maxLines: 4,
            decoration: customInputDecor("Enter description..."),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: GlassContainer(
                title: "Experience Level",
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Obx(
                    () => DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: c.experienceLevel.value,
                        items: ["Entry Level", "Mid Level", "Senior"]
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                        onChanged: (v) => c.experienceLevel.value = v!,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GlassContainer(
                title: "Job Type",
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Obx(
                    () => DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: c.jobType.value,
                        items:
                            const [
                                  "Freelance",
                                  "Full-Time",
                                  "Part-Time",
                                  "Contract",
                                ]
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ),
                                )
                                .toList(),
                        onChanged: (v) => c.jobType.value = v!,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Step2Details extends StatelessWidget {
  final JobPostController c;
  _Step2Details(this.c);

  Future<void> _pickDate(BuildContext context, Rxn<DateTime> target) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) target.value = picked;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GlassContainer(
          title: "Salary Range",
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: c.minSalaryController,
                  decoration: customInputDecor("Min amount"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: c.maxSalaryController,
                  decoration: customInputDecor("Max amount"),
                ),
              ),
            ],
          ),
        ),
        GlassContainer(
          title: "Project Details",
          child: TextField(
            controller: c.projectDetailsController,
            maxLines: 3,
            decoration: customInputDecor("Scope, deliverables..."),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: GlassContainer(
                title: "Start Date",
                child: InkWell(
                  onTap: () => _pickDate(context, c.startDate),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Obx(
                      () => Text(
                        c.startDate.value == null
                            ? "Select Date"
                            : DateFormat(
                                'MM/dd/yyyy',
                              ).format(c.startDate.value!),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GlassContainer(
                title: "End Date",
                child: InkWell(
                  onTap: () => _pickDate(context, c.endDate),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Obx(
                      () => Text(
                        c.endDate.value == null
                            ? "Select Date"
                            : DateFormat('MM/dd/yyyy').format(c.endDate.value!),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Step3Requirements extends StatelessWidget {
  final JobPostController c;
  _Step3Requirements(this.c);

  Widget _buildCheckItem(String label, RxBool value) {
    return Expanded(
      child: Obx(
        () => InkWell(
          onTap: () => value.value = !value.value,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: value.value ? Colors.white : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  value.value ? Icons.check_circle : Icons.circle_outlined,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GlassContainer(
          title: "Equipment Requirements",
          child: Column(
            children: [
              Row(
                children: [
                  _buildCheckItem("Has Camera", c.hasCamera),
                  const SizedBox(width: 10),
                  _buildCheckItem("Has Audio", c.hasAudio),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildCheckItem("Can Travel", c.canTravel),
                  const SizedBox(width: 10),
                  _buildCheckItem("Portfolio Req.", c.portfolioRequired),
                ],
              ),
            ],
          ),
        ),
        GlassContainer(
          title: "Contact Information",
          child: Column(
            children: [
              TextField(
                controller: c.contactNameController,
                decoration: customInputDecor("Contact Name"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: c.contactEmailController,
                decoration: customInputDecor("Contact Email *"),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Step4Skills extends StatelessWidget {
  final JobPostController c;
  _Step4Skills(this.c);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GlassContainer(
          title: "Required Skills",
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: c.skillInputController,
                decoration: customInputDecor("Type skill & Enter"),
                onSubmitted: (_) =>
                    c.addItemToList(c.skillInputController, c.skillsList),
              ),
              const SizedBox(height: 10),
              Obx(
                () => Wrap(
                  spacing: 8,
                  children: c.skillsList
                      .map(
                        (e) => Chip(
                          label: Text(e),
                          onDeleted: () => c.removeItem(c.skillsList, e),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
        GlassContainer(
          title: "Locations",
          child: TextField(
            controller: c.locationController,
            decoration: customInputDecor("Type location & Enter"),
            onSubmitted: (_) =>
                c.addItemToList(c.locationController, c.locationList),
          ),
        ),
      ],
    );
  }
}

class _Step5Additional extends StatelessWidget {
  final JobPostController c;
  _Step5Additional(this.c);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GlassContainer(
          title: "Benefits",
          child: TextField(
            controller: c.benefitsController,
            maxLines: 3,
            decoration: customInputDecor(
              "Enter benefits separated by commas...",
            ),
          ),
        ),
        GlassContainer(
          title: "Job Flags",
          child: Row(
            children: [
              Expanded(
                child: Obx(
                  () => CheckboxListTile(
                    title: const Text(
                      "Urgent Job",
                      style: TextStyle(color: Colors.white),
                    ),
                    value: c.isUrgent.value,
                    onChanged: (v) => c.isUrgent.value = v!,
                  ),
                ),
              ),
              Expanded(
                child: Obx(
                  () => CheckboxListTile(
                    title: const Text(
                      "Featured Job",
                      style: TextStyle(color: Colors.white),
                    ),
                    value: c.isFeatured.value,
                    onChanged: (v) => c.isFeatured.value = v!,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Step6Review extends StatelessWidget {
  final JobPostController c;
  _Step6Review(this.c);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        // أضفنا سكرول لتجنب مشاكل المساحة
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // العنوان الرئيسي مع الحالة
            Obx(
              () => Container(
                padding: const EdgeInsets.all(16),
                color: const Color(0xFFE55F5F),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // هنا نستخدم .text لأنها مراقبة تلقائياً أو نستخدم .value إذا كان obs
                    Text(
                      c.titleController.text.isEmpty
                          ? "No Title"
                          : c.titleController.text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        _reviewChip(c.jobType.value), // .value مهمة هنا
                        const SizedBox(width: 5),
                        _reviewChip(c.experienceLevel.value),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              "Project Details",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const Divider(),

            // تأكد أن كل Obx يحتوي على متغير .value بداخل نطاقه
            Obx(() => _infoRow("Positions:", "${c.numPositions.value}")),
            Obx(
              () => _infoRow(
                "Salary:",
                "${c.minSalaryController.text} - ${c.maxSalaryController.text} ${c.currency.value}",
              ),
            ),
            Obx(
              () => _infoRow(
                "Start Date:",
                c.startDate.value == null
                    ? "Flexible"
                    : DateFormat('yyyy-MM-dd').format(c.startDate.value!),
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              "Skills",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const Divider(),

            // عرض القائمة
            Obx(
              () => Wrap(
                spacing: 8,
                children: c.skillsList
                    .map((skill) => Chip(label: Text(skill)))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _reviewChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

InputDecoration customInputDecor(String hint) {
  return InputDecoration(
    filled: true,
    fillColor: Colors.white.withOpacity(0.9),
    hintText: hint,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  );
}
