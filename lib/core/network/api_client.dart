import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

String _getBaseUrl() {
  if (kIsWeb) return 'http://localhost:3000/api';
  if (Platform.isAndroid) return 'http://10.0.2.2:3000/api';
  if (Platform.isIOS) return 'http://localhost:3000/api';
  // Fallback: replace with your machine IP when testing on a physical device
  return 'http://<TU_IP_LOCAL>:3000/api';
}

class ApiClient {
  late final Dio _dio;
  String? _apiKey;

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl:
          _getBaseUrl(), // Base URL chosen by platform (emulator/device/web)
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add Authorization header if session exists in storage
        const storage = FlutterSecureStorage();
        final sessionString = await storage.read(key: 'auth_session');
        if (sessionString != null) {
          try {
            final sessionMap = jsonDecode(sessionString);
            String? token;
            if (sessionMap['access_token'] != null) {
              token = sessionMap['access_token'];
            } else if (sessionMap['data'] != null && sessionMap['data']['session'] != null) {
              token = sessionMap['data']['session']['access_token'];
            } else if (sessionMap['session'] != null) {
              token = sessionMap['session']['access_token'];
            }

            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          } catch (_) {}
        }
        // Attach API key header if configured and not already provided
        if (_apiKey != null &&
            _apiKey!.isNotEmpty &&
            (options.headers['x-api-key'] == null &&
                options.headers['X-API-KEY'] == null)) {
          options.headers['x-api-key'] = _apiKey!;
        }
        return handler.next(options);
      },
      onError: (DioException error, handler) {
        // Log or handle global errors here
        return handler.next(error);
      },
    ));

    // Add a log interceptor for debug (remove or disable in production)
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
    ));
  }

  Dio get dio => _dio;

  /// Set a global API key that will be added to requests as `x-api-key`.
  void setApiKey(String key) {
    _apiKey = key;
  }

  // Simple GET wrapper
  Future<Response> get(String path,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } catch (e) {
      rethrow;
    }
  }

  // Simple POST wrapper
  Future<Response> post(String path, {dynamic data}) async {
    try {
      return await _dio.post(path, data: data);
    } catch (e) {
      rethrow;
    }
  }

  // Simple PUT wrapper
  Future<Response> put(String path, {dynamic data}) async {
    try {
      return await _dio.put(path, data: data);
    } catch (e) {
      rethrow;
    }
  }

  // Simple DELETE wrapper
  Future<Response> delete(String path, {dynamic data}) async {
    try {
      return await _dio.delete(path, data: data);
    } catch (e) {
      rethrow;
    }
  }

  // ...existing code...
  // Añadir esto dentro de la clase ApiClient
  Future<dynamic> patch(String path,
      {dynamic data,
      Map<String, dynamic>? queryParameters,
      Options? options,
      CancelToken? cancelToken,
      ProgressCallback? onSendProgress,
      ProgressCallback? onReceiveProgress}) async {
    return await _dio.patch(path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress);
  }
// ...existing code...
}
