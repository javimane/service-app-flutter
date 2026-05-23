import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../network/api_client.dart';
import '../../providers/api_client_provider.dart';
import '../../services/api_constants.dart';

class BankRepository {
  final ApiClient client;
  BankRepository(this.client);

  Future<dynamic> findAll({int? queryId}) async =>
      (await client.get(ApiConstants.banks,
              queryParameters: queryId != null ? {'id': queryId} : null))
          .data;
  Future<dynamic> getById(int id) async =>
      (await client.get('${ApiConstants.banks}/$id')).data;
}

final bankRepositoryProvider = Provider<BankRepository>((ref) {
  return BankRepository(ref.read(apiClientProvider));
});
