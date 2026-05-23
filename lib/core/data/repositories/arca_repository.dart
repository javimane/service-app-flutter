import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../network/api_client.dart';
import '../../providers/api_client_provider.dart';
import '../../services/api_constants.dart';
import '../models/arca.model.dart';

class ArcaRepository {
  final ApiClient _client;
  ArcaRepository(this._client);

  Future<ArcaModel> verifyCuit(
      String cuit, String companyName, int professionalId) async {
    final res = (await _client.get(
            '${ApiConstants.arca}/verify/$cuit/$companyName/$professionalId'))
        .data;
    return ArcaModel.fromJson(res as Map<String, dynamic>);
  }

  Future<ArcaModel> getCompanyRecord(int companyId) async {
    final res =
        (await _client.get('${ApiConstants.arca}/company/$companyId')).data;
    return ArcaModel.fromJson(res as Map<String, dynamic>);
  }
}

final arcaRepositoryProvider = Provider<ArcaRepository>((ref) {
  return ArcaRepository(ref.read(apiClientProvider));
});
