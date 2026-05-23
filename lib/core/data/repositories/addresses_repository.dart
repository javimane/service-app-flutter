import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../network/api_client.dart';
import '../../providers/api_client_provider.dart';
import '../../services/api_constants.dart';
import 'package:service_app_flutter/data/models/api_models.dart';

class AddressesRepository {
  final ApiClient _client;
  AddressesRepository(this._client);

  Future<List<AddressModel>> findAllPublic() async {
    final res = (await _client.get(ApiConstants.addresses)).data;
    return (res as List)
        .map((e) => AddressModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<AddressModel>> findMyAddresses() async {
    final res = (await _client.get('${ApiConstants.addresses}/my')).data;
    return (res as List)
        .map((e) => AddressModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<AddressModel>> getProfessionalAddresses(
      int professionalId) async {
    final res = (await _client
            .get('${ApiConstants.addresses}/professional/$professionalId'))
        .data;
    return (res as List)
        .map((e) => AddressModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<AddressModel> create(dynamic body) async {
    final res = (await _client.post(ApiConstants.addresses, data: body)).data;
    return AddressModel.fromJson(res as Map<String, dynamic>);
  }

  Future<AddressModel> update(int id, dynamic body) async {
    final res =
        (await _client.put('${ApiConstants.addresses}/$id', data: body)).data;
    return AddressModel.fromJson(res as Map<String, dynamic>);
  }
}

final addressesRepositoryProvider = Provider<AddressesRepository>((ref) {
  return AddressesRepository(ref.read(apiClientProvider));
});
