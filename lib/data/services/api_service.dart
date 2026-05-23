import '../../core/network/api_client.dart';
import '../models/api_models.dart';
import '../../core/services/api_constants.dart';
import '../../core/data/models/arca.model.dart';

class ApiService {
  final ApiClient _client;

  ApiService(this._client);

  // --- HEALTH ---
  Future<Map<String, dynamic>> checkHealth() async {
    final response = await _client.get(ApiConstants.health);
    return response.data;
  }

  // --- AUTH ---
  Future<dynamic> register(Map<String, dynamic> data) async {
    final response = await _client.post(ApiConstants.register, data: data);
    return response.data;
  }

  Future<dynamic> login(Map<String, dynamic> data) async {
    final response = await _client.post(ApiConstants.login, data: data);
    return response.data;
  }

  Future<dynamic> loginWithGoogle(String accessToken) async {
    final response = await _client.post('${ApiConstants.login}/google',
        data: {'access_token': accessToken});
    return response.data;
  }

  Future<dynamic> loginWithFacebook(String accessToken) async {
    final response = await _client.post('${ApiConstants.login}/facebook',
        data: {'access_token': accessToken});
    return response.data;
  }

  Future<void> resetPassword(String email) async {
    await _client.post(ApiConstants.authReset, data: {'email': email});
  }

  Future<dynamic> getSession() async {
    final response = await _client.get(ApiConstants.session);
    return response.data;
  }

  // --- USERS ---
  Future<List<dynamic>> getRoles() async {
    final response = await _client.get('${ApiConstants.users}/roles');
    return response.data;
  }

  Future<Map<String, dynamic>> getFavorites({int? page, int? limit}) async {
    final response =
        await _client.get(ApiConstants.userFavorites, queryParameters: {
      if (page != null) 'page': page,
      if (limit != null) 'limit': limit,
    });
    return response.data;
  }

  Future<dynamic> addFavorite(int professionalId) async {
    final response = await _client.post(ApiConstants.userFavorites,
        data: {'professionalId': professionalId});
    return response.data;
  }

  Future<void> removeFavorite(int professionalId) async {
    await _client.delete('${ApiConstants.userFavorites}/$professionalId');
  }

  // --- PROFESSIONALS ---
  Future<List<ProfessionalModel>> getProfessionals({int? limit}) async {
    final response = await _client.get(ApiConstants.professionals,
        queryParameters: limit != null ? {'limit': limit} : null);
    return (response.data as List)
        .map((e) => ProfessionalModel.fromJson(e))
        .toList();
  }

  Future<ProfessionalModel?> getMyProfessionalProfile() async {
    final response = await _client.get(ApiConstants.professionalMe);
    if (response.data == null) return null;
    return ProfessionalModel.fromJson(response.data);
  }

  Future<ProfessionalModel> getProfessionalById(int id) async {
    final response = await _client.get('${ApiConstants.professionals}/$id');
    return ProfessionalModel.fromJson(response.data);
  }

  // --- ARCA ---
  Future<ArcaModel> verifyCuit(String cuit) async {
    final response = await _client.get('${ApiConstants.arca}/verify/$cuit');
    return ArcaModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ArcaModel> getArcaCompany(int companyId) async {
    final response =
        await _client.get('${ApiConstants.arca}/company/$companyId');
    return ArcaModel.fromJson(response.data as Map<String, dynamic>);
  }

  // --- ADDRESSES ---
  Future<List<AddressModel>> getAddresses() async {
    final response = await _client.get(ApiConstants.addresses);
    return (response.data as List)
        .map((e) => AddressModel.fromJson(e))
        .toList();
  }

  Future<List<AddressModel>> getMyAddresses() async {
    final response = await _client.get('${ApiConstants.addresses}/my');
    return (response.data as List)
        .map((e) => AddressModel.fromJson(e))
        .toList();
  }

  Future<List<AddressModel>> getProfessionalAddresses(
      int professionalId) async {
    final response = await _client
        .get('${ApiConstants.addresses}/professional/$professionalId');
    return (response.data as List)
        .map((e) => AddressModel.fromJson(e))
        .toList();
  }

  Future<AddressModel> createAddress(Map<String, dynamic> addressData) async {
    final response =
        await _client.post(ApiConstants.addresses, data: addressData);
    return AddressModel.fromJson(response.data);
  }

  Future<AddressModel> updateAddress(
      int id, Map<String, dynamic> addressData) async {
    final response =
        await _client.put('${ApiConstants.addresses}/$id', data: addressData);
    return AddressModel.fromJson(response.data);
  }

  // --- COMMUNICATIONS ---
  Future<List<dynamic>> getUserContactRequests(String userId) async {
    final response = await _client
        .get('${ApiConstants.communications}/requests/user/$userId');
    return response.data;
  }

  Future<List<dynamic>> getProfessionalContactRequests(
      int professionalId) async {
    final response = await _client.get(
        '${ApiConstants.communications}/requests/professional/$professionalId');
    return response.data;
  }

  Future<List<dynamic>> getRequestMessages(int requestId) async {
    final response = await _client
        .get('${ApiConstants.communications}/requests/$requestId/messages');
    return response.data;
  }

  Future<dynamic> createContactRequest(Map<String, dynamic> data) async {
    final response = await _client
        .post('${ApiConstants.communications}/contact-request', data: data);
    return response.data;
  }

  // --- PROFESSIONAL DETAILS ---
  Future<List<dynamic>> getProfessionalCategories(int professionalId) async {
    final response = await _client
        .get('${ApiConstants.professionalDetails}/$professionalId/categories');
    return response.data;
  }

  Future<List<dynamic>> getProfessionalCredentials(int professionalId) async {
    final response = await _client
        .get('${ApiConstants.professionalDetails}/$professionalId/credentials');
    return response.data;
  }

  Future<List<dynamic>> getProfessionalSchedules(int professionalId) async {
    final response = await _client
        .get('${ApiConstants.professionalDetails}/$professionalId/schedules');
    return response.data;
  }

  // --- PRODUCTS ---
  Future<List<ProductModel>> getProducts({int? page, int? limit}) async {
    final response = await _client.get(ApiConstants.products, queryParameters: {
      if (page != null) 'page': page,
      if (limit != null) 'limit': limit,
    });
    return (response.data['data'] as List)
        .map((e) => ProductModel.fromJson(e))
        .toList();
  }

  Future<List<ProductModel>> getProductsByName(String name) async {
    final response = await _client.get('${ApiConstants.products}/name/$name');
    return (response.data as List)
        .map((e) => ProductModel.fromJson(e))
        .toList();
  }

  Future<List<ProductModel>> getProductsByCategory(int categoryId) async {
    final response =
        await _client.get('${ApiConstants.products}/category/$categoryId');
    return (response.data as List)
        .map((e) => ProductModel.fromJson(e))
        .toList();
  }

  Future<List<dynamic>> getProfessionalProducts(int professionalId) async {
    final response = await _client
        .get('${ApiConstants.products}/professional/$professionalId');
    return response.data;
  }

  Future<List<ProductModel>> getProfessionalOnlyProducts(
      int professionalId) async {
    final response = await _client.get(
        '${ApiConstants.products}/professional/$professionalId/only-products');
    return (response.data as List)
        .map((e) => ProductModel.fromJson(e))
        .toList();
  }

  Future<ProductModel> getProductById(int id) async {
    final response = await _client.get('${ApiConstants.products}/$id');
    return ProductModel.fromJson(response.data);
  }

  Future<ProductModel> createProduct(Map<String, dynamic> productData) async {
    final response =
        await _client.post(ApiConstants.products, data: productData);
    return ProductModel.fromJson(response.data);
  }

  Future<ProductModel> updateProduct(
      int id, Map<String, dynamic> productData) async {
    final response =
        await _client.put('${ApiConstants.products}/$id', data: productData);
    return ProductModel.fromJson(response.data);
  }

  Future<dynamic> updateProfessionalProductPrice(
      int professionalId, int productId, dynamic data) async {
    final response = await _client.put(
        '${ApiConstants.products}/professional/$professionalId/product/$productId',
        data: data);
    return response.data;
  }

  Future<void> updatePrices(Map<String, dynamic> data) async {
    await _client.put('${ApiConstants.products}/update-prices', data: data);
  }

  Future<void> massUpdatePrices(Map<String, dynamic> data) async {
    await _client.put('${ApiConstants.products}/mass-update-prices',
        data: data);
  }

  Future<dynamic> assignProductToProfessional(Map<String, dynamic> data) async {
    final response = await _client
        .post('${ApiConstants.products}/assign-professional', data: data);
    return response.data;
  }

  Future<void> deleteProfessionalProduct(
      int productId, int professionalId) async {
    await _client.delete(
        '${ApiConstants.products}/$productId/professional/$professionalId');
  }

  // --- PROVINCES & DEPARTMENTS ---
  Future<List<dynamic>> getProvinces() async {
    final response = await _client.get(ApiConstants.provinces);
    return response.data;
  }

  Future<dynamic> getProvinceById(int id) async {
    final response = await _client.get('${ApiConstants.provinces}/$id');
    return response.data;
  }

  Future<List<dynamic>> getProvinceDepartments({int? provinceId}) async {
    final String path = provinceId != null
        ? '${ApiConstants.provinceDepartments}/province/$provinceId'
        : ApiConstants.provinceDepartments;
    final response = await _client.get(path);
    return response.data;
  }

  Future<dynamic> getProvinceDepartmentById(int id) async {
    final response =
        await _client.get('${ApiConstants.provinceDepartments}/$id');
    return response.data;
  }

  // --- SERVICES ---
  Future<List<ServiceModel>> getServices(
      {String? name, int? categoryId}) async {
    final response = await _client.get(ApiConstants.services, queryParameters: {
      if (name != null) 'name': name,
      if (categoryId != null) 'categoryId': categoryId,
    });
    return (response.data as List)
        .map((e) => ServiceModel.fromJson(e))
        .toList();
  }

  Future<ServiceModel> getServiceById(int id) async {
    final response = await _client.get('${ApiConstants.services}/$id');
    return ServiceModel.fromJson(response.data);
  }

  Future<List<ServiceModel>> getProfessionalServices(int professionalId) async {
    final response = await _client
        .get('${ApiConstants.services}/professional/$professionalId');
    return (response.data as List)
        .map((e) => ServiceModel.fromJson(e))
        .toList();
  }

  Future<ServiceModel> createService(Map<String, dynamic> serviceData) async {
    final response =
        await _client.post(ApiConstants.services, data: serviceData);
    return ServiceModel.fromJson(response.data);
  }

  Future<ServiceModel> updateService(
      int id, Map<String, dynamic> serviceData) async {
    final response =
        await _client.put('${ApiConstants.services}/$id', data: serviceData);
    return ServiceModel.fromJson(response.data);
  }

  Future<void> deleteService(int id) async {
    await _client.delete('${ApiConstants.services}/$id');
  }

  // --- CATEGORIES ---
  Future<List<dynamic>> getProductCategories() async {
    final response = await _client.get(ApiConstants.categoriesProducts);
    return response.data;
  }

  Future<List<dynamic>> getServiceCategories() async {
    final response = await _client.get(ApiConstants.categoriesServices);
    return response.data;
  }

  // --- SUBSCRIPTION ---
  Future<List<dynamic>> getSubscriptionPrices() async {
    final response = await _client.get(ApiConstants.subscriptionPrice);
    return response.data;
  }

  // --- COMPANIES ---
  Future<List<dynamic>> getCompanies() async {
    final response = await _client.get(ApiConstants.companies);
    return response.data;
  }

  Future<dynamic> getCompanyById(int id) async {
    final response = await _client.get('${ApiConstants.companies}/$id');
    return response.data;
  }

  Future<dynamic> createCompany(Map<String, dynamic> companyData) async {
    final response =
        await _client.post(ApiConstants.companies, data: companyData);
    return response.data;
  }

  Future<dynamic> updateCompany(
      int id, Map<String, dynamic> companyData) async {
    final response =
        await _client.put('${ApiConstants.companies}/$id', data: companyData);
    return response.data;
  }

  // --- AVAILABILITY ---
  Future<List<dynamic>> getProfessionalAvailability(int professionalId) async {
    final response = await _client.get(
        '${ApiConstants.professionalAvailability}/professional/$professionalId');
    return response.data;
  }

  Future<List<dynamic>> bulkCreateAvailability(
      Map<String, dynamic> data) async {
    final response = await _client
        .post('${ApiConstants.professionalAvailability}/bulk', data: data);
    return response.data;
  }

  // --- RANKING ---
  Future<List<dynamic>> getProfessionalRanking(
      {int? categoryId, int? limit}) async {
    final response =
        await _client.get(ApiConstants.professionalRanking, queryParameters: {
      if (categoryId != null) 'categoryId': categoryId.toString(),
      if (limit != null) 'limit': limit.toString(),
    });
    return response.data;
  }

  // --- REVIEWS ---
  Future<List<ReviewModel>> getProfessionalReviews(int professionalId) async {
    final response = await _client
        .get('${ApiConstants.reviews}/professional/$professionalId');
    return (response.data as List).map((e) => ReviewModel.fromJson(e)).toList();
  }

  Future<ReviewModel> createReview(Map<String, dynamic> reviewData) async {
    final response = await _client.post(ApiConstants.reviews, data: reviewData);
    return ReviewModel.fromJson(response.data);
  }

  // --- PROPOSALS ---
  Future<ProfessionalProposalModel> createProposal(
      Map<String, dynamic> data) async {
    final response =
        await _client.post(ApiConstants.professionalProposals, data: data);
    return ProfessionalProposalModel.fromJson(response.data);
  }

  Future<List<ProfessionalProposalModel>> getReceivedProposals() async {
    final response =
        await _client.get('${ApiConstants.professionalProposals}/received');
    return (response.data as List)
        .map((e) => ProfessionalProposalModel.fromJson(e))
        .toList();
  }

  Future<List<ProfessionalProposalModel>> getSentProposals() async {
    final response =
        await _client.get('${ApiConstants.professionalProposals}/sent');
    return (response.data as List)
        .map((e) => ProfessionalProposalModel.fromJson(e))
        .toList();
  }

  Future<ProfessionalProposalModel> getProposalById(String id) async {
    final response =
        await _client.get('${ApiConstants.professionalProposals}/$id');
    return ProfessionalProposalModel.fromJson(response.data);
  }

  Future<ProfessionalProposalModel> acceptProposal(String id) async {
    final response =
        await _client.post('${ApiConstants.professionalProposals}/$id/accept');
    return ProfessionalProposalModel.fromJson(response.data);
  }
}
