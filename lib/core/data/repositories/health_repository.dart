import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../network/api_client.dart';
import '../../providers/api_client_provider.dart';
import '../../services/api_constants.dart';

class HealthRepository {
  final ApiClient _client;
  HealthRepository(this._client);

  Future<dynamic> getStatus() async =>
      (await _client.get(ApiConstants.health)).data;
}

final healthRepositoryProvider = Provider<HealthRepository>((ref) {
  return HealthRepository(ref.read(apiClientProvider));
});
