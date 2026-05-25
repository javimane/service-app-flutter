import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../network/api_client.dart';
import '../../providers/api_client_provider.dart';
import '../../services/api_constants.dart';
import '../models/professional_model.dart';

class ProfessionalsRepository {
  final ApiClient _client;

  ProfessionalsRepository(this._client);

  Future<List<ProfessionalModel>> getProfessionals({
    int? limit,
    int? categoryId,
    int? provinceId,
    int? departmentId,
    String? query,
    double? lat,
    double? lng,
    int? radius,
    bool? publicTrade,
    String? isMatriculate,
    String? isVerified,
    String? emergency,
    String? specialty,
  }) async {
    final queryParameters = <String, dynamic>{
      if (limit != null) 'limit': limit.toString(),
      if (categoryId != null) 'categoryId': categoryId.toString(),
      if (provinceId != null) 'province_id': provinceId.toString(),
      if (departmentId != null) 'department_id': departmentId.toString(),
      if (query != null && query.isNotEmpty) 'name': query,
      if (lat != null) 'lat': lat.toString(),
      if (lng != null) 'lng': lng.toString(),
      if (radius != null) 'radius': radius.toString(),
      if (publicTrade != null) 'public_trade': publicTrade.toString(),
      if (isMatriculate != null) 'is_matriculate': isMatriculate,
      if (isVerified != null) 'isVerified': isVerified,
      if (emergency != null) 'emergency': emergency,
      if (specialty != null) 'specialty': specialty,
    };

    final response = await _client.get(
      ApiConstants.professionals,
      queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
    );
    final data = response.data as List<dynamic>;
    return data
        .map((e) => ProfessionalModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ProfessionalModel?> getProfessionalById(int id) async {
    final response = await _client.get('${ApiConstants.professionals}/$id');
    if (response.data == null) return null;
    return ProfessionalModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ProfessionalModel?> getMyProfessional() async {
    final response = await _client.get(ApiConstants.professionalMe);
    if (response.data == null) return null;
    return ProfessionalModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<Map<String, dynamic>>> getProfessionalRanking(
      {int? categoryId, int? limit}) async {
    final response = await _client.get(
      ApiConstants.professionalRanking,
      queryParameters: {
        if (categoryId != null) 'categoryId': categoryId.toString(),
        if (limit != null) 'limit': limit.toString(),
      },
    );
    final data = response.data as List<dynamic>;
    return data.map((e) => e as Map<String, dynamic>).toList();
  }

  Future<Map<String, dynamic>?> getProfessionalDetail(int id) async {
    final response = await _client.get('${ApiConstants.professionals}/$id');
    return response.data as Map<String, dynamic>?;
  }
}

final professionalsRepositoryProvider =
    Provider<ProfessionalsRepository>((ref) {
  return ProfessionalsRepository(ref.read(apiClientProvider));
});

final professionalsProvider =
    FutureProvider<List<ProfessionalModel>>((ref) async {
  return ref.read(professionalsRepositoryProvider).getProfessionals(limit: 20);
});

final professionalRankingProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref
      .read(professionalsRepositoryProvider)
      .getProfessionalRanking(limit: 10);
});
