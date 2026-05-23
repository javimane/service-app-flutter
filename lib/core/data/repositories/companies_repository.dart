import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../network/api_client.dart';
import '../../providers/api_client_provider.dart';
import '../../services/api_constants.dart';

class CompaniesRepository {
  final ApiClient _client;
  CompaniesRepository(this._client);

  Future<dynamic> findAll() async =>
      (await _client.get(ApiConstants.companies)).data;
  Future<dynamic> findById(int id) async =>
      (await _client.get('${ApiConstants.companies}/$id')).data;
  Future<dynamic> findByProfessionalId(int id) async =>
      (await _client.get('${ApiConstants.companies}/professional/$id')).data;
  Future<dynamic> create(dynamic body) async =>
      (await _client.post(ApiConstants.companies, data: body)).data;
  Future<dynamic> update(int id, dynamic body) async =>
      (await _client.put('${ApiConstants.companies}/$id', data: body)).data;
}

final companiesRepositoryProvider = Provider<CompaniesRepository>((ref) {
  return CompaniesRepository(ref.read(apiClientProvider));
});
