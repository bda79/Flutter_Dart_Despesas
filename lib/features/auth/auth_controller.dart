import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/secure_storage.dart';
import 'auth_service.dart';
import 'auth_state.dart';

final authProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) => AuthController(ref),
);

class AuthController extends StateNotifier<AuthState> {
  final Ref ref;
  final _service = AuthService();

  AuthController(this.ref) : super(const AuthState(AuthStatus.loading)) {
    _init();
  }

  Future<void> _init() async {
    try {
      final hasToken = await SecureStorage.hasToken();

      if (!hasToken) {
        state = const AuthState(AuthStatus.unauthenticated);
        return;
      }

      final me = await _service.me();

      if (me == null) {
        await SecureStorage.clear();
        state = const AuthState(AuthStatus.unauthenticated);
        return;
      }

      state = const AuthState(AuthStatus.authenticated);
    } catch (_) {
      await SecureStorage.clear();
      state = const AuthState(AuthStatus.unauthenticated);
    }
  }

  Future<bool> login(String user, String pass) async {
    final ok = await _service.login(user, pass);

    if (ok) {
      state = const AuthState(AuthStatus.authenticated);
    }

    return ok;
  }

  Future<void> logout() async {
    await _service.logout();
    await SecureStorage.clear();
    state = const AuthState(AuthStatus.unauthenticated);
  }

  Future<void> register({
    required String username,
    required String email,
    required String password,
  }) {
    return _service.register(
      username: username,
      email: email,
      password: password,
    );
  }

  Future<String?> resetPassword(String email) {
    return _service.resetPassword(email);
  }

  Future<void> confirmPasswordReset(String token, String password) {
    return _service.confirmPasswordReset(token, password);
  }
}
