import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../network/api_client.dart';
import '../../providers/api_client_provider.dart';
import '../../services/api_constants.dart';
import '../models/bank_promotions.model.dart';

class BankPromotionsRepository {
  final ApiClient _client;
  BankPromotionsRepository(this._client);

  Future<List<BankPromotionModel>> findAll(
      {Map<String, dynamic>? query}) async {
    final res =
        (await _client.get(ApiConstants.bankPromotions, queryParameters: query))
            .data;
    return (res as List)
        .map((e) => BankPromotionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<BankPromotionModel>> findMyPromotions() async {
    final res =
        (await _client.get('${ApiConstants.bankPromotions}/my-promotions'))
            .data;
    return (res as List)
        .map((e) => BankPromotionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<BankPromotionModel> getById(String id) async {
    final res = (await _client.get('${ApiConstants.bankPromotions}/$id')).data;
    return BankPromotionModel.fromJson(res as Map<String, dynamic>);
  }

  Future<BankPromotionModel> create(dynamic body) async {
    final res =
        (await _client.post(ApiConstants.bankPromotions, data: body)).data;
    return BankPromotionModel.fromJson(res as Map<String, dynamic>);
  }

  Future<BankPromotionModel> update(String id, dynamic body) async {
    final res =
        (await _client.patch('${ApiConstants.bankPromotions}/$id', data: body))
            .data;
    return BankPromotionModel.fromJson(res as Map<String, dynamic>);
  }

  Future<void> delete(String id) async {
    await _client.delete('${ApiConstants.bankPromotions}/$id');
  }
}

final bankPromotionsRepositoryProvider =
    Provider<BankPromotionsRepository>((ref) {
  return BankPromotionsRepository(ref.read(apiClientProvider));
});
