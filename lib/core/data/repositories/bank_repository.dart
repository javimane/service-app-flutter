import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../network/api_client.dart';
import '../../providers/api_client_provider.dart';
import '../../services/api_constants.dart';
import '../models/bank_promotions.model.dart';

class BankRepository {
  final ApiClient client;
  BankRepository(this.client);

  Future<List<BankModel>> findAll({int? queryId}) async {
    final res = (await client.get(ApiConstants.banks,
            queryParameters: queryId != null ? {'id': queryId} : null))
        .data;
    return (res as List).map((e) => BankModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<BankModel> getById(int id) async {
    final res = (await client.get('${ApiConstants.banks}/$id')).data;
    return BankModel.fromJson(res as Map<String, dynamic>);
  }
}

final bankRepositoryProvider = Provider<BankRepository>((ref) {
  return BankRepository(ref.read(apiClientProvider));
});
