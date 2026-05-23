import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../network/api_client.dart';
import '../../providers/api_client_provider.dart';
import '../../services/api_constants.dart';
import '../models/misc_models.dart';

class FavoritesRepository {
  final ApiClient _client;

  FavoritesRepository(this._client);

  Future<List<FavoriteModel>> getFavorites({int page = 1, int limit = 20}) async {
    final response = await _client.get(
      ApiConstants.userFavorites,
      queryParameters: {'page': page.toString(), 'limit': limit.toString()},
    );
    final raw = response.data;
    List<dynamic> data;
    if (raw is Map<String, dynamic>) {
      data = raw['data'] as List<dynamic>? ?? [];
    } else {
      data = raw as List<dynamic>;
    }
    return data.map((e) => FavoriteModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> addFavorite(int professionalId) async {
    await _client.post(ApiConstants.userFavorites, data: {'professionalId': professionalId});
  }

  Future<void> removeFavorite(int professionalId) async {
    await _client.delete('${ApiConstants.userFavorites}/$professionalId');
  }
}

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  return FavoritesRepository(ref.read(apiClientProvider));
});

final favoritesProvider = FutureProvider<List<FavoriteModel>>((ref) async {
  return ref.read(favoritesRepositoryProvider).getFavorites();
});
