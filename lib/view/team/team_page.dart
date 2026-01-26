import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:we_source_you/view/team/team_controller/team_controller.dart';
import 'package:we_source_you/view/team/widget/team_card.dart';
import 'package:we_source_you/widgets/glass_morphism.dart';

class TeamResultsList extends StatelessWidget {
  const TeamResultsList({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TeamController>();

    // حساب عدد الأعمدة بناءً على عرض الشاشة
    int getCrossAxisCount(BuildContext context) {
      double width = MediaQuery.of(context).size.width;
      if (width >= 1100) return 3; // Desktop
      if (width >= 600) return 2; // Tablet
      return 1; // Mobile
    }

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      final team = controller.visibleTeam;
      if (team.isEmpty) {
        return const Center(child: Text('No team members found'));
      }

      return GridView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: team.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: getCrossAxisCount(context), // عدد الأعمدة الديناميكي
          crossAxisSpacing: 20, // المسافة الأفقية بين الكروت
          mainAxisSpacing: 20, // المسافة الرأسية بين الكروت
          // هذا الحقل مهم جداً لضبط ارتفاع الكارت، جربي تغيير القيمة حتى تناسب محتوى الـ TeamCard
          childAspectRatio: 0.9,
        ),
        itemBuilder: (context, index) {
          final member = team[index];
          return TeamCard(journalist: member);
        },
      );
    });
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
  String _selectedType = 'Any';
  String? _selectedAnalystSpecialty;
  // Controller
  late final TeamController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<TeamController>();
  }

  // --- MOCK DATA (Replace with Firestore StreamBuilder if fetching options dynamically) ---
  final List<String> _specialties = [
    'Producer',
    'Reporter',
    'TV Cameraman',
    'Photographer',
    'Editor',
    'Trainer',
    'Graphic Designer',
    'Media Lawyer',
    'Voice Over',
    'Translator',
    'Analyst',
    'Web Designer',
    'Social Media Management',
    'Video Editing',
    'Audio Production',
    'Conflict Reporting',
    'Live Broadcasting',
    'Interviewing',
  ];

  String? _selectedCountry;

  final List<String> _types = ['Any', 'Company'];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: GlassContainer(
          width: MediaQuery.of(context).size.width * 0.85,
          // color: Colors.white,
          // padding: const EdgeInsets.all(16.0),
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
              // Row(
              //   children: [
              //     _buildTab('Team'),
              //     const SizedBox(width: 8),
              //     _buildTab('Online Users'),
              //   ],
              // ),
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
              _buildSectionTitle('Country'),
              InkWell(
                onTap: () {
                  showCountryPicker(
                    context: context,
                    showPhoneCode: false,
                    onSelect: (country) {
                      setState(() {
                        _selectedCountry = country.name;
                      });
                    },
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _selectedCountry ?? 'Select country',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),

              const SizedBox(height: 20),

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
            color: isSelected ? const Color(0xFF337AB7) : Colors.white,
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
      _selectedType = 'Any';
    });
    controller.clearFilters();
  }

  Future<void> _performSearch() async {
    final selectedSpecialtiesList = _selectedSpecialties.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    controller.applyAdvancedFilters(
      type: _selectedType,
      specialties: selectedSpecialtiesList,
      country: _selectedCountry,
      minRating: double.tryParse(_minRatingController.text),
      maxRating: double.tryParse(_maxRatingController.text),
    );

    // Close dialog if this sidebar was opened as a dialog (mobile filter)
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }
}
