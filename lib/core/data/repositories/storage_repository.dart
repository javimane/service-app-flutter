import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../network/api_client.dart';
import '../../providers/api_client_provider.dart';
import '../../services/api_constants.dart';

class StorageRepository {
  final ApiClient _client;
  StorageRepository(this._client);

  Future<dynamic> getProductImagesConfig() async =>
      (await _client.get('${ApiConstants.storage}/products')).data;
  Future<dynamic> getProfileConfig() async =>
      (await _client.get('${ApiConstants.storage}/profile')).data;
  Future<dynamic> getPortfolioConfig() async =>
      (await _client.get('${ApiConstants.storage}/portfolio')).data;
  Future<dynamic> getProposalsConfig() async =>
      (await _client.get('${ApiConstants.storage}/proposals')).data;
  Future<dynamic> getPromotionsConfig() async =>
      (await _client.get('${ApiConstants.storage}/promotions')).data;
  Future<dynamic> getReviewsConfig() async =>
      (await _client.get('${ApiConstants.storage}/reviews')).data;
  Future<dynamic> getChatConfig(String fileName) async =>
      (await _client.get('${ApiConstants.storage}/chat',
              queryParameters: {'fileName': fileName}))
          .data;
  Future<dynamic> getChatViewUrl(String path) async =>
      (await _client.get('${ApiConstants.storage}/chat/view-url',
              queryParameters: {'path': path}))
          .data;
  Future<dynamic> getProposalsViewUrl(String path) async =>
      (await _client.get('${ApiConstants.storage}/proposals/view-url',
              queryParameters: {'path': path}))
          .data;
}

final storageRepositoryProvider = Provider<StorageRepository>((ref) {
  return StorageRepository(ref.read(apiClientProvider));
});
