import 'package:flutter_app/features/despesas/lista_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/auth_controller.dart';
import '../features/auth/auth_state.dart';
import '../features/auth/login_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',

    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/lista', builder: (context, state) => const ListaScreen()),
    ],

    redirect: (context, state) {
      final status = auth.status;

      // ainda a carregar app
      if (status == AuthStatus.loading) {
        return null;
      }

      final isLogged = status == AuthStatus.authenticated;

      final isLogin = state.matchedLocation == '/login';

      if (!isLogged && !isLogin) {
        return '/login';
      }

      if (isLogged && isLogin) {
        return '/lista';
      }

      return null;
    },
  );
});
