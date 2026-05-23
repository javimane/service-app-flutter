import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../network/api_client.dart';
import '../../providers/api_client_provider.dart';
import '../../services/api_constants.dart';

class SubscriptionRepository {
  final ApiClient _client;

  SubscriptionRepository(this._client);

  Future<List<Map<String, dynamic>>> getSubscriptionPlans() async {
    final response = await _client.get(ApiConstants.subscriptionPrice);
    final data = response.data as List<dynamic>;
    return data.map((e) => e as Map<String, dynamic>).toList();
  }
}

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  return SubscriptionRepository(ref.read(apiClientProvider));
});

final subscriptionPlansProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref.read(subscriptionRepositoryProvider).getSubscriptionPlans();
});
