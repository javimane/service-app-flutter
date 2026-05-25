import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/models/professional_model.dart';
import '../../../core/data/repositories/professionals_repository.dart';
import '../../../core/data/models/categories.model.dart';
import '../../../core/data/models/location_model.dart';
import '../../../core/data/repositories/categories_repository.dart';
import '../../../core/data/repositories/provinces_repository.dart';
import '../../../core/data/repositories/province_departments_repository.dart';

class MapFilters {
  final String query;
  final int? categoryId;
  final int? provinceId;
  final int? departmentId;
  final double? lat;
  final double? lng;

  MapFilters({
    this.query = '',
    this.categoryId,
    this.provinceId,
    this.departmentId,
    this.lat,
    this.lng,
  });

  MapFilters copyWith({
    String? query,
    int? categoryId,
    int? provinceId,
    int? departmentId,
    double? lat,
    double? lng,
    bool clearCategory = false,
    bool clearProvince = false,
    bool clearDepartment = false,
  }) {
    return MapFilters(
      query: query ?? this.query,
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      provinceId: clearProvince ? null : (provinceId ?? this.provinceId),
      departmentId: clearDepartment ? null : (departmentId ?? this.departmentId),
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
    );
  }
}

final mapFiltersProvider = StateProvider<MapFilters>((ref) => MapFilters());

final mapProfessionalsProvider = FutureProvider<List<ProfessionalModel>>((ref) async {
  final filters = ref.watch(mapFiltersProvider);
  final repo = ref.read(professionalsRepositoryProvider);
  
  // As in the web app, we can fetch public_trade = true
  final professionals = await repo.getProfessionals(
    query: filters.query,
    categoryId: filters.categoryId,
    provinceId: filters.provinceId,
    departmentId: filters.departmentId,
    lat: filters.lat,
    lng: filters.lng,
    radius: filters.lat != null ? 20 : null,
    publicTrade: true,
  );

  // Filter out those without valid coordinates
  return professionals.where((p) => p.latitude != null && p.longitude != null).toList();
});

final mapCategoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  return ref.read(categoriesRepositoryProvider).findAllServices();
});

final mapProvincesProvider = FutureProvider<List<ProvinceModel>>((ref) async {
  final data = await ref.read(provincesRepositoryProvider).findAll();
  if (data is List) {
    return data.map((e) => ProvinceModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }
  return [];
});

final mapDepartmentsProvider = FutureProvider<List<ProvinceDepartmentModel>>((ref) async {
  final filters = ref.watch(mapFiltersProvider);
  if (filters.provinceId == null) return [];
  
  final data = await ref.read(provinceDepartmentsRepositoryProvider).findByProvinceId(filters.provinceId!);
  if (data is List) {
    return data.map((e) => ProvinceDepartmentModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }
  return [];
});
