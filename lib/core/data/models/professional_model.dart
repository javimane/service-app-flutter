class ProfessionalModel {
  final int id;
  final String? bio;
  final double? ratingAvg;
  final bool isActive;
  final String accountType;
  final String? displayName;
  final String? avatarUrl;
  final String? website;
  final bool isVerified;
  final int completedJobs;
  final int yearsExperience;
  final int profileViews;

  ProfessionalModel({
    required this.id,
    this.bio,
    this.ratingAvg,
    required this.isActive,
    required this.accountType,
    this.displayName,
    this.avatarUrl,
    this.website,
    this.isVerified = false,
    this.completedJobs = 0,
    this.yearsExperience = 0,
    this.profileViews = 0,
  });

  factory ProfessionalModel.fromJson(Map<String, dynamic> json) {
    final profile = json['Profile'] as Map<String, dynamic>?;
    return ProfessionalModel(
      id: json['id'] as int,
      bio: json['bio'] as String?,
      ratingAvg: (json['rating_avg'] as num?)?.toDouble(),
      isActive: json['is_active'] as bool? ?? true,
      accountType: json['account_type'] as String? ?? 'individual',
      displayName: profile?['display_name'] as String?,
      avatarUrl: profile?['avatar_url'] as String?,
      website: profile?['website'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      completedJobs: json['completed_jobs'] as int? ?? 0,
      yearsExperience: json['years_experience'] as int? ?? 0,
      profileViews: json['profile_views'] as int? ?? 0,
    );
  }

  String get name => displayName ?? 'Profesional #$id';
  String get avatar =>
      avatarUrl ??
      'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=FF7F50&color=fff';
}
