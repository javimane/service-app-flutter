import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../network/api_client.dart';
import '../../providers/api_client_provider.dart';
import '../../services/api_constants.dart';
import '../models/companies.model.dart';

class CompaniesRepository {
  final ApiClient _client;
  CompaniesRepository(this._client);

  Future<List<Company>> findAll() async {
    final res = (await _client.get(ApiConstants.companies)).data;
    return companiesFromResponse(res);
  }

  Future<Company?> findById(int id) async {
    final res = (await _client.get('${ApiConstants.companies}/$id')).data;
    if (res == null) {
      return null;
    }
    if (res is Map<String, dynamic>) {
      return Company.fromJson(res);
    }
    if (res is Map && res['data'] is Map) {
      return Company.fromJson(res['data'] as Map<String, dynamic>);
    }
    return null;
  }

  Future<List<Company>> findByProfessionalId(int id) async {
    final res =
        (await _client.get('${ApiConstants.companies}/professional/$id')).data;
    return companiesFromResponse(res);
  }

  Future<Company> create(dynamic body) async {
    final res = (await _client.post(ApiConstants.companies, data: body)).data;
    return Company.fromJson(res as Map<String, dynamic>);
  }

  Future<Company> update(int id, dynamic body) async {
    final res =
        (await _client.put('${ApiConstants.companies}/$id', data: body)).data;
    return Company.fromJson(res as Map<String, dynamic>);
  }
}

final companiesRepositoryProvider = Provider<CompaniesRepository>((ref) {
  return CompaniesRepository(ref.read(apiClientProvider));
});
