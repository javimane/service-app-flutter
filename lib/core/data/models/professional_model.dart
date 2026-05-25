import 'profile_model.dart';

class ProfessionalModel {
  final int id;
  final String userId;
  final String? bio;
  final double? ratingAvg;
  final bool isActive;
  final String accountType;
  final String? displayName;
  final String? avatarUrl;
  final String? website;
  final String? webUrl;
  final bool isVerified;
  final int completedJobs;
  final int yearsExperience;
  final int profileViews;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;
  final bool? isMatriculate;
  final bool? emergency;
  final ProfileModel? profile;

  final String? companyName;
  final String? specialty;
  final double? latitude;
  final double? longitude;

  ProfessionalModel({
    required this.id,
    required this.userId,
    this.bio,
    this.ratingAvg,
    required this.isActive,
    required this.accountType,
    this.displayName,
    this.avatarUrl,
    this.website,
    this.webUrl,
    this.isVerified = false,
    this.completedJobs = 0,
    this.yearsExperience = 0,
    this.profileViews = 0,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.isMatriculate,
    this.emergency,
    this.profile,
    this.companyName,
    this.specialty,
    this.latitude,
    this.longitude,
  });

  factory ProfessionalModel.fromJson(Map<String, dynamic> json) {
    final profile = json['Profile'] ?? json['profile'];
    final company = json['Company'] ?? json['company'];
    
    // Extraer direcciones como en la web
    final List<dynamic> addressesList = [
      ...(json['address'] ?? []),
      ...(json['Address'] ?? []),
      ...(json['addresses'] ?? []),
      ...(json['Addresses'] ?? []),
      if (company?['Address'] != null) company['Address'],
    ];
    
    final Map<String, dynamic>? primaryAddress = addressesList.firstWhere(
      (a) => a?['is_main_address'] == true,
      orElse: () => addressesList.isNotEmpty ? addressesList.first : null,
    );

    final latStr = primaryAddress?['latitude'];
    final lngStr = primaryAddress?['longitude'];
    final double? lat = latStr != null ? double.tryParse(latStr.toString()) : null;
    final double? lng = lngStr != null ? double.tryParse(lngStr.toString()) : null;

    final bool isVerified = json['company_arca']?['is_verified'] == true ||
        json['companyArca']?['is_verified'] == true ||
        company?['company_arca']?['is_verified'] == true ||
        company?['companyArca']?['is_verified'] == true ||
        json['is_verified'] == true;

    return ProfessionalModel(
      id: json['id'] as int,
      userId: json['user_id'] as String? ?? '',
      bio: json['bio'] as String?,
      ratingAvg: (json['ratingAvg'] ?? json['rating_avg'] as num?)?.toDouble(),
      isActive: json['is_active'] as bool? ?? true,
      accountType: json['account_type'] as String? ?? 'individual',
      displayName: profile?['display_name'] as String?,
      avatarUrl: profile?['avatar_url'] as String?,
      website: profile?['website'] as String?,
      webUrl: json['web_url'] as String?,
      isVerified: isVerified,
      completedJobs: json['completed_jobs'] as int? ?? 0,
      yearsExperience: json['years_experience'] as int? ?? 0,
      profileViews: json['profile_views'] as int? ?? 0,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      deletedAt: json['deleted_at'] as String?,
      isMatriculate: json['is_matriculate'] as bool?,
      emergency: json['emergency'] as bool?,
      profile: profile != null ? ProfileModel.fromJson(profile as Map<String, dynamic>) : null,
      companyName: json['company_name'] as String? ?? company?['name'] as String?,
      specialty: json['specialty'] as String? ?? json['bio'] as String?,
      latitude: lat,
      longitude: lng,
    );
  }

  String get name => companyName ?? displayName ?? 'Profesional #$id';
  String get avatar =>
      avatarUrl ??
      'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=FF7F50&color=fff';
}
