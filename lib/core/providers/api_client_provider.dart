import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../network/api_client.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  final client = ApiClient();
  // Prefer --dart-define value, fallback to .env
  const envKey = String.fromEnvironment('WEB_API_KEY_SECRET', defaultValue: '');
  final apiKey = envKey.isNotEmpty
      ? envKey
      : (dotenv.env['WEB_API_KEY_SECRET'] ?? dotenv.env['WEB_API_KEY'] ?? '');
  if (apiKey.isNotEmpty) client.setApiKey(apiKey);
  return client;
});
