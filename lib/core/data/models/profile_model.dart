class ProfileModel {
  final String id;
  final String? email;
  final String? displayName;
  final String? avatarUrl;
  final String? updatedAt;

  ProfileModel({
    required this.id,
    this.email,
    this.displayName,
    this.avatarUrl,
    this.updatedAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
        id: json['id'] as String,
        email: json['email'] as String?,
        displayName: json['display_name'] as String?,
        avatarUrl: json['avatar_url'] as String?,
        updatedAt: json['updated_at'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'display_name': displayName,
        'avatar_url': avatarUrl,
        'updated_at': updatedAt,
      };
}
