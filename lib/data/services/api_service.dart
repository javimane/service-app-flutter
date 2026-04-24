import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../models/api_models.dart';

class ApiService {
  final ApiClient _client;

  ApiService(this._client);

  // --- HEALTH ---
  Future<Map<String, dynamic>> checkHealth() async {
    final response = await _client.get('/health');
    return response.data;
  }

  // --- PROFESSIONALS ---
  Future<List<ProfessionalModel>> getProfessionals({int? limit}) async {
    final response = await _client.get('/professionals', queryParameters: limit != null ? {'limit': limit} : null);
    return (response.data as List).map((e) => ProfessionalModel.fromJson(e)).toList();
  }

  Future<ProfessionalModel?> getMyProfessionalProfile() async {
    final response = await _client.get('/professionals/me');
    if (response.data == null) return null;
    return ProfessionalModel.fromJson(response.data);
  }

  Future<ProfessionalModel> getProfessionalById(int id) async {
    final response = await _client.get('/professionals/$id');
    return ProfessionalModel.fromJson(response.data);
  }

  // --- ADDRESSES ---
  Future<List<AddressModel>> getMyAddresses() async {
    final response = await _client.get('/addresses/my');
    return (response.data as List).map((e) => AddressModel.fromJson(e)).toList();
  }

  Future<AddressModel> createAddress(Map<String, dynamic> addressData) async {
    final response = await _client.post('/addresses', data: addressData);
    return AddressModel.fromJson(response.data);
  }

  // --- PRODUCTS ---
  Future<List<ProductModel>> getProducts({int? page, int? limit}) async {
    final response = await _client.get('/products', queryParameters: {
      if (page != null) 'page': page,
      if (limit != null) 'limit': limit,
    });
    return (response.data['data'] as List).map((e) => ProductModel.fromJson(e)).toList();
  }

  Future<ProductModel> getProductById(int id) async {
    final response = await _client.get('/products/$id');
    return ProductModel.fromJson(response.data);
  }

  Future<ProductModel> createProduct(Map<String, dynamic> productData) async {
    final response = await _client.post('/products', data: productData);
    return ProductModel.fromJson(response.data);
  }

  // --- SERVICES ---
  Future<List<ServiceModel>> getServices({String? name, int? categoryId}) async {
    final response = await _client.get('/services', queryParameters: {
      if (name != null) 'name': name,
      if (categoryId != null) 'categoryId': categoryId,
    });
    return (response.data as List).map((e) => ServiceModel.fromJson(e)).toList();
  }

  Future<ServiceModel> createService(Map<String, dynamic> serviceData) async {
    final response = await _client.post('/services', data: serviceData);
    return ServiceModel.fromJson(response.data);
  }

  // --- REVIEWS ---
  Future<List<ReviewModel>> getProfessionalReviews(int professionalId) async {
    final response = await _client.get('/reviews/professional/$professionalId');
    return (response.data as List).map((e) => ReviewModel.fromJson(e)).toList();
  }

  Future<ReviewModel> createReview(Map<String, dynamic> reviewData) async {
    final response = await _client.post('/reviews', data: reviewData);
    return ReviewModel.fromJson(response.data);
  }

  // --- PROPOSALS ---
  Future<ProfessionalProposalModel> createProposal(Map<String, dynamic> data) async {
    final response = await _client.post('/professional-proposals', data: data);
    return ProfessionalProposalModel.fromJson(response.data);
  }

  Future<List<ProfessionalProposalModel>> getReceivedProposals() async {
    final response = await _client.get('/professional-proposals/received');
    return (response.data as List).map((e) => ProfessionalProposalModel.fromJson(e)).toList();
  }

  Future<ProfessionalProposalModel> acceptProposal(String id) async {
    final response = await _client.post('/professional-proposals/$id/accept');
    return ProfessionalProposalModel.fromJson(response.data);
  }
}
