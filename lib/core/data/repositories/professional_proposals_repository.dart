import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../network/api_client.dart';
import '../../providers/api_client_provider.dart';
import '../../services/api_constants.dart';

class ProfessionalProposalsRepository {
  final ApiClient _client;
  ProfessionalProposalsRepository(this._client);

  Future<dynamic> create(dynamic body) async =>
      (await _client.post(ApiConstants.professionalProposals, data: body)).data;
  Future<dynamic> getReceived() async =>
      (await _client.get('${ApiConstants.professionalProposals}/received'))
          .data;
  Future<dynamic> getSent() async =>
      (await _client.get('${ApiConstants.professionalProposals}/sent')).data;
  Future<dynamic> getAcceptedCount() async => (await _client
          .get('${ApiConstants.professionalProposals}/accepted/count'))
      .data;
  Future<dynamic> getById(String id) async =>
      (await _client.get('${ApiConstants.professionalProposals}/$id')).data;
  Future<dynamic> accept(String id) async =>
      (await _client.post('${ApiConstants.professionalProposals}/$id/accept'))
          .data;
}

final professionalProposalsRepositoryProvider =
    Provider<ProfessionalProposalsRepository>((ref) {
  return ProfessionalProposalsRepository(ref.read(apiClientProvider));
});
