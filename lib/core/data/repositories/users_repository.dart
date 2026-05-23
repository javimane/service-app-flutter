import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../network/api_client.dart';
import '../../providers/api_client_provider.dart';
import '../../services/api_constants.dart';

class UsersRepository {
  final ApiClient _client;
  UsersRepository(this._client);

  Future<dynamic> getRoles() async =>
      (await _client.get('${ApiConstants.users}/roles')).data;
  Future<dynamic> getMyFavorites({int? page, int? limit}) async =>
      (await _client.get(ApiConstants.userFavorites, queryParameters: {
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
      }))
          .data;
  Future<dynamic> addFavorite(int professionalId) async =>
      (await _client.post(ApiConstants.userFavorites,
              data: {'professionalId': professionalId}))
          .data;
  Future<void> removeFavorite(int professionalId) async =>
      await _client.delete('${ApiConstants.userFavorites}/$professionalId');
  Future<dynamic> registerDeviceToken(String token, {String? platform}) async =>
      (await _client.post('${ApiConstants.users}/me/device-tokens', data: {
        'token': token,
        if (platform != null) 'platform': platform
      }))
          .data;
  Future<void> removeDeviceToken(String token) async => await _client
      .delete('${ApiConstants.users}/me/device-tokens', data: {'token': token});
}

final usersRepositoryProvider = Provider<UsersRepository>((ref) {
  return UsersRepository(ref.read(apiClientProvider));
});
