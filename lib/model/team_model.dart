// // journalist_model.dart

// import 'package:flutter/material.dart';

// class TeamModel {
//   final String initials;
//   final Color initialsColor;
//   final String name;
//   final String title;
//   final String location;
//   final double rating;
//   final int reviews;
//   final List<String> specialties;
//   final String projects;
//   final String clients;
//   final String years;
//   final String hourlyRate;
//   final String dailyRate;
//   final String projectRate;
//   final bool isCompany;

//   TeamModel({
//     required this.initials,
//     required this.initialsColor,
//     required this.name,
//     required this.title,
//     required this.location,
//     required this.rating,
//     required this.reviews,
//     required this.specialties,
//     required this.projects,
//     required this.clients,
//     required this.years,
//     required this.hourlyRate,
//     required this.dailyRate,
//     required this.projectRate,
//     required this.isCompany,
//   });
//   factory TeamModel.fromMap(Map<String, dynamic> map) {
//     return TeamModel(
//       initials: map['name'] != null && map['name'].isNotEmpty
//           ? map['name'][0].toUpperCase()
//           : '',
//       initialsColor: Colors.blue, // أو توليد لون عشوائي إذا تحبي
//       name: map['type'] == 'company' ? map['companyName'] : map['fullName'],
//       title: map['mediaWorkType'] ?? '',
//       location: '${map['city'] ?? ''}, ${map['country'] ?? ''}',
//       rating: (map['rating'] ?? 0).toDouble(),
//       reviews: map['reviews'] ?? 0,
//       specialties: List<String>.from(map['specialties'] ?? []),
//       projects: map['projects']?.toString() ?? '0',
//       clients: map['clients']?.toString() ?? '0',
//       years: map['years']?.toString() ?? '0',
//       hourlyRate: map['hourlyRate'] ?? '0',
//       dailyRate: map['dailyRate'] ?? '0',
//       projectRate: map['projectRate'] ?? '0',
//       isCompany: map['type'] == 'company', // ← هنا نحدد النوع
//     );
//   }
// }
import 'package:flutter/material.dart';

const Map<String, Color> typeColors = {
  'company': Colors.orange,
  'journalist': Colors.blue,
  'photographer': Colors.purple,
  'lawyer': Colors.green,
  'designer': Colors.pink,
};

class TeamModel {
  final String initials;
  final Color initialsColor;
  final String name;
  final String title;
  final String country;
  final String location;
  final double rating;
  final int reviews;
  final List<String> specialties;
  final String projects;
  final String clients;
  final String years;
  final String hourlyRate;
  final String dailyRate;
  final String projectRate;
  final bool isCompany;

  TeamModel({
    required this.initials,
    required this.initialsColor,
    required this.name,
    required this.title,
    required this.country,

    required this.location,
    required this.rating,
    required this.reviews,
    required this.specialties,
    required this.projects,
    required this.clients,
    required this.years,
    required this.hourlyRate,
    required this.dailyRate,
    required this.projectRate,
    required this.isCompany,
  });

  factory TeamModel.fromMap(Map<String, dynamic> map) {
    String type = (map['type'] ?? 'journalist').toLowerCase();
    return TeamModel(
      initials: map['name'] != null && map['name'].isNotEmpty
          ? map['name']
                .toString()
                .split(' ')
                .map((e) => e[0])
                .join()
                .toUpperCase()
          : '?',
      initialsColor: typeColors[type] ?? Colors.grey,
      name: map['name'] ?? 'Unknown',
      title: map['title'] ?? '',
      country: map['country'] ?? '',
      location: map['location'] ?? 'Not specified',
      rating: (map['rating'] ?? 0).toDouble(),
      reviews: map['reviews'] ?? 0,
      specialties: List<String>.from(map['specialties'] ?? []),
      projects: map['projects']?.toString() ?? '0',
      clients: map['clients']?.toString() ?? '0',
      years: map['years']?.toString() ?? '0',
      hourlyRate: map['hourlyRate'] ?? '0.00/hr',
      dailyRate: map['dailyRate'] ?? '0.00/day',
      projectRate: map['projectRate'] ?? '0.00',
      isCompany: type == 'company',
    );
  }
}
