class Province {
  final int id;
  final String name;
  final DateTime? createdAt;

  Province({required this.id, required this.name, this.createdAt});

  factory Province.fromJson(Map<String, dynamic> json) => Province(
        id: json['id'] as int,
        name: json['name'] as String,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : null,
      );
}

class Department {
  final int id;
  final String name;
  final DateTime? createdAt;
  final int? provinceId;

  Department(
      {required this.id, required this.name, this.createdAt, this.provinceId});

  factory Department.fromJson(Map<String, dynamic> json) => Department(
        id: json['id'] as int,
        name: json['name'] as String,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : null,
        provinceId: json['province_id'] as int?,
      );
}

class CompanyProvince {
  final Province province;
  final int companyId;
  final DateTime? createdAt;
  final int? provinceId;

  CompanyProvince(
      {required this.province,
      required this.companyId,
      this.createdAt,
      this.provinceId});

  factory CompanyProvince.fromJson(Map<String, dynamic> json) =>
      CompanyProvince(
        province: Province.fromJson(json['Province'] as Map<String, dynamic>),
        companyId: json['company_id'] as int,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : null,
        provinceId: json['province_id'] as int?,
      );
}

class CompanyDepartment {
  final Department department;
  final int companyId;
  final DateTime? createdAt;
  final int? provinceDepartmentId;

  CompanyDepartment(
      {required this.department,
      required this.companyId,
      this.createdAt,
      this.provinceDepartmentId});

  factory CompanyDepartment.fromJson(Map<String, dynamic> json) =>
      CompanyDepartment(
        department:
            Department.fromJson(json['Department'] as Map<String, dynamic>),
        companyId: json['company_id'] as int,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : null,
        provinceDepartmentId: json['province_department_id'] as int?,
      );
}

class Address {
  final int id;
  final int? professionalId;
  final int? provinceId;
  final int? departmentId;
  final String? streetName;
  final String? streetNumber;
  final String? floorApartment;
  final String? zipCode;
  final double? latitude;
  final double? longitude;
  final bool? isMainAddress;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Address(
      {required this.id,
      this.professionalId,
      this.provinceId,
      this.departmentId,
      this.streetName,
      this.streetNumber,
      this.floorApartment,
      this.zipCode,
      this.latitude,
      this.longitude,
      this.isMainAddress,
      this.createdAt,
      this.updatedAt});

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        id: json['id'] as int,
        professionalId: json['professional_id'] as int?,
        provinceId: json['province_id'] as int?,
        departmentId: json['department_id'] as int?,
        streetName: json['street_name'] as String?,
        streetNumber: json['street_number'] as String?,
        floorApartment: json['floor_apartment'] as String?,
        zipCode: json['zip_code'] as String?,
        latitude: (json['latitude'] is num)
            ? (json['latitude'] as num).toDouble()
            : null,
        longitude: (json['longitude'] is num)
            ? (json['longitude'] as num).toDouble()
            : null,
        isMainAddress: json['is_main_address'] as bool?,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : null,
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'] as String)
            : null,
      );
}

class Company {
  final int id;
  final String name;
  final String? taxCode;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? professionalId;
  final int? addressId;
  final String? businessType;
  final bool? publicTrade;
  final bool? cash;
  final bool? transfer;
  final bool? credit;
  final bool? debit;
  final bool? cheque;
  final List<CompanyProvince> companyProvinces;
  final List<CompanyDepartment> companyDepartments;
  final Address? address;

  Company(
      {required this.id,
      required this.name,
      this.taxCode,
      this.createdAt,
      this.updatedAt,
      this.professionalId,
      this.addressId,
      this.businessType,
      this.publicTrade,
      this.cash,
      this.transfer,
      this.credit,
      this.debit,
      this.cheque,
      this.companyProvinces = const [],
      this.companyDepartments = const [],
      this.address});

  factory Company.fromJson(Map<String, dynamic> json) {
    final provinces = <CompanyProvince>[];
    if (json['CompanyProvinces'] is List) {
      for (final p in json['CompanyProvinces'] as List) {
        if (p is Map<String, dynamic>) {
          provinces.add(CompanyProvince.fromJson(p));
        }
      }
    }

    final departments = <CompanyDepartment>[];
    if (json['CompanyDepartments'] is List) {
      for (final d in json['CompanyDepartments'] as List) {
        if (d is Map<String, dynamic>) {
          departments.add(CompanyDepartment.fromJson(d));
        }
      }
    }

    Address? addr;
    if (json['Address'] is Map<String, dynamic>) {
      addr = Address.fromJson(json['Address'] as Map<String, dynamic>);
    }

    return Company(
      id: json['id'] as int,
      name: json['name'] as String,
      taxCode: json['tax_code'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
      professionalId: json['professional_id'] as int?,
      addressId: json['address_id'] as int?,
      businessType: json['business_type'] as String?,
      publicTrade: json['public_trade'] as bool?,
      cash: json['cash'] as bool?,
      transfer: json['transfer'] as bool?,
      credit: json['credit'] as bool?,
      debit: json['debit'] as bool?,
      cheque: json['cheque'] as bool?,
      companyProvinces: provinces,
      companyDepartments: departments,
      address: addr,
    );
  }
}

// Helper to parse a list response that might be a raw List or wrapped under `data`.
List<Company> companiesFromResponse(dynamic res) {
  if (res == null) {
    return [];
  }
  if (res is List) {
    return res
        .whereType<Map<String, dynamic>>()
        .map((e) => Company.fromJson(e))
        .toList();
  }
  if (res is Map && res['data'] is List) {
    return (res['data'] as List)
        .whereType<Map<String, dynamic>>()
        .map((e) => Company.fromJson(e))
        .toList();
  }
  return [];
}
