import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../network/api_client.dart';
import '../../providers/api_client_provider.dart';
import '../../services/api_constants.dart';

class ProfessionalPromotionsRepository {
  final ApiClient _client;
  ProfessionalPromotionsRepository(this._client);

  Future<dynamic> findAllPublic({Map<String, dynamic>? query}) async =>
      (await _client.get(ApiConstants.professionalPromotions,
              queryParameters: query))
          .data;
  Future<dynamic> findByProfessionalId(int professionalId) async =>
      (await _client.get(
              '${ApiConstants.professionalPromotions}/professional/$professionalId'))
          .data;
  Future<dynamic> getById(String id) async =>
      (await _client.get('${ApiConstants.professionalPromotions}/$id')).data;
  Future<dynamic> create(dynamic body) async =>
      (await _client.post(ApiConstants.professionalPromotions, data: body))
          .data;
  Future<dynamic> update(String id, dynamic body) async => (await _client
          .put('${ApiConstants.professionalPromotions}/$id', data: body))
      .data;
  Future<dynamic> delete(String id) async =>
      (await _client.delete('${ApiConstants.professionalPromotions}/$id')).data;
}

final professionalPromotionsRepositoryProvider =
    Provider<ProfessionalPromotionsRepository>((ref) {
  return ProfessionalPromotionsRepository(ref.read(apiClientProvider));
});
