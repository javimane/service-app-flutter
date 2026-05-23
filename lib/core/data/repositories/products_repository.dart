import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../network/api_client.dart';
import '../../providers/api_client_provider.dart';
import '../../services/api_constants.dart';
import '../models/product_model.dart';
import '../models/categories.model.dart';

class ProductsRepository {
  final ApiClient _client;

  ProductsRepository(this._client);

  Future<List<ProductModel>> getProducts({int page = 1, int limit = 20}) async {
    final response = await _client.get(
      ApiConstants.products,
      queryParameters: {'page': page, 'limit': limit},
    );
    final raw = response.data;
    List<dynamic> data;
    if (raw is Map<String, dynamic>) {
      data = raw['data'] as List<dynamic>? ?? [];
    } else {
      data = raw as List<dynamic>;
    }
    return data
        .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ProductModel?> getProductById(int id) async {
    final response = await _client.get('${ApiConstants.products}/$id');
    if (response.data == null) return null;
    return ProductModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<ProductModel>> getProductsByProfessional(
      int professionalId) async {
    final response = await _client
        .get('${ApiConstants.products}/professional/$professionalId');
    final data = response.data as List<dynamic>;
    return data
        .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ProductModel>> searchProductsByName(String name) async {
    final response = await _client.get('${ApiConstants.products}/name/$name');
    final data = response.data as List<dynamic>;
    return data
        .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<CategoryModel>> getProductCategories() async {
    final response = await _client.get(ApiConstants.categoriesProducts);
    final data = response.data as List<dynamic>;
    return data
        .map((e) => CategoryModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}

final productsRepositoryProvider = Provider<ProductsRepository>((ref) {
  return ProductsRepository(ref.read(apiClientProvider));
});

final productsProvider = FutureProvider<List<ProductModel>>((ref) async {
  return ref.read(productsRepositoryProvider).getProducts();
});

// Product categories provider moved to `categories_repository.dart` to
// centralize category endpoints and types.
