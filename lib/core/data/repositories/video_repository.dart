import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../network/api_client.dart';
import '../../providers/api_client_provider.dart';
import '../../services/api_constants.dart';

class VideoRepository {
  final ApiClient _client;
  VideoRepository(this._client);

  Future<dynamic> getUploadUrl(dynamic body) async =>
      (await _client.post('${ApiConstants.videos}/upload-url', data: body))
          .data;
}

final videoRepositoryProvider = Provider<VideoRepository>((ref) {
  return VideoRepository(ref.read(apiClientProvider));
});
