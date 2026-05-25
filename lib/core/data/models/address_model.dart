import 'professional_model.dart';
import 'location_model.dart';

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
        id: json['id'] as int,
        professionalId: json['professional_id'] as int,
        provinceId: json['province_id'] as int,
        departmentId: json['department_id'] as int,
        streetName: json['street_name'] as String? ?? '',
        streetNumber: json['street_number'] as String?,
        floorApartment: json['floor_apartment'] as String?,
        zipCode: json['zip_code'] as String?,
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        isMainAddress: json['is_main_address'] as bool?,
        createdAt: json['created_at'] as String?,
        updatedAt: json['updated_at'] as String?,
        professional: json['Professional'] != null
            ? ProfessionalModel.fromJson(
                json['Professional'] as Map<String, dynamic>)
            : null,
        province: json['Province'] != null
            ? ProvinceModel.fromJson(json['Province'] as Map<String, dynamic>)
            : null,
        department: json['Department'] != null
            ? ProvinceDepartmentModel.fromJson(
                json['Department'] as Map<String, dynamic>)
            : null,
      );
}
