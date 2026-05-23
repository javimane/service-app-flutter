import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../network/api_client.dart';
import '../../providers/api_client_provider.dart';
import '../../services/api_constants.dart';
import '../models/service_model.dart';
import '../models/categories.model.dart';

class ServicesRepository {
  final ApiClient _client;

  ServicesRepository(this._client);

  Future<List<ServiceModel>> getServices({
    String? name,
    int? categoryId,
    double? minPrice,
    double? maxPrice,
    bool? isActive,
  }) async {
    final response = await _client.get(
      ApiConstants.services,
      queryParameters: {
        if (name != null) 'name': name,
        if (categoryId != null) 'categoryId': categoryId,
        if (minPrice != null) 'minPrice': minPrice,
        if (maxPrice != null) 'maxPrice': maxPrice,
        if (isActive != null) 'isActive': isActive,
      },
    );
    final data = response.data as List<dynamic>;
    return data
        .map((e) => ServiceModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ServiceModel?> getServiceById(int id) async {
    final response = await _client.get('${ApiConstants.services}/$id');
    if (response.data == null) return null;
    return ServiceModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<CategoryModel>> getServiceCategories() async {
    final response = await _client.get(ApiConstants.categoriesServices);
    final data = response.data as List<dynamic>;
    return data
        .map((e) => CategoryModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<List<ServiceModel>> getServicesByProfessional(
      int professionalId) async {
    final response = await _client
        .get('${ApiConstants.services}/professional/$professionalId');
    final data = response.data as List<dynamic>;
    return data
        .map((e) => ServiceModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

final servicesRepositoryProvider = Provider<ServicesRepository>((ref) {
  return ServicesRepository(ref.read(apiClientProvider));
});

final servicesProvider = FutureProvider<List<ServiceModel>>((ref) async {
  return ref.read(servicesRepositoryProvider).getServices(isActive: true);
});

// Service categories provider moved to `categories_repository.dart` to
// centralize category endpoints and types.
