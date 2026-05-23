import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../network/api_client.dart';
import '../../providers/api_client_provider.dart';
import '../../services/api_constants.dart';

class ProfessionalImagesRepository {
  final ApiClient _client;
  ProfessionalImagesRepository(this._client);

  Future<dynamic> findAllByProfessionalId(int professionalId) async =>
      (await _client.get(
              '${ApiConstants.professionalImages}/professional/$professionalId'))
          .data;
  Future<dynamic> findById(String id) async =>
      (await _client.get('${ApiConstants.professionalImages}/$id')).data;
  Future<dynamic> create(dynamic body) async =>
      (await _client.post(ApiConstants.professionalImages, data: body)).data;
  Future<dynamic> delete(String id) async =>
      (await _client.delete('${ApiConstants.professionalImages}/$id')).data;
}

final professionalImagesRepositoryProvider =
    Provider<ProfessionalImagesRepository>((ref) {
  return ProfessionalImagesRepository(ref.read(apiClientProvider));
});
