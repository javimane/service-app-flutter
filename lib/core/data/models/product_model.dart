import 'package:service_app_flutter/core/data/models/categories.model.dart';

// Reuse `CategoryModel` defined in `categories.model.dart` to avoid duplicates.

class ProductImage {
  final String id;
  final String imageUrl;
  final DateTime? createdAt;
  final String productId;
  final DateTime? updatedAt;
  final int? displayOrder;

  ProductImage(
      {required this.id,
      required this.imageUrl,
      this.createdAt,
      required this.productId,
      this.updatedAt,
      this.displayOrder});

  factory ProductImage.fromJson(Map<String, dynamic> json) => ProductImage(
        id: json['id'] as String? ?? '',
        imageUrl: json['image_url'] as String? ?? '',
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'] as String)
            : null,
        productId: json['product_id'] as String? ?? '',
        updatedAt: json['updated_at'] != null
            ? DateTime.tryParse(json['updated_at'] as String)
            : null,
        displayOrder: json['display_order'] as int?,
      );
}

class CompanySummary {
  final String? name;
  CompanySummary({this.name});
  factory CompanySummary.fromJson(Map<String, dynamic> json) =>
      CompanySummary(name: json['name'] as String?);
}

class ProvinceSummary {
  final String? name;
  ProvinceSummary({this.name});
  factory ProvinceSummary.fromJson(Map<String, dynamic> json) =>
      ProvinceSummary(name: json['name'] as String?);
}

class AddressSummary {
  final ProvinceSummary? province;
  final double? latitude;
  final double? longitude;
  final int? provinceId;

  AddressSummary(
      {this.province, this.latitude, this.longitude, this.provinceId});

  factory AddressSummary.fromJson(Map<String, dynamic> json) => AddressSummary(
        province: json['Province'] is Map<String, dynamic>
            ? ProvinceSummary.fromJson(json['Province'] as Map<String, dynamic>)
            : null,
        latitude: (json['latitude'] is num)
            ? (json['latitude'] as num).toDouble()
            : null,
        longitude: (json['longitude'] is num)
            ? (json['longitude'] as num).toDouble()
            : null,
        provinceId: json['province_id'] as int?,
      );
}

class ProfessionalSummary {
  final int? id;
  final List<CompanySummary> companies;
  final List<AddressSummary> addresses;

  ProfessionalSummary(
      {this.id, this.companies = const [], this.addresses = const []});

  factory ProfessionalSummary.fromJson(Map<String, dynamic> json) {
    final comp = <CompanySummary>[];
    if (json['Company'] is List) {
      for (final c in json['Company'] as List) {
        if (c is Map<String, dynamic>) {
          comp.add(CompanySummary.fromJson(c));
        }
      }
    }
    final addr = <AddressSummary>[];
    if (json['address'] is List) {
      for (final a in json['address'] as List) {
        if (a is Map<String, dynamic>) {
          addr.add(AddressSummary.fromJson(a));
        }
      }
    }
    return ProfessionalSummary(
        id: json['id'] as int?, companies: comp, addresses: addr);
  }
}

class ProfessionalProduct {
  final double? price;
  final int? stock;
  final String? linkUrl;
  final bool? isActive;
  final String? saleType;
  final double? offerPrice;
  final ProfessionalSummary? professional;
  final String? currencyCode;
  final int? professionalId;
  final int? percentDiscount;

  ProfessionalProduct(
      {this.price,
      this.stock,
      this.linkUrl,
      this.isActive,
      this.saleType,
      this.offerPrice,
      this.professional,
      this.currencyCode,
      this.professionalId,
      this.percentDiscount});

  factory ProfessionalProduct.fromJson(Map<String, dynamic> json) =>
      ProfessionalProduct(
        price: (json['price'] as num?)?.toDouble(),
        stock: json['stock'] as int?,
        linkUrl: json['link_url'] as String?,
        isActive: json['is_active'] as bool?,
        saleType: json['sale_type'] as String?,
        offerPrice: (json['offer_price'] as num?)?.toDouble(),
        professional: json['Professional'] is Map<String, dynamic>
            ? ProfessionalSummary.fromJson(
                json['Professional'] as Map<String, dynamic>)
            : null,
        currencyCode: json['currency_code'] as String?,
        professionalId: json['professional_id'] as int?,
        percentDiscount: json['percent_discount'] as int?,
      );
}

class ProductModel {
  final String id;
  final String name;
  final String? ean;
  final String? description;
  final String? brand;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool? isForeign;
  final int? categoryId;
  final CategoryModel? category;
  final List<ProductImage> images;
  final List<ProfessionalProduct> professionalProducts;
  final String? seoPath;
  final double? price;
  final double? defaultPrice;
  final int?
      professionalId; // convenience field (from first professional product)
  final String? professionalName; // convenience
  final bool isActive;
  final int? stock;

  ProductModel({
    required this.id,
    required this.name,
    this.ean,
    this.description,
    this.brand,
    this.createdAt,
    this.updatedAt,
    this.isForeign,
    this.categoryId,
    this.category,
    this.images = const [],
    this.professionalProducts = const [],
    this.seoPath,
    this.price,
    this.defaultPrice,
    this.professionalId,
    this.professionalName,
    this.isActive = true,
    this.stock,
  });

  String? get imageUrl => images.isNotEmpty ? images.first.imageUrl : null;

  String? get categoryName => category?.name;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // product may be nested under 'Product' or be the root
    final product = json['Product'] as Map<String, dynamic>? ?? json;

    final images = <ProductImage>[];
    if (product['Images'] is List) {
      for (final i in product['Images'] as List) {
        if (i is Map<String, dynamic>) {
          images.add(ProductImage.fromJson(i));
        }
      }
    }

    final profProds = <ProfessionalProduct>[];
    if (product['ProfessionalProducts'] is List) {
      for (final p in product['ProfessionalProducts'] as List) {
        if (p is Map<String, dynamic>) {
          profProds.add(ProfessionalProduct.fromJson(p));
        }
      }
    }

    CategoryModel? category;
    if (product['Category'] is Map<String, dynamic>) {
      category =
          CategoryModel.fromJson(product['Category'] as Map<String, dynamic>);
    }

    final defaultPrice = (json['price'] as num?)?.toDouble() ??
        (product['price'] as num?)?.toDouble();

    int? profId;
    String? profName;
    if (profProds.isNotEmpty) {
      profId = profProds.first.professionalId;
      // try to extract company name from professional summary
      final prof = profProds.first.professional;
      if (prof != null && prof.companies.isNotEmpty) {
        profName = prof.companies.first.name;
      }
    }

    return ProductModel(
      id: product['id']?.toString() ?? '',
      name: product['name'] as String? ?? 'Producto',
      ean: product['ean'] as String?,
      description: product['description'] as String?,
      brand: product['brand'] as String?,
      createdAt: product['created_at'] != null
          ? DateTime.tryParse(product['created_at'] as String)
          : null,
      updatedAt: product['updated_at'] != null
          ? DateTime.tryParse(product['updated_at'] as String)
          : null,
      isForeign: product['is_foreign'] as bool?,
      categoryId: product['categories_products_id'] as int?,
      category: category,
      images: images,
      professionalProducts: profProds,
      seoPath: product['seo_path'] as String?,
      price: (product['price'] as num?)?.toDouble() ?? defaultPrice,
      defaultPrice: defaultPrice,
      professionalId: profId,
      professionalName: profName,
      isActive: (json['is_active'] as bool?) ??
          (product['is_active'] as bool?) ??
          true,
      stock: (json['stock'] as int?) ??
          (profProds.isNotEmpty ? profProds.first.stock : null),
    );
  }
}
