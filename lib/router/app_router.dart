import 'package:flutter_app/features/auth/auth_controller.dart';
import 'package:flutter_app/features/auth/auth_state.dart';
import 'package:flutter_app/features/auth/login_screen.dart';
import 'package:flutter_app/features/auth/register_screen.dart';
import 'package:flutter_app/features/auth/reset_password_screen.dart';
import 'package:flutter_app/features/despesas/lista_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',

    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) {
          final token = state.uri.queryParameters['token'];
          return ResetPasswordScreen(token: token ?? '');
        },
      ),
      GoRoute(path: '/lista', builder: (context, state) => const ListaScreen()),
    ],

    redirect: (context, state) {
      final status = auth.status;
      final location = state.matchedLocation;

      // CRÍTICO: não decidir enquanto está a carregar
      if (status == AuthStatus.loading) {
        return null;
      }

      final isLogged = status == AuthStatus.authenticated;

      const publicRoutes = ['/login', '/register', '/reset-password'];

      final isPublicRoute = publicRoutes.any(
        (route) => location.startsWith(route),
      );

      // bloqueia privadas
      if (!isLogged && !isPublicRoute) {
        return '/login';
      }

      // logged in não vê login/register
      if (isLogged && (location == '/login' || location == '/register')) {
        return '/lista';
      }

      return null;
    },
  );
});
