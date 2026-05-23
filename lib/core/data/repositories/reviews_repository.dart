import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../network/api_client.dart';
import '../../providers/api_client_provider.dart';
import '../../services/api_constants.dart';
import '../models/misc_models.dart';

class ReviewsRepository {
  final ApiClient _client;

  ReviewsRepository(this._client);

  Future<List<ReviewModel>> getReviewsByProfessional(int professionalId) async {
    final response = await _client
        .get('${ApiConstants.reviews}/professional/$professionalId');
    final data = response.data as List<dynamic>;
    return data
        .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> createReview({
    required int professionalId,
    required double rating,
    String? comment,
  }) async {
    await _client.post(ApiConstants.reviews, data: {
      'professional_id': professionalId,
      'rating': rating,
      if (comment != null) 'comment': comment,
    });
  }
}

final reviewsRepositoryProvider = Provider<ReviewsRepository>((ref) {
  return ReviewsRepository(ref.read(apiClientProvider));
});
