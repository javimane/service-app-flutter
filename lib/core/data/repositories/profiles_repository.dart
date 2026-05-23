import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../network/api_client.dart';
import '../../providers/api_client_provider.dart';
import '../../services/api_constants.dart';

class ProfilesRepository {
  final ApiClient _client;
  ProfilesRepository(this._client);

  Future<dynamic> findById(String id) async =>
      (await _client.get('${ApiConstants.profiles}/$id')).data;
  Future<dynamic> update(String id, dynamic body) async =>
      (await _client.put('${ApiConstants.profiles}/$id', data: body)).data;
}

final profilesRepositoryProvider = Provider<ProfilesRepository>((ref) {
  return ProfilesRepository(ref.read(apiClientProvider));
});
