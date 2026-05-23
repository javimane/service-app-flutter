import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../network/api_client.dart';
import '../../providers/api_client_provider.dart';
import '../../services/api_constants.dart';
import '../models/categories.model.dart';

class CategoriesRepository {
  final ApiClient _client;
  CategoriesRepository(this._client);

  Future<List<CategoryModel>> findAllServices() async {
    final data = (await _client.get(ApiConstants.categoriesServices)).data;
    if (data is List) {
      return data
          .map((e) =>
              CategoryModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }
    return <CategoryModel>[];
  }

  Future<CategoryModel> findServiceById(int id) async {
    final data =
        (await _client.get('${ApiConstants.categoriesServices}/$id')).data;
    if (data is Map) {
      return CategoryModel.fromJson(Map<String, dynamic>.from(data));
    }
    throw Exception('Unexpected response for service category with id $id');
  }

  Future<List<CategoryModel>> findAllProducts() async {
    final data = (await _client.get(ApiConstants.categoriesProducts)).data;
    if (data is List) {
      return data
          .map((e) =>
              CategoryModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }
    return <CategoryModel>[];
  }

  Future<CategoryModel> findProductById(int id) async {
    final data =
        (await _client.get('${ApiConstants.categoriesProducts}/$id')).data;
    if (data is Map) {
      return CategoryModel.fromJson(Map<String, dynamic>.from(data));
    }
    throw Exception('Unexpected response for product category with id $id');
  }
}

final categoriesRepositoryProvider = Provider<CategoriesRepository>((ref) {
  return CategoriesRepository(ref.read(apiClientProvider));
});

final productCategoriesProvider =
    FutureProvider<List<CategoryModel>>((ref) async {
  return ref.read(categoriesRepositoryProvider).findAllProducts();
});

final productCategoryProvider =
    FutureProvider.family<CategoryModel, int>((ref, id) async {
  return ref.read(categoriesRepositoryProvider).findProductById(id);
});

final serviceCategoriesProvider =
    FutureProvider<List<CategoryModel>>((ref) async {
  return ref.read(categoriesRepositoryProvider).findAllServices();
});

final serviceCategoryProvider =
    FutureProvider.family<CategoryModel, int>((ref, id) async {
  return ref.read(categoriesRepositoryProvider).findServiceById(id);
});
