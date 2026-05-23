import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../network/api_client.dart';
import '../../providers/api_client_provider.dart';
import '../../services/api_constants.dart';

class ProvinceDepartmentsRepository {
  final ApiClient _client;
  ProvinceDepartmentsRepository(this._client);

  Future<dynamic> findAll() async =>
      (await _client.get(ApiConstants.provinceDepartments)).data;
  Future<dynamic> findById(int id) async =>
      (await _client.get('${ApiConstants.provinceDepartments}/$id')).data;
  Future<dynamic> findByProvinceId(int provinceId) async => (await _client
          .get('${ApiConstants.provinceDepartments}/province/$provinceId'))
      .data;
}

final provinceDepartmentsRepositoryProvider =
    Provider<ProvinceDepartmentsRepository>((ref) {
  return ProvinceDepartmentsRepository(ref.read(apiClientProvider));
});
