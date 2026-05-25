import 'professional_model.dart';
import 'profile_model.dart';

class ProfessionalProposalModel {
  final String id;
  final String fileUrl;
  final bool accepted;
  final String professionalName;
  final int professionalId;
  final String userId;
  final String createdAt;
  final ProfessionalModel? professional;
  final ProfileModel? profile;

  ProfessionalProposalModel({
    required this.id,
    required this.fileUrl,
    required this.accepted,
    required this.professionalName,
    required this.professionalId,
    required this.userId,
    required this.createdAt,
    this.professional,
    this.profile,
  });

  factory ProfessionalProposalModel.fromJson(Map<String, dynamic> json) =>
      ProfessionalProposalModel(
        id: json['id'] as String? ?? '',
        fileUrl: json['file_url'] as String? ?? '',
        accepted: json['accepted'] as bool? ?? false,
        professionalName: json['professional_name'] as String? ?? '',
        professionalId: json['professional_id'] as int,
        userId: json['user_id'] as String? ?? '',
        createdAt: json['created_at'] as String? ?? '',
        professional: json['Professional'] != null
            ? ProfessionalModel.fromJson(
                json['Professional'] as Map<String, dynamic>)
            : null,
        profile: json['Profile'] != null
            ? ProfileModel.fromJson(json['Profile'] as Map<String, dynamic>)
            : null,
      );
}
