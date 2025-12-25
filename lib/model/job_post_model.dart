class JobPostModel {
  String? id;
  // Step 1: Basics
  String title;
  String description;
  String experienceLevel;
  String jobType;
  int numPositions;

  // Step 2: Details
  double? minSalary;
  double? maxSalary;
  String currency;
  String period;
  String projectDetails;
  DateTime? startDate;
  DateTime? endDate;
  DateTime? deadline;

  // Step 3: Requirements
  bool hasCamera;
  bool hasAudio;
  bool canTravel;
  bool portfolioRequired;
  String contactName;
  String contactEmail;
  String contactPhone;
  String contactMethod;

  // Step 4: Skills & Languages (Stored as lists)
  List<String> skills;
  List<String> languages;
  List<String> mediaTypes;
  List<String> locations;

  // Step 5: Additional Info
  List<String> benefits;
  List<String> tags;
  List<String> categories;
  String additionalInfo;
  bool isUrgent;
  bool isFeatured;

  JobPostModel({
    this.id,
    this.title = '',
    this.description = '',
    this.experienceLevel = 'Entry Level',
    this.jobType = 'Freelance',
    this.numPositions = 1,
    this.minSalary,
    this.maxSalary,
    this.currency = 'USD',
    this.period = 'Monthly',
    this.projectDetails = '',
    this.startDate,
    this.endDate,
    this.deadline,
    this.hasCamera = false,
    this.hasAudio = false,
    this.canTravel = false,
    this.portfolioRequired = false,
    this.contactName = '',
    this.contactEmail = '',
    this.contactPhone = '',
    this.contactMethod = 'Email',
    this.skills = const [],
    this.languages = const [],
    this.mediaTypes = const [],
    this.locations = const [],
    this.benefits = const [],
    this.tags = const [],
    this.categories = const [],
    this.additionalInfo = '',
    this.isUrgent = false,
    this.isFeatured = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'experienceLevel': experienceLevel,
      'jobType': jobType,
      'numPositions': numPositions,
      'minSalary': minSalary,
      'maxSalary': maxSalary,
      'currency': currency,
      'period': period,
      'projectDetails': projectDetails,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'deadline': deadline?.toIso8601String(),
      'hasCamera': hasCamera,
      'hasAudio': hasAudio,
      'canTravel': canTravel,
      'portfolioRequired': portfolioRequired,
      'contactName': contactName,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      'contactMethod': contactMethod,
      'skills': skills,
      'languages': languages,
      'mediaTypes': mediaTypes,
      'locations': locations,
      'benefits': benefits,
      'tags': tags,
      'categories': categories,
      'additionalInfo': additionalInfo,
      'isUrgent': isUrgent,
      'isFeatured': isFeatured,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  factory JobPostModel.fromMap(Map<String, dynamic> data) {
    return JobPostModel(
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      experienceLevel: data['experienceLevel'] ?? 'Entry Level',
      jobType: data['jobType'] ?? 'Freelance',
      numPositions: data['numPositions'] ?? 1,
      minSalary: data['minSalary']?.toDouble(),
      maxSalary: data['maxSalary']?.toDouble(),
      currency: data['currency'] ?? 'USD',
      period: data['period'] ?? 'Monthly',
      projectDetails: data['projectDetails'] ?? '',
      startDate: data['startDate'] != null
          ? DateTime.tryParse(data['startDate'])
          : null,
      endDate: data['endDate'] != null
          ? DateTime.tryParse(data['endDate'])
          : null,
      deadline: data['deadline'] != null
          ? DateTime.tryParse(data['deadline'])
          : null,
      hasCamera: data['hasCamera'] ?? false,
      hasAudio: data['hasAudio'] ?? false,
      canTravel: data['canTravel'] ?? false,
      portfolioRequired: data['portfolioRequired'] ?? false,
      contactName: data['contactName'] ?? '',
      contactEmail: data['contactEmail'] ?? '',
      contactPhone: data['contactPhone'] ?? '',
      contactMethod: data['contactMethod'] ?? 'Email',
      skills: List<String>.from(data['skills'] ?? []),
      languages: List<String>.from(data['languages'] ?? []),
      mediaTypes: List<String>.from(data['mediaTypes'] ?? []),
      locations: List<String>.from(data['locations'] ?? []),
      benefits: List<String>.from(data['benefits'] ?? []),
      tags: List<String>.from(data['tags'] ?? []),
      categories: List<String>.from(data['categories'] ?? []),
      additionalInfo: data['additionalInfo'] ?? '',
      isUrgent: data['isUrgent'] ?? false,
      isFeatured: data['isFeatured'] ?? false,
    );
  }
}
