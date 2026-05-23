class ReviewModel {
  final int id;
  final String? comment;
  final double rating;
  final String? reviewerName;
  final String? reviewerAvatar;
  final DateTime? createdAt;

  ReviewModel({
    required this.id,
    this.comment,
    required this.rating,
    this.reviewerName,
    this.reviewerAvatar,
    this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final profile = json['Profile'] as Map<String, dynamic>?;
    return ReviewModel(
      id: json['id'] as int,
      comment: json['comment'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      reviewerName: profile?['display_name'] as String?,
      reviewerAvatar: profile?['avatar_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }
}

class SubscriptionPlanModel {
  final String name;
  final double price;
  final String period;
  final List<String> features;
  final bool isPopular;

  SubscriptionPlanModel({
    required this.name,
    required this.price,
    required this.period,
    required this.features,
    this.isPopular = false,
  });

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanModel(
      name: json['name'] as String? ?? 'Plan',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      period: json['period'] as String? ?? 'mes',
      features: (json['features'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      isPopular: json['is_popular'] as bool? ?? false,
    );
  }
}

class FavoriteModel {
  final int id;
  final int professionalId;
  final String? professionalName;
  final String? professionalAvatar;
  final String? professionalBio;
  final double? rating;

  FavoriteModel({
    required this.id,
    required this.professionalId,
    this.professionalName,
    this.professionalAvatar,
    this.professionalBio,
    this.rating,
  });

  factory FavoriteModel.fromJson(Map<String, dynamic> json) {
    final professional = json['Professional'] as Map<String, dynamic>?;
    final profile = professional?['Profile'] as Map<String, dynamic>?;

    return FavoriteModel(
      id: json['id'] as int,
      professionalId: json['professional_id'] as int,
      professionalName: profile?['display_name'] as String?,
      professionalAvatar: profile?['avatar_url'] as String?,
      professionalBio: professional?['bio'] as String?,
      rating: (professional?['rating_avg'] as num?)?.toDouble(),
    );
  }
}
