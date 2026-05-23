import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../network/api_client.dart';
import '../../providers/api_client_provider.dart';
import '../../services/api_constants.dart';

class NotificationsRepository {
  final ApiClient _client;
  NotificationsRepository(this._client);

  Future<dynamic> lambdaWebhook(dynamic body) async => (await _client
          .post('${ApiConstants.notifications}/lambda-webhook', data: body))
      .data;
  Future<dynamic> registerPushToken(int professionalId, dynamic body) async =>
      (await _client.post(
              '${ApiConstants.notifications}/professionals/$professionalId/push-token',
              data: body))
          .data;
}

final notificationsRepositoryProvider =
    Provider<NotificationsRepository>((ref) {
  return NotificationsRepository(ref.read(apiClientProvider));
});
