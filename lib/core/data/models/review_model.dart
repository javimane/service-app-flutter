import 'professional_model.dart';
import 'profile_model.dart';

class ReviewModel {
  final int id;
  final String? userId;
  final int professionalId;
  final double rating;
  final String? comment;
  final String createdAt;
  final String? imageUrl;
  final ProfileModel? profile;
  final ProfessionalModel? professional;

  ReviewModel({
    required this.id,
    this.userId,
    required this.professionalId,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.imageUrl,
    this.profile,
    this.professional,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) => ReviewModel(
        id: json['id'] as int,
        userId: json['user_id'] as String?,
        professionalId: json['professional_id'] as int,
        rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
        comment: json['comment'] as String?,
        createdAt: json['created_at'] as String? ?? '',
        imageUrl: json['image_url'] as String?,
        profile: json['Profile'] != null
            ? ProfileModel.fromJson(json['Profile'] as Map<String, dynamic>)
            : null,
        professional: json['Professional'] != null
            ? ProfessionalModel.fromJson(
                json['Professional'] as Map<String, dynamic>)
            : null,
      );
}
