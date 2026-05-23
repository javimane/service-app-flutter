import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../network/api_client.dart';
import '../../providers/api_client_provider.dart';
import '../../services/api_constants.dart';

class ProvincesRepository {
  final ApiClient _client;
  ProvincesRepository(this._client);

  Future<dynamic> findAll() async =>
      (await _client.get(ApiConstants.provinces)).data;
  Future<dynamic> findById(int id) async =>
      (await _client.get('${ApiConstants.provinces}/$id')).data;
}

final provincesRepositoryProvider = Provider<ProvincesRepository>((ref) {
  return ProvincesRepository(ref.read(apiClientProvider));
});
