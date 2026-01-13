// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:we_source_you/model/team_model.dart';
// import 'package:we_source_you/core/constant/app_color.dart';
// import 'package:we_source_you/widgets/circular_icon/circular_icon.dart';
// import 'package:we_source_you/widgets/custom_buttom/custom_buttom.dart';
// import 'package:we_source_you/core/services/payment_controller.dart';
// import 'package:we_source_you/model/payment_models.dart';
// import 'package:we_source_you/widgets/payment/payment_summary_sheet.dart';

// class TeamProfileView extends StatelessWidget {
//   final TeamModel member;
//   const TeamProfileView({super.key, required this.member});

//   void _showHireMeDialog(BuildContext context) {
//     Get.dialog(
//       AlertDialog(
//         title: const Text('Choose Hire Type'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ListTile(
//               title: const Text('Hourly'),
//               subtitle: Text(member.hourlyRate),
//               onTap: () {
//                 Get.back();
//                 _showPaymentSheet(
//                   HireType.hourly,
//                   _parseRate(member.hourlyRate),
//                 );
//               },
//             ),
//             ListTile(
//               title: const Text('Daily'),
//               subtitle: Text(member.dailyRate),
//               onTap: () {
//                 Get.back();
//                 _showPaymentSheet(HireType.daily, _parseRate(member.dailyRate));
//               },
//             ),
//             ListTile(
//               title: const Text('Project'),
//               subtitle: Text(member.projectRate),
//               onTap: () {
//                 Get.back();
//                 _showPaymentSheet(
//                   HireType.project,
//                   _parseRate(member.projectRate),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   double _parseRate(String rate) {
//     // Parse rate string like "50.00/hr" or "500.00/day" or "5000.00"
//     final cleaned = rate.replaceAll(RegExp(r'[^\d.]'), '');
//     return double.tryParse(cleaned) ?? 0.0;
//   }

//   void _showPaymentSheet(HireType hireType, double rate) {
//     if (!Get.isRegistered<PaymentController>()) {
//       Get.put(PaymentController());
//     }

//     final paymentController = Get.find<PaymentController>();
//     // Use member name as teamId - backend will look up by name
//     final teamId = member.name;

//     Get.bottomSheet(
//       PaymentSummarySheet(
//         title: 'Hire ${member.name}',
//         subtitle: '${hireType.name.toUpperCase()} Rate',
//         amount: rate,
//         onConfirm: () {
//           paymentController.processHiringPayment(
//             teamId: teamId,
//             hireType: hireType,
//             rate: rate,
//           );
//         },
//       ),
//       isScrollControlled: true,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final TextStyle nameStyle = Theme.of(context).textTheme.headlineSmall!
//         .copyWith(fontWeight: FontWeight.bold, fontSize: 24);
//     final TextStyle titleStyle = Theme.of(
//       context,
//     ).textTheme.bodyMedium!.copyWith(color: Colors.grey);

//     return DefaultTabController(
//       length: 3,
//       child: Scaffold(
//         appBar: AppBar(
//           backgroundColor: AppColors.lightBlue,
//           title: Text(member.name),
//           bottom: const TabBar(
//             tabs: [
//               Tab(text: 'Overview'),
//               Tab(text: 'Rates & Reviews'),
//               Tab(text: 'Projects'),
//             ],
//           ),
//         ),
//         body: TabBarView(
//           children: [
//             // ---------------- Overview Tab ----------------
//             SingleChildScrollView(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Avatar + Name + Title
//                   Row(
//                     children: [
//                       CircularIcon(
//                         gradientColors: [
//                           AppColors.lightBlue,
//                           const Color.fromARGB(79, 155, 39, 176),
//                         ],
//                         child: Center(
//                           child: Text(
//                             member.name[0].toUpperCase(),
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 16),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(member.name, style: nameStyle),
//                             Text(member.title, style: titleStyle),
//                             Row(
//                               children: [
//                                 const Icon(
//                                   Icons.location_on,
//                                   size: 16,
//                                   color: Colors.grey,
//                                 ),
//                                 const SizedBox(width: 4),
//                                 Text(
//                                   member.location,
//                                   style: const TextStyle(color: Colors.grey),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 20),

//                   // Specialties
//                   Text('Specialties', style: nameStyle),
//                   const SizedBox(height: 10),
//                   Wrap(
//                     spacing: 8,
//                     runSpacing: 8,
//                     children: member.specialties
//                         .map(
//                           (tag) => Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 8,
//                               vertical: 4,
//                             ),
//                             decoration: BoxDecoration(
//                               color: Colors.grey.shade100,
//                               borderRadius: BorderRadius.circular(4),
//                               border: Border.all(color: Colors.grey.shade300),
//                             ),
//                             child: Text(
//                               tag,
//                               style: const TextStyle(
//                                 fontSize: 12,
//                                 color: Colors.black87,
//                               ),
//                             ),
//                           ),
//                         )
//                         .toList(),
//                   ),
//                   const SizedBox(height: 20),

//                   // Stats
//                   Text('Stats', style: nameStyle),
//                   const SizedBox(height: 10),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                     children: [
//                       _StatColumn(count: member.projects, label: 'Projects'),
//                       _StatColumn(count: member.clients, label: 'Clients'),
//                       _StatColumn(count: member.years, label: 'Years'),
//                     ],
//                   ),
//                   WebHoverButton(
//                     text: "Hire me",
//                     onPressed: () => _showHireMeDialog(context),
//                   ),
//                 ],
//               ),
//             ),

//             // ---------------- Rates & Reviews Tab ----------------
//             SingleChildScrollView(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text('Rates', style: nameStyle),
//                   const SizedBox(height: 10),
//                   _RateRow(label: 'Hourly', rate: member.hourlyRate),
//                   _RateRow(label: 'Daily', rate: member.dailyRate),
//                   _RateRow(label: 'Project', rate: member.projectRate),
//                   const SizedBox(height: 20),

//                   Text('Reviews', style: nameStyle),
//                   const SizedBox(height: 10),
//                   Row(
//                     children: [
//                       Text(
//                         '${member.rating.toStringAsFixed(1)} ',
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 18,
//                         ),
//                       ),
//                       const Icon(Icons.star, color: Colors.amber, size: 20),
//                       const SizedBox(width: 8),
//                       Text(
//                         '(${member.reviews} reviews)',
//                         style: const TextStyle(color: Colors.grey),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),

//             // ---------------- Projects Tab ----------------
//             // ---------------- Projects Tab ----------------
//             SingleChildScrollView(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text('Projects', style: nameStyle),
//                   const SizedBox(height: 10),
//                   Text('Total Projects: ${member.projects}'),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ------------------- Widgets reused -------------------
// class _StatColumn extends StatelessWidget {
//   final String count;
//   final String label;
//   const _StatColumn({required this.count, required this.label});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Text(
//           count,
//           style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//         ),
//         Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
//       ],
//     );
//   }
// }

// class _RateRow extends StatelessWidget {
//   final String label;
//   final String rate;
//   const _RateRow({required this.label, required this.rate});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(label, style: const TextStyle(color: Colors.grey)),
//           Text(rate, style: const TextStyle(fontWeight: FontWeight.bold)),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:we_source_you/model/payment_models.dart';
import 'package:we_source_you/model/team_model.dart';
import 'package:we_source_you/core/constant/app_color.dart';
import 'package:we_source_you/view/jobs/job_proposals/job_proposals_view.dart';
import 'package:we_source_you/widgets/circular_icon/circular_icon.dart';
import 'package:we_source_you/widgets/custom_buttom/custom_buttom.dart';
import 'package:we_source_you/core/services/payment_controller.dart';
import 'package:we_source_you/widgets/payment/payment_summary_sheet.dart';

class TeamProfileView extends StatelessWidget {
  final TeamModel member;
  const TeamProfileView({super.key, required this.member});

  void _showHireMeDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Choose Hire Type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Hourly'),
              subtitle: Text(member.hourlyRate),
              onTap: () {
                Get.back();
                // _showPaymentSheet(
                //   HireType.hourly,
                //   _parseRate(member.hourlyRate),
                // );
              },
            ),
            ListTile(
              title: const Text('Daily'),
              subtitle: Text(member.dailyRate),
              onTap: () {
                Get.back();
                // _showPaymentSheet(HireType.daily, _parseRate(member.dailyRate));
              },
            ),
            ListTile(
              title: const Text('Project'),
              subtitle: Text(member.projectRate),
              onTap: () {
                Get.back();
                // _showPaymentSheet(
                //   HireType.project,
                //   _parseRate(member.projectRate),
                // );
              },
            ),
          ],
        ),
      ),
    );
  }

  double _parseRate(String rate) {
    final cleaned = rate.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(cleaned) ?? 0.0;
  }

  void _showPaymentSheet(
    // HireType hireType,
    double rate,
  ) {
    if (!Get.isRegistered<PaymentController>()) {
      Get.put(PaymentController());
    }

    final paymentController = Get.find<PaymentController>();
    final teamId = member.name;

    Get.bottomSheet(
      PaymentSummarySheet(
        title: 'Hire ${member.name}',
        // subtitle: '${hireType.name.toUpperCase()} Rate',
        amount: rate,
        proposalId: '',
        jobId: '',
        teamId: '',
        subtitle: '',
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle nameStyle = Theme.of(context).textTheme.headlineSmall!
        .copyWith(fontWeight: FontWeight.bold, fontSize: 24);
    final TextStyle titleStyle = Theme.of(
      context,
    ).textTheme.bodyMedium!.copyWith(color: Colors.grey);

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
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 600) {
              return _buildResponsiveCard(
                context,
                child: _buildTabContent(nameStyle, titleStyle),
                padding: 16,
                maxWidth: double.infinity,
              );
            } else if (constraints.maxWidth < 1100) {
              return _buildResponsiveCard(
                context,
                child: _buildTabContent(nameStyle, titleStyle),
                padding: 24,
                maxWidth: 900,
              );
            } else {
              return _buildResponsiveCard(
                context,
                child: _buildTabContent(nameStyle, titleStyle),
                padding: 32,
                maxWidth: 1100,
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildResponsiveCard(
    BuildContext context, {
    required Widget child,
    required double padding,
    required double maxWidth,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        margin: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: EdgeInsets.all(padding),
        child: child,
      ),
    );
  }

  Widget _buildTabContent(TextStyle nameStyle, TextStyle titleStyle) {
    return DefaultTabController(
      length: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(onPressed: Get.back, icon: Icon(Icons.arrow_back)),
          TabBar(
            indicatorColor: AppColors.lightBlue,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'Rates & Reviews'),
              Tab(text: 'Projects'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                // ---------------- Overview ----------------
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircularIcon(
                            gradientColors: [
                              AppColors.lightBlue,
                              const Color.fromARGB(79, 155, 39, 176),
                            ],
                            child: Center(
                              child: Text(
                                member.name[0].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(member.name, style: nameStyle),
                                Text(member.title, style: titleStyle),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      member.location,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text('Specialties', style: nameStyle),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: member.specialties
                            .map(
                              (tag) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                child: Text(
                                  tag,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 20),
                      Text('Stats', style: nameStyle),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatColumn(
                            count: member.projects,
                            label: 'Projects',
                          ),
                          _StatColumn(count: member.clients, label: 'Clients'),
                          _StatColumn(count: member.years, label: 'Years'),
                        ],
                      ),
                      SizedBox(height: 20.h),
                      Center(
                        child: WebHoverButton(
                          text: "Hire me",
                          onPressed: () => _showHireMeDialog(Get.context!),
                        ),
                      ),
                    ],
                  ),
                ),

                // ---------------- Rates & Reviews ----------------
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Rates', style: nameStyle),
                      const SizedBox(height: 10),
                      _RateRow(label: 'Hourly', rate: member.hourlyRate),
                      _RateRow(label: 'Daily', rate: member.dailyRate),
                      _RateRow(label: 'Project', rate: member.projectRate),
                      const SizedBox(height: 20),
                      Text('Reviews', style: nameStyle),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            '${member.rating.toStringAsFixed(1)} ',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            '(${member.reviews} reviews)',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ---------------- Projects ----------------
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Projects', style: nameStyle),
                      const SizedBox(height: 10),
                      Text('Total Projects: ${member.projects}'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------- Widgets reused -------------------
class _StatColumn extends StatelessWidget {
  final String count;
  final String label;
  const _StatColumn({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}

class _RateRow extends StatelessWidget {
  final String label;
  final String rate;
  const _RateRow({required this.label, required this.rate});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(rate, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
