class ProvinceModel {
  final int id;
  final String name;
  final String? createdAt;

  ProvinceModel({required this.id, required this.name, this.createdAt});

  factory ProvinceModel.fromJson(Map<String, dynamic> json) => ProvinceModel(
        id: json['id'] as int,
        name: json['name'] as String,
        createdAt: json['created_at'] as String?,
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
        id: json['id'] as int,
        provinceId: json['province_id'] as int,
        name: json['name'] as String,
        createdAt: json['created_at'] as String?,
        province: json['Province'] != null
            ? ProvinceModel.fromJson(json['Province'] as Map<String, dynamic>)
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
