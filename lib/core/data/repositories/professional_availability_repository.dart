import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../network/api_client.dart';
import '../../providers/api_client_provider.dart';
import '../../services/api_constants.dart';

class ProfessionalAvailabilityRepository {
  final ApiClient _client;
  ProfessionalAvailabilityRepository(this._client);

  Future<dynamic> findByProfessionalId(int professionalId) async =>
      (await _client.get(
              '${ApiConstants.professionalAvailability}/professional/$professionalId'))
          .data;
  Future<dynamic> upsertBulk(dynamic body) async => (await _client
          .post('${ApiConstants.professionalAvailability}/bulk', data: body))
      .data;
  Future<dynamic> update(String id, dynamic body) async => (await _client
          .put('${ApiConstants.professionalAvailability}/$id', data: body))
      .data;
  Future<void> delete(String id) async =>
      await _client.delete('${ApiConstants.professionalAvailability}/$id');
}

final professionalAvailabilityRepositoryProvider =
    Provider<ProfessionalAvailabilityRepository>((ref) {
  return ProfessionalAvailabilityRepository(ref.read(apiClientProvider));
});
