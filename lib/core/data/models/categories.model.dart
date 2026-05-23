class CategoryModel {
  final int id;
  final String name;
  final String? seoPath;
  final String? imageUrl;

  CategoryModel(
      {required this.id, required this.name, this.seoPath, this.imageUrl});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final idVal = json['id'];
    final id =
        idVal is int ? idVal : int.tryParse(idVal?.toString() ?? '') ?? 0;
    return CategoryModel(
      id: id,
      name: (json['name'] ?? '') as String,
      seoPath: json['seo_path'] as String?,
      imageUrl: json['image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (seoPath != null) 'seo_path': seoPath,
        if (imageUrl != null) 'image_url': imageUrl,
      };
}
