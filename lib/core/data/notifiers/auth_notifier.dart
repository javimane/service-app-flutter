import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../repositories/auth_repository.dart';

class AuthState {
  final bool loading;
  final Map<String, dynamic>? session;
  final String? error;

  AuthState({this.loading = false, this.session, this.error});

  AuthState copyWith(
      {bool? loading, Map<String, dynamic>? session, String? error}) {
    return AuthState(
      loading: loading ?? this.loading,
      session: session ?? this.session,
      error: error,
    );
  }

  bool get authenticated => session != null;
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;
  final AuthRepository _repo;
  static const _storageKey = 'auth_session';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AuthNotifier(this.ref, this._repo) : super(AuthState()) {
    // restore session asynchronously
    Future.microtask(() async {
      await _restoreSession();
    });
  }

  Future<void> _saveSession(Map<String, dynamic> session) async {
    try {
      await _storage.write(key: _storageKey, value: jsonEncode(session));
    } catch (_) {}
  }

  Future<void> _clearSession() async {
    try {
      await _storage.delete(key: _storageKey);
    } catch (_) {}
  }

  Future<void> _restoreSession() async {
    try {
      final s = await _storage.read(key: _storageKey);
      if (s == null) return;
      final Map<String, dynamic> session =
          jsonDecode(s) as Map<String, dynamic>;
      state = state.copyWith(session: session);
      // Optionally validate session by calling getSession
      try {
        final remote = await _repo.getSession();
        if (remote.isNotEmpty) {
          state = state.copyWith(session: remote);
          await _saveSession(remote);
        }
      } catch (_) {}
    } catch (_) {}
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(loading: true, error: null);
    try {
      debugPrint('AuthNotifier.login: usando _repo directamente');
      final resp = await _repo.login(email, password);
      debugPrint('AuthNotifier.login: _repo.login finalizado con exito');
      // save session
      await _saveSession(resp);

      // Supabase Login (Chat)
      try {
        debugPrint('AuthNotifier.login: Iniciando Supabase signInWithPassword');
        await Supabase.instance.client.auth
            .signInWithPassword(
              email: email,
              password: password,
            )
            .timeout(const Duration(seconds: 5));
        debugPrint('AuthNotifier.login: Supabase login exitoso');
      } catch (e) {
        debugPrint('Supabase login error: $e');
      }

      // Firebase Token Registration (Push Notifications)
      try {
        debugPrint('AuthNotifier.login: Solicitando token de Firebase');
        final token = await FirebaseMessaging.instance
            .getToken()
            .timeout(const Duration(seconds: 5));
        debugPrint('AuthNotifier.login: Token Firebase obtenido');
        if (token != null) {
          final platform =
              kIsWeb ? 'web' : (Platform.isIOS ? 'ios' : 'android');
          await _repo
              .registerDeviceToken(token, platform)
              .timeout(const Duration(seconds: 5));
          debugPrint(
              'AuthNotifier.login: Token Firebase registrado en backend');
        }
      } catch (e) {
        debugPrint('Firebase token registration error: $e');
      }

      state = state.copyWith(loading: false, session: resp, error: null);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      // Do not rethrow; error will be shown in UI via state.error
    }
  }

  Future<void> register(String email, String password) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final repo = _repo;
      await repo.register(email, password);
      // try auto-login
      await login(email, password);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> refresh() async {
    // attempt to refresh session from server
    state = state.copyWith(loading: true, error: null);
    try {
      final repo = ref.read(authRepositoryProvider);
      final remote = await repo.getSession();
      state = state.copyWith(session: remote, loading: false);
      await _saveSession(remote);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  void logout() {
    state = AuthState();
    _clearSession();
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repo = ref.read(authRepositoryProvider);
  return AuthNotifier(ref, repo);
});
