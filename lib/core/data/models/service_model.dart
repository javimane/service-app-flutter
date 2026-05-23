class ServiceModel {
  final int id;
  final String name;
  final String? description;
  final double? price;
  final int? durationMinutes;
  final bool isActive;
  final int? categoryId;
  final String? categoryName;
  final int? professionalId;
  final String? professionalName;
  final String? professionalAvatar;
  final double? rating;

  ServiceModel({
    required this.id,
    required this.name,
    this.description,
    this.price,
    this.durationMinutes,
    required this.isActive,
    this.categoryId,
    this.categoryName,
    this.professionalId,
    this.professionalName,
    this.professionalAvatar,
    this.rating,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    final professional = json['Professional'] as Map<String, dynamic>?;
    final profile = professional?['Profile'] as Map<String, dynamic>?;
    final category = json['CategoriesService'] as Map<String, dynamic>?;

    return ServiceModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Servicio',
      description: json['description'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      durationMinutes: json['duration_minutes'] as int?,
      isActive: json['is_active'] as bool? ?? true,
      categoryId: json['categories_services_id'] as int?,
      categoryName: category?['name'] as String?,
      professionalId: json['professional_id'] as int?,
      professionalName: profile?['display_name'] as String?,
      professionalAvatar: profile?['avatar_url'] as String?,
      rating: (professional?['rating_avg'] as num?)?.toDouble(),
    );
  }
}
