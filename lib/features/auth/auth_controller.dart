import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/secure_storage.dart';
import 'auth_service.dart';
import 'auth_state.dart';

final authProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) => AuthController(ref),
);

class AuthController extends StateNotifier<AuthState> {
  final Ref ref;

  AuthController(this.ref) : super(const AuthState(AuthStatus.loading)) {
    init();
  }

  final _service = AuthService();

  Future<void> init() async {
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

  Future<void> forceLogout() async {
    await SecureStorage.clear();

    state = const AuthState(AuthStatus.unauthenticated);
  }
}
