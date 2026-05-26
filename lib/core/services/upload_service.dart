import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UploadService {
  final Dio _dio;

  UploadService(this._dio);

  Future<void> uploadToPresignedUrl({
    required String uploadUrl,
    required File file,
  }) async {
    try {
      final response = await _dio.put(
        uploadUrl,
        data: file.openRead(),
        options: Options(
          headers: {
            Headers.contentLengthHeader: file.lengthSync(),
            // The content type will be inferred or left blank, usually S3 or Supabase Storage accepts it without strict Content-Type 
            // if we are using presigned URLs and just pushing binary data.
          },
        ),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Error al subir el archivo. Código HTTP: \${response.statusCode}');
      }
    } catch (e) {
      throw Exception('No se pudo subir el archivo: $e');
    }
  }
}

// Global provider for the upload service.
// Notice we use a fresh Dio instance without base url interceptors 
// because presigned URLs point to external hosts (like AWS S3 or Supabase Storage bucket URLs).
final uploadServiceProvider = Provider<UploadService>((ref) {
  return UploadService(Dio());
});
