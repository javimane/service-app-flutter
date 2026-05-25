import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/models/professional_model.dart';
import '../../../core/data/models/categories.model.dart';
import '../../../core/data/models/location_model.dart';
import '../../../core/data/repositories/professionals_repository.dart';
import '../../../core/data/repositories/categories_repository.dart';
import '../../../core/data/repositories/provinces_repository.dart';
import '../../../core/data/repositories/province_departments_repository.dart';

class CategoriesFilterState {
  final String query;
  final int? categoryId;
  final int? provinceId;
  final int? departmentId;
  final String accountType; // "Comercio", "Autónomo"
  final bool urgentOnly;
  final bool publicStoreOnly;
  final bool verifiedOnly;
  final bool matriculatedOnly;

  CategoriesFilterState({
    this.query = '',
    this.categoryId,
    this.provinceId,
    this.departmentId,
    this.accountType = 'Todos',
    this.urgentOnly = false,
    this.publicStoreOnly = false,
    this.verifiedOnly = false,
    this.matriculatedOnly = false,
  });

  CategoriesFilterState copyWith({
    String? query,
    int? categoryId,
    int? provinceId,
    int? departmentId,
    String? accountType,
    bool? urgentOnly,
    bool? publicStoreOnly,
    bool? verifiedOnly,
    bool? matriculatedOnly,
    bool clearCategory = false,
    bool clearProvince = false,
    bool clearDepartment = false,
  }) {
    return CategoriesFilterState(
      query: query ?? this.query,
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      provinceId: clearProvince ? null : (provinceId ?? this.provinceId),
      departmentId:
          clearDepartment ? null : (departmentId ?? this.departmentId),
      accountType: accountType ?? this.accountType,
      urgentOnly: urgentOnly ?? this.urgentOnly,
      publicStoreOnly: publicStoreOnly ?? this.publicStoreOnly,
      verifiedOnly: verifiedOnly ?? this.verifiedOnly,
      matriculatedOnly: matriculatedOnly ?? this.matriculatedOnly,
    );
  }
}

final categoriesFilterProvider =
    StateProvider<CategoriesFilterState>((ref) => CategoriesFilterState());

final categoriesListProvider = FutureProvider<List<CategoryModel>>((ref) async {
  return ref.read(categoriesRepositoryProvider).findAllServices();
});

final categoriesProvincesProvider =
    FutureProvider<List<ProvinceModel>>((ref) async {
  final data = await ref.read(provincesRepositoryProvider).findAll();
  if (data is List) {
    return data
        .map((e) => ProvinceModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
  return [];
});

final categoriesDepartmentsProvider =
    FutureProvider<List<ProvinceDepartmentModel>>((ref) async {
  final filters = ref.watch(categoriesFilterProvider);
  if (filters.provinceId == null) return [];

  final data = await ref
      .read(provinceDepartmentsRepositoryProvider)
      .findByProvinceId(filters.provinceId!);
  if (data is List) {
    return data
        .map((e) => ProvinceDepartmentModel.fromJson(
            Map<String, dynamic>.from(e as Map)))
        .toList();
  }
  return [];
});

final categoriesProfessionalsProvider =
    FutureProvider<List<ProfessionalModel>>((ref) async {
  final filters = ref.watch(categoriesFilterProvider);
  final repo = ref.read(professionalsRepositoryProvider);

  final professionals = await repo.getProfessionals(
    query: filters.query,
    categoryId: filters.categoryId,
    provinceId: filters.provinceId,
    departmentId: filters.departmentId,
    isMatriculate: filters.matriculatedOnly ? 'true' : null,
    isVerified: filters.verifiedOnly ? 'true' : null,
    emergency: filters.urgentOnly ? 'true' : null,
    publicTrade: filters.publicStoreOnly
        ? true
        : null, // Assuming boolean in getProfessionals params
    limit: 100, // Fetch up to 100 professionals
  );

  // Client-side filtering for accountType since it's not a parameter in getProfessionals
  if (filters.accountType == 'Comercio') {
    return professionals.where((p) => p.accountType == 'company').toList();
  } else if (filters.accountType == 'Autónomo') {
    return professionals.where((p) => p.accountType != 'company').toList();
  }

  return professionals;
});
