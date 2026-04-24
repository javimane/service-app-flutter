// GENERATED API MODELS

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
        id: json['id'],
        email: json['email'],
        displayName: json['display_name'],
        avatarUrl: json['avatar_url'],
        updatedAt: json['updated_at'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'display_name': displayName,
        'avatar_url': avatarUrl,
        'updated_at': updatedAt,
      };
}

class AddressModel {
  final int id;
  final int professionalId;
  final int provinceId;
  final int departmentId;
  final String streetName;
  final String? streetNumber;
  final String? floorApartment;
  final String? zipCode;
  final double? latitude;
  final double? longitude;
  final bool? isMainAddress;
  final String? createdAt;
  final String? updatedAt;
  final ProfessionalModel? professional;
  final ProvinceModel? province;
  final ProvinceDepartmentModel? department;

  AddressModel({
    required this.id,
    required this.professionalId,
    required this.provinceId,
    required this.departmentId,
    required this.streetName,
    this.streetNumber,
    this.floorApartment,
    this.zipCode,
    this.latitude,
    this.longitude,
    this.isMainAddress,
    this.createdAt,
    this.updatedAt,
    this.professional,
    this.province,
    this.department,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) => AddressModel(
        id: json['id'],
        professionalId: json['professional_id'],
        provinceId: json['province_id'],
        departmentId: json['department_id'],
        streetName: json['street_name'],
        streetNumber: json['street_number'],
        floorApartment: json['floor_apartment'],
        zipCode: json['zip_code'],
        latitude: json['latitude']?.toDouble(),
        longitude: json['longitude']?.toDouble(),
        isMainAddress: json['is_main_address'],
        createdAt: json['created_at'],
        updatedAt: json['updated_at'],
        professional: json['Professional'] != null
            ? ProfessionalModel.fromJson(json['Professional'])
            : null,
        province: json['Province'] != null
            ? ProvinceModel.fromJson(json['Province'])
            : null,
        department: json['Department'] != null
            ? ProvinceDepartmentModel.fromJson(json['Department'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'professional_id': professionalId,
        'province_id': provinceId,
        'department_id': departmentId,
        'street_name': streetName,
        'street_number': streetNumber,
        'floor_apartment': floorApartment,
        'zip_code': zipCode,
        'latitude': latitude,
        'longitude': longitude,
        'is_main_address': isMainAddress,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'Professional': professional?.toJson(),
        'Province': province?.toJson(),
        'Department': department?.toJson(),
      };
}

class CategoryProductModel {
  final int id;
  final String name;

  CategoryProductModel({required this.id, required this.name});

  factory CategoryProductModel.fromJson(Map<String, dynamic> json) =>
      CategoryProductModel(id: json['id'], name: json['name']);

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

class CategoryServiceModel {
  final int id;
  final String name;

  CategoryServiceModel({required this.id, required this.name});

  factory CategoryServiceModel.fromJson(Map<String, dynamic> json) =>
      CategoryServiceModel(id: json['id'], name: json['name']);

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

class CompanyModel {
  final int id;
  final String? name;
  final String? taxCode;
  final String? arcaFile;
  final String createdAt;
  final String? updatedAt;
  final int professionalId;
  final int addressId;
  final String? businessType;
  final bool? publicTrade;
  final ProfessionalModel? professional;
  final AddressModel? address;

  CompanyModel({
    required this.id,
    this.name,
    this.taxCode,
    this.arcaFile,
    required this.createdAt,
    this.updatedAt,
    required this.professionalId,
    required this.addressId,
    this.businessType,
    this.publicTrade,
    this.professional,
    this.address,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) => CompanyModel(
        id: json['id'],
        name: json['name'],
        taxCode: json['tax_code'],
        arcaFile: json['arca_file'],
        createdAt: json['created_at'],
        updatedAt: json['updated_at'],
        professionalId: json['professional_id'],
        addressId: json['address_id'],
        businessType: json['business_type'],
        publicTrade: json['public_trade'],
        professional: json['Professional'] != null
            ? ProfessionalModel.fromJson(json['Professional'])
            : null,
        address: json['Address'] != null
            ? AddressModel.fromJson(json['Address'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'tax_code': taxCode,
        'arca_file': arcaFile,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'professional_id': professionalId,
        'address_id': addressId,
        'business_type': businessType,
        'public_trade': publicTrade,
        'Professional': professional?.toJson(),
        'Address': address?.toJson(),
      };
}

class CompaniesArcaModel {
  final int id;
  final int companyId;
  final String validFrom;
  final String validTo;
  final bool? isVerified;
  final String? verifiedAt;
  final String? createdAt;
  final String? token;
  final String? tokenExpiresAt;
  final CompanyModel? company;

  CompaniesArcaModel({
    required this.id,
    required this.companyId,
    required this.validFrom,
    required this.validTo,
    this.isVerified,
    this.verifiedAt,
    this.createdAt,
    this.token,
    this.tokenExpiresAt,
    this.company,
  });

  factory CompaniesArcaModel.fromJson(Map<String, dynamic> json) =>
      CompaniesArcaModel(
        id: json['id'],
        companyId: json['company_id'],
        validFrom: json['valid_from'],
        validTo: json['valid_to'],
        isVerified: json['is_verified'],
        verifiedAt: json['verified_at'],
        createdAt: json['created_at'],
        token: json['token'],
        tokenExpiresAt: json['token_expires_at'],
        company: json['Company'] != null
            ? CompanyModel.fromJson(json['Company'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'company_id': companyId,
        'valid_from': validFrom,
        'valid_to': validTo,
        'is_verified': isVerified,
        'verified_at': verifiedAt,
        'created_at': createdAt,
        'token': token,
        'token_expires_at': tokenExpiresAt,
        'Company': company?.toJson(),
      };
}

class ProductModel {
  final int id;
  final String ean;
  final String name;
  final String? description;
  final String? brand;
  final String? imageUrl;
  final String? createdAt;
  final String? updatedAt;
  final int? categoriesProductsId;
  final bool? isForeign;
  final CategoryProductModel? categoryProduct;

  ProductModel({
    required this.id,
    required this.ean,
    required this.name,
    this.description,
    this.brand,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
    this.categoriesProductsId,
    this.isForeign,
    this.categoryProduct,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
        id: json['id'],
        ean: json['ean'],
        name: json['name'],
        description: json['description'],
        brand: json['brand'],
        imageUrl: json['image_url'],
        createdAt: json['created_at'],
        updatedAt: json['updated_at'],
        categoriesProductsId: json['categories_products_id'],
        isForeign: json['is_foreign'],
        categoryProduct: json['CategoryProduct'] != null
            ? CategoryProductModel.fromJson(json['CategoryProduct'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'ean': ean,
        'name': name,
        'description': description,
        'brand': brand,
        'image_url': imageUrl,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'categories_products_id': categoriesProductsId,
        'is_foreign': isForeign,
        'CategoryProduct': categoryProduct?.toJson(),
      };
}

class ProfessionalModel {
  final int id;
  final String userId;
  final String? bio;
  final double ratingAvg;
  final bool isActive;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final String? webUrl;
  final String? accountType;
  final bool? isMatriculate;
  final bool? emergency;
  final int? profileViews;
  final ProfileModel? profile;

  ProfessionalModel({
    required this.id,
    required this.userId,
    this.bio,
    required this.ratingAvg,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.webUrl,
    this.accountType,
    this.isMatriculate,
    this.emergency,
    this.profileViews,
    this.profile,
  });

  factory ProfessionalModel.fromJson(Map<String, dynamic> json) =>
      ProfessionalModel(
        id: json['id'],
        userId: json['user_id'],
        bio: json['bio'],
        ratingAvg: (json['rating_avg'] ?? 0).toDouble(),
        isActive: json['is_active'],
        createdAt: json['created_at'],
        updatedAt: json['updated_at'],
        deletedAt: json['deleted_at'],
        webUrl: json['web_url'],
        accountType: json['account_type'],
        isMatriculate: json['is_matriculate'],
        emergency: json['emergency'],
        profileViews: json['profile_views'],
        profile: json['Profile'] != null
            ? ProfileModel.fromJson(json['Profile'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'bio': bio,
        'rating_avg': ratingAvg,
        'is_active': isActive,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'deleted_at': deletedAt,
        'web_url': webUrl,
        'account_type': accountType,
        'is_matriculate': isMatriculate,
        'emergency': emergency,
        'profile_views': profileViews,
        'Profile': profile?.toJson(),
      };
}

class ProfessionalProductModel {
  final int id;
  final int professionalId;
  final int productId;
  final double price;
  final String saleType;
  final bool? isActive;
  final int? stock;
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
    this.createdAt,
    this.updatedAt,
    this.professional,
    this.product,
  });

  factory ProfessionalProductModel.fromJson(Map<String, dynamic> json) =>
      ProfessionalProductModel(
        id: json['id'],
        professionalId: json['professional_id'],
        productId: json['product_id'],
        price: (json['price'] ?? 0).toDouble(),
        saleType: json['sale_type'],
        isActive: json['is_active'],
        stock: json['stock'],
        createdAt: json['created_at'],
        updatedAt: json['updated_at'],
        professional: json['Professional'] != null
            ? ProfessionalModel.fromJson(json['Professional'])
            : null,
        product: json['Product'] != null
            ? ProductModel.fromJson(json['Product'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'professional_id': professionalId,
        'product_id': productId,
        'price': price,
        'sale_type': saleType,
        'is_active': isActive,
        'stock': stock,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'Professional': professional?.toJson(),
        'Product': product?.toJson(),
      };
}

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
        id: json['id'],
        fileUrl: json['file_url'],
        accepted: json['accepted'] ?? false,
        professionalName: json['professional_name'],
        professionalId: json['professional_id'],
        userId: json['user_id'],
        createdAt: json['created_at'],
        professional: json['Professional'] != null
            ? ProfessionalModel.fromJson(json['Professional'])
            : null,
        profile: json['Profile'] != null
            ? ProfileModel.fromJson(json['Profile'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'file_url': fileUrl,
        'accepted': accepted,
        'professional_name': professionalName,
        'professional_id': professionalId,
        'user_id': userId,
        'created_at': createdAt,
        'Professional': professional?.toJson(),
        'Profile': profile?.toJson(),
      };
}

class ProfessionalAvailabilityModel {
  final int id;
  final int professionalId;
  final int? dayOfWeek;
  final String startTime;
  final String endTime;

  ProfessionalAvailabilityModel({
    required this.id,
    required this.professionalId,
    this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });

  factory ProfessionalAvailabilityModel.fromJson(Map<String, dynamic> json) =>
      ProfessionalAvailabilityModel(
        id: json['id'],
        professionalId: json['professional_id'],
        dayOfWeek: json['day_of_week'],
        startTime: json['start_time'],
        endTime: json['end_time'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'professional_id': professionalId,
        'day_of_week': dayOfWeek,
        'start_time': startTime,
        'end_time': endTime,
      };
}

class ServiceModel {
  final int id;
  final int professionalId;
  final int categoryServicesId;
  final String name;
  final String? description;
  final double? basePrice;
  final String? createdAt;
  final String? updatedAt;
  final ProfessionalModel? professional;
  final CategoryServiceModel? categoryService;

  ServiceModel({
    required this.id,
    required this.professionalId,
    required this.categoryServicesId,
    required this.name,
    this.description,
    this.basePrice,
    this.createdAt,
    this.updatedAt,
    this.professional,
    this.categoryService,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) => ServiceModel(
        id: json['id'],
        professionalId: json['professional_id'],
        categoryServicesId: json['category_services_id'],
        name: json['name'],
        description: json['description'],
        basePrice: json['base_price']?.toDouble(),
        createdAt: json['created_at'],
        updatedAt: json['updated_at'],
        professional: json['Professional'] != null
            ? ProfessionalModel.fromJson(json['Professional'])
            : null,
        categoryService: json['CategoryService'] != null
            ? CategoryServiceModel.fromJson(json['CategoryService'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'professional_id': professionalId,
        'category_services_id': categoryServicesId,
        'name': name,
        'description': description,
        'base_price': basePrice,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'Professional': professional?.toJson(),
        'CategoryService': categoryService?.toJson(),
      };
}

class ProvinceModel {
  final int id;
  final String name;
  final String? createdAt;

  ProvinceModel({required this.id, required this.name, this.createdAt});

  factory ProvinceModel.fromJson(Map<String, dynamic> json) => ProvinceModel(
        id: json['id'],
        name: json['name'],
        createdAt: json['created_at'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'created_at': createdAt,
      };
}

class ProvinceDepartmentModel {
  final int id;
  final int provinceId;
  final String name;
  final String? createdAt;
  final ProvinceModel? province;

  ProvinceDepartmentModel({
    required this.id,
    required this.provinceId,
    required this.name,
    this.createdAt,
    this.province,
  });

  factory ProvinceDepartmentModel.fromJson(Map<String, dynamic> json) =>
      ProvinceDepartmentModel(
        id: json['id'],
        provinceId: json['province_id'],
        name: json['name'],
        createdAt: json['created_at'],
        province: json['Province'] != null
            ? ProvinceModel.fromJson(json['Province'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'province_id': provinceId,
        'name': name,
        'created_at': createdAt,
        'Province': province?.toJson(),
      };
}

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
        id: json['id'],
        userId: json['user_id'],
        professionalId: json['professional_id'],
        rating: (json['rating'] ?? 0).toDouble(),
        comment: json['comment'],
        createdAt: json['created_at'],
        imageUrl: json['image_url'],
        profile: json['Profile'] != null
            ? ProfileModel.fromJson(json['Profile'])
            : null,
        professional: json['Professional'] != null
            ? ProfessionalModel.fromJson(json['Professional'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'professional_id': professionalId,
        'rating': rating,
        'comment': comment,
        'created_at': createdAt,
        'image_url': imageUrl,
        'Profile': profile?.toJson(),
        'Professional': professional?.toJson(),
      };
}
