class ArcaModel {
  final int id;
  final int companyId;
  final DateTime validFrom;
  final DateTime validTo;
  final bool isVerified;
  final DateTime? verifiedAt;
  final DateTime createdAt;
  final String? token;
  final String? tokenExpiresAt;
  final bool isActive;
  final String companyName;
  final String personType;

  ArcaModel({
    required this.id,
    required this.companyId,
    required this.validFrom,
    required this.validTo,
    required this.isVerified,
    this.verifiedAt,
    required this.createdAt,
    this.token,
    this.tokenExpiresAt,
    required this.isActive,
    required this.companyName,
    required this.personType,
  });

  factory ArcaModel.fromJson(Map<String, dynamic> json) {
    return ArcaModel(
      id: json['id'] as int,
      companyId: json['company_id'] as int,
      validFrom: DateTime.parse(json['valid_from'] as String),
      validTo: DateTime.parse(json['valid_to'] as String),
      isVerified: json['is_verified'] as bool,
      verifiedAt: json['verified_at'] != null
          ? DateTime.parse(json['verified_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      token: json['token'] as String?,
      tokenExpiresAt: json['token_expires_at'] as String?,
      isActive: json['is_active'] as bool,
      companyName: json['company_name'] as String,
      personType: json['person_type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'valid_from': validFrom.toIso8601String().split('T').first,
      'valid_to': validTo.toIso8601String().split('T').first,
      'is_verified': isVerified,
      'verified_at': verifiedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'token': token,
      'token_expires_at': tokenExpiresAt,
      'is_active': isActive,
      'company_name': companyName,
      'person_type': personType,
    };
  }
}
