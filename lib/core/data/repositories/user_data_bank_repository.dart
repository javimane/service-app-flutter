import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../network/api_client.dart';
import '../../providers/api_client_provider.dart';
import '../../services/api_constants.dart';

class UserDataBankRepository {
  final ApiClient _client;
  UserDataBankRepository(this._client);

  Future<dynamic> findMy() async =>
      (await _client.get('${ApiConstants.userDataBank}/my')).data;
  Future<dynamic> create(dynamic body) async =>
      (await _client.post(ApiConstants.userDataBank, data: body)).data;
  Future<dynamic> update(String userId, dynamic body) async =>
      (await _client.put('${ApiConstants.userDataBank}/$userId', data: body))
          .data;
  Future<void> remove(String userId) async =>
      await _client.delete('${ApiConstants.userDataBank}/$userId');
}

final userDataBankRepositoryProvider = Provider<UserDataBankRepository>((ref) {
  return UserDataBankRepository(ref.read(apiClientProvider));
});
