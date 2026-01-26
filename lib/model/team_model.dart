import 'package:flutter/material.dart';

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
  final String name; // سنخزن فيه fullName
  final String title;
  final String country;
  final String location;
  final double rating;
  final int reviews;
  final List<String> specialties;
  final String? analystSpecialty; // نأخذ أول عنصر من المصفوفة للعرض
  final String projects;
  final String clients;
  final String years;
  final double hourlyRate;
  final double dailyRate;
  final double projectRate;
  final bool isCompany;
  final bool available;

  TeamModel({
    required this.id,
    required this.initials,
    required this.initialsColor,
    required this.name,
    required this.title,
    required this.country,
    required this.location,
    required this.rating,
    required this.reviews,
    required this.specialties,
    this.analystSpecialty,
    required this.projects,
    required this.clients,
    required this.years,
    required this.hourlyRate,
    required this.dailyRate,
    required this.projectRate,
    required this.isCompany,
    required this.available,
  });

  factory TeamModel.fromMap({
    required String id,
    required Map<String, dynamic> map,
  }) {
    // دالة لتحويل أي نوع بيانات إلى Double بأمان
    double asDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    // 1. معالجة الاسم: جلب fullName (لليوزر) أو name (للتيم)
    String name = map['fullName'] ?? map['name'] ?? 'No Name';

    // 2. معالجة التخصصات (specialties أو mediaWorkTypes)
    List<String> specs = [];
    if (map['mediaWorkTypes'] is List) {
      specs = List<String>.from(map['mediaWorkTypes']);
    } else if (map['specialties'] is List) {
      specs = List<String>.from(map['specialties']);
    }

    // 3. ✅ معالجة analystSpecialty كـ Array أو String
    String? displayAnalyst;
    if (map['analystSpecialty'] is List &&
        (map['analystSpecialty'] as List).isNotEmpty) {
      displayAnalyst = map['analystSpecialty'][0].toString(); // نأخذ أول عنصر
    } else if (map['analystSpecialty'] is String &&
        map['analystSpecialty'].isNotEmpty) {
      displayAnalyst = map['analystSpecialty'];
    }

    // دمج التخصص الفرعي في القائمة العامة للـ Tags إذا لم يكن موجوداً
    if (displayAnalyst != null && !specs.contains(displayAnalyst)) {
      specs.add(displayAnalyst);
    }

    String type = (map['type'] ?? 'individual').toLowerCase();

    return TeamModel(
      id: id,
      name: name,
      initials: name.trim().isNotEmpty
          ? name.trim().split(' ').take(2).map((e) => e[0]).join().toUpperCase()
          : '?',
      initialsColor: type == 'company' ? Colors.orange : Colors.blue,
      title: map['title'] ?? (specs.isNotEmpty ? specs.first : 'Freelancer'),
      country: map['country'] ?? '',
      location: map['location'] ?? map['country'] ?? 'Global',
      rating: asDouble(map['rating'] ?? 5.0),
      reviews: int.tryParse(map['reviews']?.toString() ?? '0') ?? 0,
      specialties: specs,
      analystSpecialty: displayAnalyst, // الحقل الجديد
      projects: map['projects']?.toString() ?? '0',
      clients: map['clients']?.toString() ?? '0',
      years: map['years']?.toString() ?? '0',
      hourlyRate: asDouble(map['hourlyRate']),
      dailyRate: asDouble(map['dailyRate']),
      projectRate: asDouble(map['projectRate']),
      isCompany: type == 'company',
      available: map['available'] ?? false,
    );
  }
}
