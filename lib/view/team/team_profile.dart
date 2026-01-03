import 'package:flutter/material.dart';
import 'package:we_source_you/model/team_model.dart';
import 'package:we_source_you/core/constant/app_color.dart';
import 'package:we_source_you/widgets/circular_icon/circular_icon.dart';
import 'package:we_source_you/widgets/glass_morphism.dart';

class TeamProfileView extends StatelessWidget {
  final TeamModel member;
  const TeamProfileView({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    final TextStyle nameStyle = Theme.of(context).textTheme.headlineSmall!
        .copyWith(fontWeight: FontWeight.bold, fontSize: 24);
    final TextStyle titleStyle = Theme.of(
      context,
    ).textTheme.bodyMedium!.copyWith(color: Colors.grey);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.lightBlue,
          title: Text(member.name),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Rates & Reviews'),
              Tab(text: 'Projects'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // ---------------- Overview Tab ----------------
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar + Name + Title
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
                              border: Border.all(color: Colors.grey.shade300),
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

                  // Stats
                  Text('Stats', style: nameStyle),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatColumn(count: member.projects, label: 'Projects'),
                      _StatColumn(count: member.clients, label: 'Clients'),
                      _StatColumn(count: member.years, label: 'Years'),
                    ],
                  ),
                ],
              ),
            ),

            // ---------------- Rates & Reviews Tab ----------------
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

            // ---------------- Projects Tab ----------------
            // ---------------- Projects Tab ----------------
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
