import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../network/api_client.dart';
import '../../providers/api_client_provider.dart';
import '../../services/api_constants.dart';

class ProfessionalVideosRepository {
  final ApiClient _client;
  ProfessionalVideosRepository(this._client);

  Future<dynamic> findAllByProfessionalId(int professionalId) async =>
      (await _client.get(
              '${ApiConstants.professionalVideos}/professional/$professionalId'))
          .data;
  Future<dynamic> findById(String id) async =>
      (await _client.get('${ApiConstants.professionalVideos}/$id')).data;
  Future<dynamic> create(dynamic body) async =>
      (await _client.post(ApiConstants.professionalVideos, data: body)).data;
  Future<dynamic> update(String id, dynamic body) async =>
      (await _client.put('${ApiConstants.professionalVideos}/$id', data: body))
          .data;
  Future<void> delete(String id) async =>
      await _client.delete('${ApiConstants.professionalVideos}/$id');
  Future<void> incrementLikes(String id) async =>
      await _client.post('${ApiConstants.professionalVideos}/$id/like');
  Future<void> incrementViews(String id) async =>
      await _client.post('${ApiConstants.professionalVideos}/$id/view');
}

final professionalVideosRepositoryProvider =
    Provider<ProfessionalVideosRepository>((ref) {
  return ProfessionalVideosRepository(ref.read(apiClientProvider));
});
