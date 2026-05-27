import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:service_app_flutter/data/services/alert_service.dart';
import 'package:service_app_flutter/core/router/app_router.dart';

String _getBaseUrl() {
  if (kIsWeb) return 'http://localhost:3000/api';
  if (Platform.isAndroid) return 'http://10.0.2.2:3000/api';
  if (Platform.isIOS) return 'http://localhost:3000/api';
  // Fallback: replace with your machine IP when testing on a physical device
  return 'http://<TU_IP_LOCAL>:3000/api';
}

class ApiClient {
  late final Dio _dio;
  late CookieJar _cookieJar = CookieJar();
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

    // Cookie manager to capture/send cookies (access_token / refresh_token)
    _dio.interceptors.add(CookieManager(_cookieJar));

    // Initialize persistent cookie jar in background (will replace memory jar)
    _initPersistCookieJar();

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add Authorization header if session exists in storage
        const storage = FlutterSecureStorage();
        final sessionString = await storage.read(key: 'auth_session');
        if (sessionString != null) {
          try {
            final sessionMap = jsonDecode(sessionString);
            String? token;

            // Busca el token en distintas estructuras posibles
            if (sessionMap['access_token'] != null) {
              token = sessionMap['access_token'];
            } else if (sessionMap['token'] != null) {
              token = sessionMap['token'];
            } else if (sessionMap['data'] != null) {
              if (sessionMap['data']['access_token'] != null) {
                token = sessionMap['data']['access_token'];
              } else if (sessionMap['data']['token'] != null) {
                token = sessionMap['data']['token'];
              } else if (sessionMap['data']['session'] != null) {
                token = sessionMap['data']['session']['access_token'] ??
                    sessionMap['data']['session']['token'];
              }
            }

            if (token == null && sessionMap['session'] != null) {
              token = sessionMap['session']['access_token'] ??
                  sessionMap['session']['token'];
            }

            if (token != null) {
              try {
                token = token.toString().trim();
                // Avoid double 'Bearer ' prefix (accept tokens that already include it)
                final headerValue = token.toLowerCase().startsWith('bearer ')
                    ? token
                    : 'Bearer $token';

                // Log a masked sample for debugging (don't print full token)
                String masked;
                if (token.length > 8) {
                  masked =
                      '${token.substring(0, 4)}...${token.substring(token.length - 4)}';
                } else {
                  masked = '***';
                }
                debugPrint(
                    'ApiClient Interceptor: setting Authorization header, token sample: $masked');

                options.headers['Authorization'] = headerValue;
              } catch (e) {
                debugPrint('ApiClient Interceptor token handling error: $e');
              }
            } else {
              debugPrint(
                  'ApiClient Interceptor: No token found in sessionMap! Keys: ${sessionMap.keys}');
            }
          } catch (e) {
            debugPrint('ApiClient Interceptor error: $e');
          }
        }

        // If no token in secure storage, try to read cookie set by server
        if (sessionString == null) {
          try {
            // Build request URI for cookie lookup
            final base = _dio.options.baseUrl ?? '';
            final path = options.path.startsWith('/')
                ? options.path
                : '/${options.path}';
            final uri = Uri.parse('$base$path');
            List<Cookie> cookiesList = <Cookie>[];
            try {
              // `loadForRequest` may return List<Cookie> or Future<List<Cookie>>
              // Use Future.value to normalize both cases to a Future.
              final raw = await Future.value(_cookieJar.loadForRequest(uri));
              cookiesList = List<Cookie>.from(raw ?? <Cookie>[]);
            } catch (e) {
              debugPrint('ApiClient cookie load error: $e');
            }

            for (final c in cookiesList) {
              if (c.name == 'access_token' && c.value.isNotEmpty) {
                final token = c.value.trim();
                final headerValue = token.toLowerCase().startsWith('bearer ')
                    ? token
                    : 'Bearer $token';
                options.headers['Authorization'] = headerValue;
                debugPrint(
                    'ApiClient: using access_token from cookie (masked)');
                break;
              }
            }
          } catch (e) {
            debugPrint('ApiClient cookie read error: $e');
          }
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
      onError: (DioException error, handler) async {
        // Extract a user-friendly message from the API error and show it
        try {
          String? message;
          final resp = error.response?.data;
          if (resp != null) {
            if (resp is Map && resp['message'] != null) {
              message = resp['message'].toString();
            } else if (resp is String) {
              // Sometimes the response body is a JSON-encoded string
              try {
                final decoded = jsonDecode(resp);
                if (decoded is Map && decoded['message'] != null) {
                  message = decoded['message'].toString();
                } else {
                  message = resp;
                }
              } catch (_) {
                message = resp;
              }
            }
          }

          // Fallback to DioException message
          message ??= error.message;

          // If the server indicates the token is expired, try refresh first
          final lower = message?.toLowerCase() ?? '';
          final isAuthError = lower.contains('expired') ||
              lower.contains('token is expired') ||
              error.response?.statusCode == 401;

          final reqOpts = error.requestOptions;
          final alreadyRetried = reqOpts.extra['retried'] == true;

          if (isAuthError && !alreadyRetried) {
            try {
              // Attempt refresh using a separate Dio instance but shared CookieJar
              final refreshDio = Dio(BaseOptions(
                baseUrl: _dio.options.baseUrl,
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
                headers: {'Content-Type': 'application/json'},
              ));
              refreshDio.interceptors.add(CookieManager(_cookieJar));

              // Call refresh endpoint; server will read cookie or body
              final refreshResp = await refreshDio.post('/auth/refresh');
              if (refreshResp.statusCode == 200) {
                // Retry original request once; onRequest will pick new cookie
                reqOpts.extra['retried'] = true;
                try {
                  final retryResp = await _dio.fetch(reqOpts);
                  return handler.resolve(retryResp);
                } catch (e) {
                  // If retry fails, fallthrough to showing error
                }
              }
            } catch (e) {
              debugPrint('ApiClient refresh error: $e');
            }

            // Refresh didn't succeed: clear stored session, show message and navigate to login
            try {
              const storage = FlutterSecureStorage();
              await storage.delete(key: 'auth_session');
            } catch (_) {}

            AlertService.showError(
                'Sesión expirada. Por favor inicia sesión de nuevo.');
            try {
              appRouter.go('/login');
            } catch (_) {}
            return handler.next(error);
          }

          if (message != null && message.isNotEmpty) {
            AlertService.showError(message);
          }
        } catch (_) {}
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

  Future<void> _initPersistCookieJar() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final storagePath = '${dir.path}${Platform.pathSeparator}.cookies';
      final persist = PersistCookieJar(storage: FileStorage(storagePath));

      // Replace in-memory jar with persistent one and update interceptor
      _cookieJar = persist;
      _dio.interceptors.removeWhere((i) => i is CookieManager);
      _dio.interceptors.add(CookieManager(_cookieJar));
      debugPrint('ApiClient: PersistCookieJar initialized at $storagePath');
    } catch (e) {
      debugPrint('ApiClient: could not initialize PersistCookieJar: $e');
    }
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
