enum AuthStatus { loading, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;

  const AuthState(this.status);

  bool get isAuth => status == AuthStatus.authenticated;
}
