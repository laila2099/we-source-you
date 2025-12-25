import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:we_source_you/model/team_model.dart';
import 'package:we_source_you/view/team/team_controller/team_controller.dart';

class TeamResultsList extends StatelessWidget {
  const TeamResultsList({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TeamController>();
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      final team = controller.visibleTeam;
      if (team.isEmpty) {
        return const Center(child: Text('No team members found'));
      }

      return ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: team.length,
        itemBuilder: (context, index) {
          final member = team[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: _TeamCardForList(member: member),
          );
        },
      );
    });
  }
}

class _TeamCardForList extends GetView<TeamController> {
  final TeamModel member;
  const _TeamCardForList({required this.member});

  @override
  Widget build(BuildContext context) {
    final TextStyle nameStyle = Theme.of(context)
        .textTheme
        .bodyLarge!
        .copyWith(fontWeight: FontWeight.bold, fontSize: 16);
    final TextStyle titleStyle =
        Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.grey);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: member.initialsColor,
                child: Text(
                  controller.avatarLetter(member),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 15),
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
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          member.location,
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
                          '${member.rating.toStringAsFixed(1)} ',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        Text(
                          ' (${member.reviews} reviews)',
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
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: member.specialties
                .map((tag) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatColumn(count: member.projects, label: 'Projects'),
              _StatColumn(count: member.clients, label: 'Clients'),
              _StatColumn(count: member.years, label: 'Years'),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(),
          const SizedBox(height: 10),
          _RateRow(label: 'Hourly', rate: member.hourlyRate),
          _RateRow(label: 'Daily', rate: member.dailyRate),
          _RateRow(label: 'Project', rate: member.projectRate),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => controller.viewProfile(member),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5CB85C),
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
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            rate,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class TeamFilterSidebar extends StatefulWidget {
  const TeamFilterSidebar({super.key});

  @override
  State<TeamFilterSidebar> createState() => _TeamFilterSidebarState();
}

class _TeamFilterSidebarState extends State<TeamFilterSidebar> {
  // --- STATE VARIABLES ---
  String _selectedTab = 'Team';
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _minRatingController = TextEditingController();
  final TextEditingController _maxRatingController = TextEditingController();

  // Selections
  final Map<String, bool> _selectedSpecialties = {};
  final Map<String, bool> _selectedLocations = {};
  String _selectedType = 'Any';

  // Controller
  late final TeamController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<TeamController>();
  }

  // --- MOCK DATA (Replace with Firestore StreamBuilder if fetching options dynamically) ---
  final List<String> _specialties = [
    'Social Media Management',
    'Video Editing',
    'Audio Production',
    'Conflict Reporting',
    'Live Broadcasting',
    'Interviewing',
    'Research',
    'Photography',
    'Graphic Design',
    'Legal Consulting',
  ];

  final List<String> _locations = [
    'Belgium',
    'China',
    'USA',
    'Germany',
    'Egypt',
    'Remote',
  ];

  final List<String> _types = [
    'Any',
    'Company',
    'Journalist',
    'Photographer',
    'Lawyer',
    'Designer',
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          color: Colors.white,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Team',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              // Tabs
              Row(
                children: [
                  _buildTab('Team'),
                  const SizedBox(width: 8),
                  _buildTab('Online Users'),
                ],
              ),
              const SizedBox(height: 20),

              // Type Filter
              _buildSectionTitle('Type'),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.grey.shade100,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedType,
                    isExpanded: true,
                    items: _types.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedType = val!),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Specialties Filter
              _buildSectionTitle('Specialties'),
              _buildScrollableCheckboxList(_specialties, _selectedSpecialties),
              const SizedBox(height: 20),

              // Locations Filter
              _buildSectionTitle('Locations'),
              _buildScrollableCheckboxList(_locations, _selectedLocations),
              const SizedBox(height: 20),

              // Specific Location
              _buildSectionTitle('Specific Location'),
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(hintText: 'Add location...'),
              ),
              const SizedBox(height: 20),

              // Rating Range
              _buildSectionTitle('Rating Range'),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _minRatingController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: 'Min'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _maxRatingController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: 'Max'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _performSearch,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5CB85C),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: const Text(
                        'Search',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _clearFilters,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE6E6E6),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: const Text(
                        'Clear',
                        style: TextStyle(color: Colors.black87, fontSize: 16),
                      ),
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

  // --- UI HELPERS ---

  Widget _buildTab(String title) {
    bool isSelected = _selectedTab == title;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = title),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF337AB7)
                : Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildScrollableCheckboxList(
    List<String> options,
    Map<String, bool> selectionState,
  ) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Scrollbar(
        thumbVisibility: true,
        child: ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: options.length,
          itemBuilder: (context, index) {
            final option = options[index];
            return CheckboxListTile(
              dense: true,
              visualDensity: VisualDensity.compact,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 0,
              ),
              title: Text(option, style: const TextStyle(fontSize: 14)),
              value: selectionState[option] ?? false,
              activeColor: const Color(0xFF337AB7),
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (bool? value) {
                setState(() {
                  selectionState[option] = value ?? false;
                });
              },
            );
          },
        ),
      ),
    );
  }

  // --- LOGIC ---

  void _clearFilters() {
    setState(() {
      _locationController.clear();
      _minRatingController.clear();
      _maxRatingController.clear();
      _selectedSpecialties.clear();
      _selectedLocations.clear();
      _selectedType = 'Any';
    });
    controller.clearFilters();
  }

  Future<void> _performSearch() async {
    final selectedSpecialtiesList = _selectedSpecialties.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    final selectedLocationsList = _selectedLocations.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    controller.applyAdvancedFilters(
      type: _selectedType,
      specialties: selectedSpecialtiesList,
      locations: selectedLocationsList,
      minRating: double.tryParse(_minRatingController.text),
      maxRating: double.tryParse(_maxRatingController.text),
      locationQuery: _locationController.text,
    );

    // Close dialog if this sidebar was opened as a dialog (mobile filter)
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }
}

