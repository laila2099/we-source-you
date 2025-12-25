// // // journalists_controller.dart

// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';
// // import 'package:we_source_you/model/journalist_model.dart';

// // class JournalistsController extends GetxController {
// //   // Static list of featured journalists based on the screenshot
// //   final List<JournalistModel> featuredJournalists = [
// //     JournalistModel(
// //       initials: 'ED',
// //       initialsColor: const Color(0xFFC7E2F2), // Light Blue/Gray
// //       name: 'Emily Davis',
// //       title: 'TV Camerawoman',
// //       location: 'Location not specified',
// //       rating: 0.0,
// //       reviews: 22,
// //       specialties: [
// //         'Social Media Management',
// //         'Video Editing',
// //         'Audio Production',
// //       ],
// //       projects: '0',
// //       clients: '0',
// //       years: '0',
// //       hourlyRate: '55.00/hr',
// //       dailyRate: '440.00/day',
// //       projectRate: '3500.00',
// //     ),
// //     JournalistModel(
// //       initials: 'DM',
// //       initialsColor: const Color(0xFFE0C3E8), // Light Purple/Pink
// //       name: 'David Miller',
// //       title: 'Reporter',
// //       location: 'Location not specified',
// //       rating: 0.0,
// //       reviews: 30,
// //       specialties: ['Conflict Reporting', 'Research', 'Interviewing'],
// //       projects: '0',
// //       clients: '0',
// //       years: '0',
// //       hourlyRate: '75.00/hr',
// //       dailyRate: '600.00/day',
// //       projectRate: '4500.00',
// //     ),
// //     JournalistModel(
// //       initials: 'JD',
// //       initialsColor: const Color(0xFFC1F0C9), // Light Green
// //       name: 'John Doe',
// //       title: 'Reporter',
// //       location: 'Egypt',
// //       rating: 0.0,
// //       reviews: 0,
// //       specialties: [
// //         'Conflict Reporting',
// //         'Live Broadcasting',
// //         'Video Production',
// //       ],
// //       projects: '0',
// //       clients: '0',
// //       years: '0',
// //       hourlyRate: '75.00/hr',
// //       dailyRate: '600.00/day',
// //       projectRate: '2500.00',
// //     ),
// //   ].obs;

// //   void viewProfile(JournalistModel journalist) {
// //     // Navigation logic to the detailed profile page
// //     Get.toNamed('/profile/${journalist.name.replaceAll(' ', '_')}');
// //     Get.snackbar("Action", "Viewing profile for ${journalist.name}");
// //   }

// void viewMoreJournalists() {
//   // Navigation logic to the full list page
//   Get.toNamed('/journalists');
// }
// // }
// // journalists_controller.dart

// // import 'dart:async';

// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:get/get.dart';
// // import 'package:we_source_you/model/team_model.dart';

// // class TeamController extends GetxController {
// //   final RxList<TeamModel> journalists = <TeamModel>[].obs;
// //   StreamSubscription<QuerySnapshot>? _subscription;

// //   @override
// //   void onInit() {
// //     super.onInit();
// //     fetchFeaturedTeam(); // ✅ المكان الصحيح
// //   }

// //   void fetchFeaturedTeam() {
// //     _subscription?.cancel();

// //     _subscription = FirebaseFirestore.instance
// //         .collection('journalists')
// //         .orderBy('createdAt', descending: true)
// //         .limit(4)
// //         .snapshots()
// //         .listen((snapshot) {
// //           journalists.value = snapshot.docs
// //               .map((doc) => TeamModel.fromMap(doc.data()))
// //               .toList();
// //         });
// //   }

// //   @override
// //   void onClose() {
// //     _subscription?.cancel();
// //     super.onClose();
// //   }

// //   String avatarLetter(TeamModel journalist) {
// //     if (journalist.name.isNotEmpty) {
// //       return journalist.name[0].toUpperCase();
// //     }
// //     return '?';
// //   }

// //   void viewMoreJournalists() {
// //     Get.toNamed('/journalists');
// //   }
// // }

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:we_source_you/model/team_model.dart';

// class TeamController extends GetxController {
//   final RxList<TeamModel> journalists = <TeamModel>[].obs;
//   StreamSubscription<QuerySnapshot>? _journalistsSubscription;

//   @override
//   void onInit() {
//     super.onInit();
//     fetchJournalists(); // جلب البيانات عند البداية
//   }

//   void goBack() => Get.back();

//   void fetchJournalists() async {
//     try {
//       _journalistsSubscription
//           ?.cancel(); // Cancel previous subscription if exists

//       _journalistsSubscription = FirebaseFirestore.instance
//           .collection('journalists') // اسم الكولكشن في Firestore
//           .snapshots()
//           .listen(
//             (querySnapshot) {
//               final List<TeamModel> loadedJournalists = querySnapshot.docs.map((
//                 doc,
//               ) {
//                 final data = doc.data();
//                 return TeamModel(
//                   initials: (data['name'] as String)
//                       .split(' ')
//                       .map((e) => e[0])
//                       .join(),
//                   initialsColor: Color(
//                     int.parse(data['initialsColor'] ?? '0xFFCCCCCC'),
//                   ),
//                   name: data['name'] ?? 'Unknown',
//                   title: data['title'] ?? 'Unknown',
//                   location: data['location'] ?? 'Not specified',
//                   rating: (data['rating'] ?? 0).toDouble(),
//                   reviews: data['reviews'] ?? 0,
//                   specialties: List<String>.from(data['specialties'] ?? []),
//                   projects: data['projects'] ?? '0',
//                   clients: data['clients'] ?? '0',
//                   years: data['years'] ?? '0',
//                   hourlyRate: data['hourlyRate'] ?? '0.00/hr',
//                   dailyRate: data['dailyRate'] ?? '0.00/day',
//                   projectRate: data['projectRate'] ?? '0.00',
//                   isCompany: null,
//                 );
//               }).toList();

//               journalists.value = loadedJournalists;
//             },
//             onError: (error) {
//               print('❌ Error listening to journalists: $error');
//               Get.snackbar("Error", "Failed to load journalists: $error");
//             },
//           );
//     } catch (e) {
//       print('❌ Error setting up journalists stream: $e');
//       Get.snackbar("Error", "Failed to load journalists: $e");
//     }
//   }

//   @override
//   void onClose() {
//     _journalistsSubscription
//         ?.cancel(); // Cancel subscription when controller is disposed
//     super.onClose();
//   }

//   void viewProfile(TeamModel journalist) {
//     Get.toNamed('/profile/${journalist.name.replaceAll(' ', '_')}');
//     Get.snackbar("Action", "Viewing profile for ${journalist.name}");
//   }

//   String avatarLetter(TeamModel journalist) {
//     if (journalist.name.isNotEmpty) {
//       return journalist.name[0].toUpperCase();
//     }
//     return '?';
//   }

//   void viewMoreJournalists() {
//     Get.toNamed('/journalists');
//   }
// }
import 'dart:async';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  @override
  void onInit() {
    super.onInit();
    fetchFeaturedTeam();
    fetchAllTeam();
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
                .map((doc) => TeamModel.fromMap(doc.data()))
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
            allTeam.value = snapshot.docs
                .map((doc) => TeamModel.fromMap(doc.data()))
                .toList();
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
    List<String>? locations,
    double? minRating,
    double? maxRating,
    String? locationQuery,
  }) {
    _selectedType = type ?? _selectedType;
    _selectedSpecialties = specialties ?? _selectedSpecialties;
    _selectedLocations = locations ?? _selectedLocations;
    _minRating = minRating;
    _maxRating = maxRating;
    _locationQuery = locationQuery ?? _locationQuery;
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

      // Locations filter
      if (_selectedLocations.isNotEmpty) {
        final locationMatch = _selectedLocations.any(
          (loc) => member.location.toLowerCase().contains(loc.toLowerCase()),
        );
        if (!locationMatch) {
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
