import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../network/api_client.dart';
import '../../providers/api_client_provider.dart';
import '../../services/api_constants.dart';

class ReelsRepository {
  final ApiClient _client;
  ReelsRepository(this._client);

  Future<dynamic> create(dynamic body) async =>
      (await _client.post(ApiConstants.professionalReels, data: body)).data;
  Future<dynamic> findAll({Map<String, dynamic>? query}) async => (await _client
          .get(ApiConstants.professionalReels, queryParameters: query))
      .data;
  Future<
      dynamic> countViewsAndLikes(int professionalId) async => (await _client.get(
          '${ApiConstants.professionalReels}/professional/$professionalId/stats'))
      .data;
  Future<dynamic> findById(String id) async =>
      (await _client.get('${ApiConstants.professionalReels}/$id')).data;
  Future<dynamic> updateStats(String id, dynamic body) async => (await _client
          .put('${ApiConstants.professionalReels}/$id/stats', data: body))
      .data;
  Future<dynamic> delete(String id) async =>
      (await _client.delete('${ApiConstants.professionalReels}/$id')).data;
}

final reelsRepositoryProvider = Provider<ReelsRepository>((ref) {
  return ReelsRepository(ref.read(apiClientProvider));
});
