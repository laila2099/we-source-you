// // featured_journalists_view.dart

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:we_source_you/core/constant/app_color.dart';
// import 'package:we_source_you/core/services/journalist_controller.dart';
// import 'package:we_source_you/model/journalist_model.dart';

// // Assuming AppColors is available from previous files

// class FeaturedJournalistsView extends GetView<JournalistsController> {
//   const FeaturedJournalistsView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     Get.put(JournalistsController());

//     return Container(
//       color: Colors.white, // Assuming white background
//       padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
//       child: Column(
//         children: [
//           Center(
//             child: Wrap(
//               spacing: 30.0,
//               runSpacing: 30.0,
//               alignment: WrapAlignment.center,
//               children: controller.featuredJournalists.map((j) {
//                 return _JournalistCard(journalist: j);
//               }).toList(),
//             ),
//           ),
//           const SizedBox(height: 30),

//           // View More Button
//           OutlinedButton(
//             onPressed: controller.viewMoreJournalists,
//             style: OutlinedButton.styleFrom(
//               foregroundColor: AppColors.lightBlue,
//               side: const BorderSide(color: AppColors.lightBlue),
//               padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(4),
//               ),
//             ),
//             child: const Text(
//               'View More Journalists',
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // Helper Widget for the Individual Card
// class _JournalistCard extends GetView<JournalistsController> {
//   final JournalistModel journalist;
//   const _JournalistCard({required this.journalist});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 320, // Fixed width for the card
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(10),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Initials, Name, Rating
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _InitialCircle(
//                 initials: journalist.initials,
//                 color: journalist.initialsColor,
//               ),
//               const SizedBox(width: 15),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       journalist.name,
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                       ),
//                     ),
//                     Text(
//                       journalist.title,
//                       style: const TextStyle(color: Colors.grey),
//                     ),
//                     Row(
//                       children: [
//                         const Icon(
//                           Icons.location_on,
//                           size: 14,
//                           color: Colors.grey,
//                         ),
//                         Text(
//                           journalist.location,
//                           style: const TextStyle(
//                             fontSize: 12,
//                             color: Colors.grey,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 5),
//                     Row(
//                       children: [
//                         Text(
//                           '${journalist.rating.toStringAsFixed(1)} ',
//                           style: const TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                         const Icon(Icons.star, color: Colors.amber, size: 16),
//                         Text(
//                           ' (${journalist.reviews} reviews)',
//                           style: const TextStyle(color: Colors.grey),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),

//           // Specialties Tags
//           Wrap(
//             spacing: 8.0,
//             runSpacing: 8.0,
//             children: journalist.specialties
//                 .map((tag) => _SpecialtyTag(tag: tag))
//                 .toList(),
//           ),
//           const SizedBox(height: 20),

//           const Divider(),
//           const SizedBox(height: 10),

//           // Stats Grid (Projects, Clients, Years)
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               _StatColumn(count: journalist.projects, label: 'Projects'),
//               _StatColumn(count: journalist.clients, label: 'Clients'),
//               _StatColumn(count: journalist.years, label: 'Years'),
//             ],
//           ),
//           const SizedBox(height: 10),
//           const Divider(),
//           const SizedBox(height: 10),

//           // Rates
//           _RateRow(label: 'Hourly', rate: journalist.hourlyRate),
//           _RateRow(label: 'Daily', rate: journalist.dailyRate),
//           _RateRow(label: 'Project', rate: journalist.projectRate),
//           const SizedBox(height: 20),

//           // View Profile Button
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton(
//               onPressed: () => controller.viewProfile(journalist),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.lightBlue,
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(vertical: 15),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//               ),
//               child: const Text(
//                 'View Profile',
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // Helper Widgets
// class _InitialCircle extends StatelessWidget {
//   final String initials;
//   final Color color;
//   const _InitialCircle({required this.initials, required this.color});

//   @override
//   Widget build(BuildContext context) {
//     return CircleAvatar(
//       radius: 25,
//       backgroundColor: color,
//       child: Text(
//         initials,
//         style: const TextStyle(
//           color: AppColors.darkBlue,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }
// }

// class _SpecialtyTag extends StatelessWidget {
//   final String tag;
//   const _SpecialtyTag({required this.tag});

//   @override
//   Widget build(BuildContext context) {
//     // Note: The tags in the screenshot have a slight color difference.
//     // We will use a soft background and dark text.
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade100,
//         borderRadius: BorderRadius.circular(4),
//         border: Border.all(color: Colors.grey.shade300),
//       ),
//       child: Text(
//         tag,
//         style: const TextStyle(fontSize: 12, color: Colors.black87),
//       ),
//     );
//   }
// }

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
//       padding: const EdgeInsets.symmetric(vertical: 4.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(label, style: const TextStyle(color: Colors.grey)),
//           Text(
//             rate,
//             style: const TextStyle(
//               fontWeight: FontWeight.bold,
//               color: Colors.black87,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
// featured_journalists_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:we_source_you/core/constant/app_color.dart';
import 'package:we_source_you/model/team_model.dart';
import 'package:we_source_you/core/constant/responsive_layout.dart';
import 'package:we_source_you/view/team/team_controller/team_controller.dart';
import 'package:we_source_you/widgets/circular_icon/circular_icon.dart';
import 'package:we_source_you/widgets/glass_morphism.dart';

class FeaturedteamlistsView extends GetView<TeamController> {
  FeaturedteamlistsView({super.key});

  @override
  Widget build(BuildContext context) {
    // Make sure controller is initialized
    // controller.fetchFeaturedTeam();

    final padding = ResponsiveLayout.screenPadding(context);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            "assets/images/austin-distel-VCFxt2yT1eQ-unsplash.jpg",
          ),
          fit: BoxFit.cover,
          opacity: 0.18, // << اجعل الصورة خفيفة
        ),
      ),
      child: Column(
        children: [
          Text(
            'Our Team'.tr,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              // يفضل استخدام لون الثيم الأساسي للنصوص
              color: textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Meet Our Team and join Them'.tr,
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge,
          ),
          SizedBox(height: 20.h),

          // Journalists Grid
          Center(
            child: Obx(() {
              final items = controller.featuredTeam; // آخر 4 أعضاء

              return Wrap(
                spacing: 30,
                runSpacing: 30,
                alignment: WrapAlignment.center,
                children: [
                  for (final j in items)
                    SizedBox(
                      width: ResponsiveLayout.isDesktop(context)
                          ? 320
                          : ResponsiveLayout.isTablet(context)
                          ? 280
                          : MediaQuery.of(context).size.width * 0.9,
                      child: _TeamCard(journalist: j),
                    ),
                ],
              );
            }),
          ),
          const SizedBox(height: 30),

          // View More Button
          OutlinedButton(
            onPressed: controller.viewMoreTeam,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.lightBlue,
              side: const BorderSide(color: AppColors.lightBlue),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: const Text(
              'View More Journalists',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------- Individual Card -------------------

class _TeamCard extends GetView<TeamController> {
  final TeamModel journalist;
  const _TeamCard({required this.journalist});

  @override
  Widget build(BuildContext context) {
    final TextStyle nameStyle = Theme.of(
      context,
    ).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold, fontSize: 16);
    final TextStyle titleStyle = Theme.of(
      context,
    ).textTheme.bodyMedium!.copyWith(color: Colors.grey);

    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Initials, Name, Rating
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircularIcon(
                gradientColors: [
                  AppColors.lightBlue,
                  const Color.fromARGB(79, 155, 39, 176),
                ],

                child: Center(
                  child: Text(
                    controller.avatarLetter(journalist),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(journalist.name, style: nameStyle),
                    Text(journalist.title, style: titleStyle),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          journalist.location,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Text(
                          '${journalist.rating.toStringAsFixed(1)} ',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        Text(
                          ' (${journalist.reviews} reviews)',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Specialties
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: journalist.specialties
                .map((tag) => _SpecialtyTag(tag: tag))
                .toList(),
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 10),

          // Stats Grid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatColumn(count: journalist.projects, label: 'Projects'),
              _StatColumn(count: journalist.clients, label: 'Clients'),
              _StatColumn(count: journalist.years, label: 'Years'),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(),
          const SizedBox(height: 10),

          // Rates
          _RateRow(label: 'Hourly', rate: journalist.hourlyRate),
          _RateRow(label: 'Daily', rate: journalist.dailyRate),
          _RateRow(label: 'Project', rate: journalist.projectRate),
          const SizedBox(height: 20),

          // View Profile Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              //  => controller.viewProfile(journalist),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: const Text(
                'View Profile',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpecialtyTag extends StatelessWidget {
  final String tag;
  const _SpecialtyTag({required this.tag});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        tag,
        style: const TextStyle(fontSize: 12, color: Colors.black87),
      ),
    );
  }
}

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
    final colorScheme = Theme.of(context).textTheme.bodyMedium!.color;
    final rateColor = Theme.of(context).textTheme.bodyLarge!.color;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: colorScheme)),
          Text(
            rate,
            style: TextStyle(fontWeight: FontWeight.bold, color: rateColor),
          ),
        ],
      ),
    );
  }
}
// ------------------- Helper Widgets -------------------

// class _InitialCircle extends StatelessWidget {
//   final String initials;
//   final Color color;
//   const _InitialCircle({required this.initials, required this.color});

//   @override
//   Widget build(BuildContext context) {
//     return CircleAvatar(
//       radius: 25,
//       backgroundColor: color,
//       child: Text(
//         initials,
//         style: const TextStyle(
//           color: AppColors.darkBlue,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }
// }
