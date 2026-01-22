import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:we_source_you/model/job_card_model.dart';
import 'package:we_source_you/view/jobs/jobs_controller/jobs_controller.dart';
import 'package:we_source_you/view/jobs/widget/jobs_card.dart';

class JobResultsList extends StatelessWidget {
  const JobResultsList({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<JobsController>();
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      final jobs = controller.visibleCards;
      if (jobs.isEmpty) {
        return const Center(child: Text('No jobs found'));
      }

      return ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: jobs.length,
        itemBuilder: (context, index) {
          final job = jobs[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: JobCard(job: job),
          );
        },
      );
    });
  }
}

class JobFilterSidebar extends StatefulWidget {
  const JobFilterSidebar({super.key});

  @override
  State<JobFilterSidebar> createState() => _JobFilterSidebarState();
}

class _JobFilterSidebarState extends State<JobFilterSidebar> {
  // --- STATE VARIABLES ---
  String _selectedTab = 'Jobs';
  // final TextEditingController _searchController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _minSalaryController = TextEditingController();
  final TextEditingController _maxSalaryController = TextEditingController();

  // Selections
  final Map<String, bool> _selectedCountries = {};
  final Map<String, bool> _selectedMediaTypes = {};
  final Map<String, bool> _selectedLanguages = {};
  final Map<String, bool> _selectedSkills = {};
  String _selectedJobType = 'Any';

  // Controller
  late final JobsController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<JobsController>();

    // Optional: Apply initial filter to populate featuredJobs after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _applyInitialFilters();
    });
  }

  void _applyInitialFilters() {
    // Take first 4 jobs from jobsForSearch
    final filteredJobs = controller.jobsForSearch.take(4).toList();

    // Convert JobSearchModel → JobCardModel directly
    controller.featuredJobs.assignAll(
      filteredJobs
          .map((jobSearch) => JobCardModel.fromSearch(jobSearch))
          .toList(),
    );
  }

  // --- MOCK DATA (Replace with Firestore StreamBuilder if fetching options dynamically) ---
  final List<String> _countries = [
    'Belgium',
    'China',
    'USA',
    'Germany',
    'Remote',
  ];
  final List<String> _mediaTypes = [
    'Analyst',
    'Graphic Designer',
    'Lawyer',
    'Editor',
    'Journalist',
  ];
  final List<String> _languages = [
    'Arabic',
    'Chinese',
    'Dutch',
    'English',
    'French',
  ];
  final List<String> _skills = [
    'Audio Production',
    'Conflict Reporting',
    'Drone Operation',
    'First Aid',
    'Video Editing',
  ];
  final List<String> _jobTypes = [
    'Any',
    'Full-Time',
    'Part-Time',
    'Contract',
    'Freelance',
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
                'Jobs',
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
                  _buildTab('Jobs'),
                  const SizedBox(width: 8),
                  _buildTab('Online Users'),
                ],
              ),
              const SizedBox(height: 20),

              // Search Field
              // _buildSectionTitle('Search for jobs'),
              // TextField(
              //   controller: _searchController,
              //   decoration: const InputDecoration(hintText: 'Search jobs...'),
              // ),
              // const SizedBox(height: 20),

              // Countries Filter
              _buildSectionTitle('Countries'),
              _buildScrollableCheckboxList(_countries, _selectedCountries),
              const SizedBox(height: 20),

              // Specific Location
              _buildSectionTitle('Specific Location'),
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(hintText: 'Add location...'),
              ),
              const SizedBox(height: 20),

              // Media Work Types
              _buildSectionTitle('Media Work Types'),
              _buildScrollableCheckboxList(_mediaTypes, _selectedMediaTypes),
              const SizedBox(height: 20),

              // Languages
              _buildSectionTitle('Languages'),
              _buildScrollableCheckboxList(_languages, _selectedLanguages),
              const SizedBox(height: 20),

              // Job Type Dropdown
              _buildSectionTitle('Job Type'),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.grey.shade100,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedJobType,
                    isExpanded: true,
                    items: _jobTypes.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedJobType = val!),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Salary Range
              _buildSectionTitle('Salary Range (USD)'),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _minSalaryController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: 'Min'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _maxSalaryController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: 'Max'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Skills
              _buildSectionTitle('Skills'),
              _buildScrollableCheckboxList(_skills, _selectedSkills),
              const SizedBox(height: 30),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _performSearch,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFF5CB85C,
                        ), // Bootstrap Success Green
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
                : Colors.white, // Bootstrap Primary Blue
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
      height: 150, // Fixed height with scroll as per UI
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

  // --- LOGIC & FIREBASE ---

  void _clearFilters() {
    setState(() {
      // _searchController.clear();
      _locationController.clear();
      _minSalaryController.clear();
      _maxSalaryController.clear();
      _selectedCountries.clear();
      _selectedMediaTypes.clear();
      _selectedLanguages.clear();
      _selectedSkills.clear();
      _selectedJobType = 'Any';
    });
  }

  Future<void> _performSearch() async {
    final selectedCountryList = _selectedCountries.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    final selectedMediaList = _selectedMediaTypes.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    controller.applyAdvancedFilters(
      jobType: _selectedJobType,
      minSalary: int.tryParse(_minSalaryController.text),
      maxSalary: int.tryParse(_maxSalaryController.text),
      countries: selectedCountryList,
      mediaTypes: selectedMediaList,
      location: _locationController.text,
    );

    // Close dialog if this sidebar was opened as a dialog (mobile filter)
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }
}
