import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../network/api_client.dart';
import '../../providers/api_client_provider.dart';
import '../../services/api_constants.dart';
import '../models/product_model.dart';
import '../models/categories.model.dart';
import '../models/professional_product_model.dart';

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

  Future<ProductModel?> getProductById(String id) async {
    final response = await _client.get('${ApiConstants.products}/$id');
    if (response.data == null) return null;
    return ProductModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<ProfessionalProductModel>> getProductsByProfessional(
      int professionalId) async {
    final response = await _client
        .get('${ApiConstants.products}/professional/$professionalId');
    final data = response.data as List<dynamic>;
    return data
        .map(
            (e) => ProfessionalProductModel.fromJson(e as Map<String, dynamic>))
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

  Future<Map<String, dynamic>> createProduct(Map<String, dynamic> data) async {
    final response = await _client.post(ApiConstants.products, data: data);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> assignProductToProfessional(
      Map<String, dynamic> data) async {
    final response = await _client.post(
      '${ApiConstants.products}/assign-professional',
      data: data,
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateProfessionalProduct(
      int professionalId, String productId, Map<String, dynamic> updates) async {
    final response = await _client.put(
      '${ApiConstants.products}/professional/$professionalId/product/$productId',
      data: updates,
    );
    return response.data as Map<String, dynamic>;
  }

  Future<void> unassignProductFromProfessional(
      String productId, int professionalId) async {
    await _client.delete(
      '${ApiConstants.products}/$productId/professional/$professionalId',
    );
  }

  Future<Map<String, dynamic>> massUpdateProductPrices(
      Map<String, dynamic> data) async {
    final response = await _client.put(
      '${ApiConstants.products}/mass-update-prices',
      data: data,
    );
    return response.data as Map<String, dynamic>;
  }

  Future<ProductModel?> getProductByEan(String ean,
      {int? professionalId}) async {
    final params = <String, dynamic>{};
    if (professionalId != null) {
      params['professionalId'] = professionalId.toString();
    }
    try {
      final response = await _client.get(
        '${ApiConstants.products}/ean/$ean',
        queryParameters: params,
      );
      if (response.data == null) return null;
      // Depending on backend, it might return a list or a single object. 
      // Assuming a single object based on web DashboardProducts implementation.
      final raw = response.data;
      if (raw is List) {
        if (raw.isEmpty) return null;
        return ProductModel.fromJson(raw.first as Map<String, dynamic>);
      }
      return ProductModel.fromJson(raw as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
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
