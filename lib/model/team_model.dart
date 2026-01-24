import 'package:flutter/material.dart';
import 'package:get/get_rx/get_rx.dart';

const Map<String, Color> typeColors = {
  'company': Colors.orange,
  'journalist': Colors.blue,
  'photographer': Colors.purple,
  'lawyer': Colors.green,
  'designer': Colors.pink,
};

class TeamModel {
  final String id;
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
  final double hourlyRate;
  final double dailyRate;
  final double projectRate;
  final bool isCompany;
  final bool available;

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
    required this.available,
    required this.id,
  });

  factory TeamModel.fromMap({
    required String id,
    required Map<String, dynamic> map,
  }) {
    String type = (map['type'] ?? 'journalist').toLowerCase();

    return TeamModel(
      id: id,
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
      hourlyRate: (map['hourlyRate'] ?? 0).toDouble(),
      dailyRate: (map['dailyRate'] ?? 0).toDouble(),
      projectRate: (map['projectRate'] ?? 0).toDouble(),
      isCompany: type == 'company',
      available: map['available'] ?? false,
    );
  }
}
