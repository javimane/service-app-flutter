class ProductModel {
  final int id;
  final String name;
  final String? description;
  final String? brand;
  final String? imageUrl;
  final double? price;
  final int? categoryId;
  final String? categoryName;
  final int? professionalId;
  final String? professionalName;
  final bool isActive;
  final int? stock;

  ProductModel({
    required this.id,
    required this.name,
    this.description,
    this.brand,
    this.imageUrl,
    this.price,
    this.categoryId,
    this.categoryName,
    this.professionalId,
    this.professionalName,
    this.isActive = true,
    this.stock,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Handles both ProductRow and ProfessionalProductRow
    final product = json['Product'] as Map<String, dynamic>? ?? json;
    final category = product['CategoriesProduct'] as Map<String, dynamic>?;
    final professional = json['Professional'] as Map<String, dynamic>?;
    final profile = professional?['Profile'] as Map<String, dynamic>?;

    return ProductModel(
      id: product['id'] as int,
      name: product['name'] as String? ?? 'Producto',
      description: product['description'] as String?,
      brand: product['brand'] as String?,
      imageUrl: product['image_url'] as String?,
      price: (json['price'] as num?)?.toDouble() ??
          (product['price'] as num?)?.toDouble(),
      categoryId: product['categories_products_id'] as int?,
      categoryName: category?['name'] as String?,
      professionalId: json['professional_id'] as int?,
      professionalName: profile?['display_name'] as String?,
      isActive:
          json['is_active'] as bool? ?? product['is_active'] as bool? ?? true,
      stock: json['stock'] as int?,
    );
  }
}
