import 'professional_model.dart';
import 'product_model.dart';

class ProfessionalProductModel {
  final int id;
  final int professionalId;
  final int productId;
  final double price;
  final String saleType;
  final bool? isActive;
  final int? stock;
  final double? offerPrice;
  final String? currencyCode;
  final int? percentDiscount;
  final String? linkUrl;
  final String? createdAt;
  final String? updatedAt;
  final ProfessionalModel? professional;
  final ProductModel? product;

  ProfessionalProductModel({
    required this.id,
    required this.professionalId,
    required this.productId,
    required this.price,
    required this.saleType,
    this.isActive,
    this.stock,
    this.offerPrice,
    this.currencyCode,
    this.percentDiscount,
    this.linkUrl,
    this.createdAt,
    this.updatedAt,
    this.professional,
    this.product,
  });

  factory ProfessionalProductModel.fromJson(Map<String, dynamic> json) =>
      ProfessionalProductModel(
        id: json['id'] as int,
        professionalId: json['professional_id'] as int,
        productId: json['product_id'] as int,
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
        saleType: json['sale_type'] as String? ?? '',
        isActive: json['is_active'] as bool?,
        stock: json['stock'] as int?,
        offerPrice: (json['offer_price'] as num?)?.toDouble() ?? 0.0,
        currencyCode: json['currency_code'] as String?,
        percentDiscount: json['percent_discount'] as int?,
        linkUrl: json['link_url'] as String?,
        createdAt: json['created_at'] as String?,
        updatedAt: json['updated_at'] as String?,
        professional: json['Professional'] != null
            ? ProfessionalModel.fromJson(
                json['Professional'] as Map<String, dynamic>)
            : null,
        product: json['Product'] != null
            ? ProductModel.fromJson(json['Product'] as Map<String, dynamic>)
            : null,
      );
}
