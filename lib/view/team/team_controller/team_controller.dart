import 'dart:async';
<<<<<<< HEAD

=======
import 'package:flutter/material.dart';
import 'package:get/get.dart';
>>>>>>> 8c03dba (.)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:we_source_you/model/team_model.dart';
import 'package:we_source_you/routes/app_routes.dart';

class TeamController extends GetxController {
  final RxList<TeamModel> featuredTeam = <TeamModel>[].obs;
  final RxList<TeamModel> allTeam = <TeamModel>[].obs;

  // ✅ Visible list after filters/search
  final RxList<TeamModel> visibleTeam = <TeamModel>[].obs;

  // ✅ Loading state
  final RxBool isLoading = false.obs;

  StreamSubscription<QuerySnapshot>? _featuredSubscription;
  StreamSubscription<QuerySnapshot>? _allSubscription;

  // ✅ Stored filters
  String _searchQuery = '';
  String _selectedType = 'Any'; // company, journalist, photographer, etc.
  List<String> _selectedSpecialties = [];
  List<String> _selectedLocations = [];
  double? _minRating;
  double? _maxRating;
  String _locationQuery = '';
  String? _selectedCountry;

  @override
  void onInit() {
    super.onInit();
    fetchFeaturedTeam();
    fetchAllTeam();
    debugPrint('🔥 TeamController INIT ${hashCode}');
  }

  void fetchFeaturedTeam() {
    _featuredSubscription?.cancel();
    _featuredSubscription = FirebaseFirestore.instance
        .collection('team')
        .orderBy('createdAt', descending: true)
        .limit(4)
        .snapshots()
        .listen(
          (snapshot) {
            featuredTeam.value = snapshot.docs
                .map((doc) => TeamModel.fromMap(id: doc.id, map: doc.data()))
                .toList();
          },
          onError: (e) {
            Get.snackbar('Error', 'Failed to load featured team: $e');
          },
        );
  }

  void fetchAllTeam() {
    _allSubscription?.cancel();
    _allSubscription = FirebaseFirestore.instance
        .collection('team')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            allTeam.value = snapshot.docs.map((doc) {
              print(doc.id);
              return TeamModel.fromMap(id: doc.id, map: doc.data());
            }).toList();
            // Initialize visible list
            _recomputeVisible();
          },
          onError: (e) {
            Get.snackbar('Error', 'Failed to load all team: $e');
          },
        );
  }

  // 🔍 Search text from search bar
  void updateSearchQuery(String query) {
    _searchQuery = query;
    _recomputeVisible();
  }

  // 🔥 Production-ready filters
  void applyAdvancedFilters({
    String? type,
    List<String>? specialties,
    String? country,
    double? minRating,
    double? maxRating,
  }) {
    _selectedType = type ?? _selectedType;
    _selectedSpecialties = specialties ?? _selectedSpecialties;
    _selectedCountry = country;
    _minRating = minRating;
    _maxRating = maxRating;
    _recomputeVisible();
  }

  // 🔄 Clear filters (keep data)
  void clearFilters() {
    _searchQuery = '';
    _selectedType = 'Any';
    _selectedSpecialties = [];
    _selectedLocations = [];
    _minRating = null;
    _maxRating = null;
    _locationQuery = '';
    _selectedCountry = null;

    _recomputeVisible();
  }

  void _recomputeVisible() {
    final searchLower = _searchQuery.toLowerCase();
    final locationLower = _locationQuery.toLowerCase();

    final results = allTeam.where((member) {
      // Search query filter
      if (searchLower.isNotEmpty) {
        final nameMatch = member.name.toLowerCase().contains(searchLower);
        final titleMatch = member.title.toLowerCase().contains(searchLower);
        final specialtiesMatch = member.specialties.any(
          (s) => s.toLowerCase().contains(searchLower),
        );
        if (!nameMatch && !titleMatch && !specialtiesMatch) {
          return false;
        }
      }

      // Type filter
      if (_selectedType != 'Any') {
        final memberType = member.isCompany ? 'company' : 'journalist';
        if (memberType != _selectedType.toLowerCase()) {
          return false;
        }
      }

      // Specialties filter
      if (_selectedSpecialties.isNotEmpty) {
        final hasMatchingSpecialty = member.specialties.any(
          (s) => _selectedSpecialties.contains(s),
        );
        if (!hasMatchingSpecialty) {
          return false;
        }
      }
      // Country filter
      if (_selectedCountry != null && _selectedCountry!.isNotEmpty) {
        if (member.country != _selectedCountry) {
          return false;
        }
      }

      // Locations filter
      if (_selectedLocations.isNotEmpty) {
        if (!_selectedLocations.contains(member.location)) {
          return false;
        }
      }

      // Location query filter
      if (locationLower.isNotEmpty &&
          !member.location.toLowerCase().contains(locationLower)) {
        return false;
      }

      // Rating filter
      if (_minRating != null && member.rating < _minRating!) {
        return false;
      }
      if (_maxRating != null && member.rating > _maxRating!) {
        return false;
      }

      return true;
    }).toList();

    visibleTeam.assignAll(results);
  }

  @override
  void onClose() {
    _featuredSubscription?.cancel();
    _allSubscription?.cancel();
    super.onClose();
  }

  void goBack() => Get.back();

  void viewMoreTeam() {
    Get.toNamed(AppRoutes.team);
  }

  String avatarLetter(TeamModel member) =>
      member.name.isNotEmpty ? member.name[0].toUpperCase() : '?';

  void viewProfile(TeamModel member) {
    Get.toNamed('/profile/${member.name.replaceAll(' ', '_')}');
  }
}
