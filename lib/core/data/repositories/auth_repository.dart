import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../network/api_client.dart';
import '../../providers/api_client_provider.dart';
import '../../services/api_constants.dart';

class AuthRepository {
  final ApiClient _client;
  AuthRepository(this._client);

  Future<Map<String, dynamic>> register(String email, String password) async {
    final resp = await _client.post(ApiConstants.register, data: {
      'email': email,
      'password': password,
    });
    return resp.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> registerManual(
      String userId, String email, String password) async {
    final resp = await _client.post('${ApiConstants.register}-manual', data: {
      'userId': userId,
      'email': email,
      'password': password,
    });
    return resp.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final resp = await _client.post(ApiConstants.login, data: {
      'email': email,
      'password': password,
    });
    return resp.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> loginGoogle(String accessToken) async {
    final resp = await _client.post('${ApiConstants.login}/google', data: {
      'access_token': accessToken,
    });
    return resp.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> resetPassword(String email) async {
    final resp =
        await _client.post(ApiConstants.authReset, data: {'email': email});
    return resp.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getSession() async {
    final resp = await _client.get(ApiConstants.session);
    return resp.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateEmail(String email) async {
    final resp = await _client
        .put('${ApiConstants.session}/update-email', data: {'email': email});
    return resp.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updatePassword(String password) async {
    final resp = await _client.put('${ApiConstants.session}/update-password',
        data: {'password': password});
    return resp.data as Map<String, dynamic>;
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read(apiClientProvider));
});
