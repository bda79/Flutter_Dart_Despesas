import 'package:go_router/go_router.dart';
import '../../features/auth/login_screen.dart';
import '../../features/despesas/lista_screen.dart';
import '../storage/secure_storage.dart';
import '../../features/auth/auth_service.dart';

final appRouter = GoRouter(
  initialLocation: '/login',

  redirect: (context, state) async {
    final auth = AuthService();

    final hasToken = await SecureStorage.hasToken();

    final isLogin = state.matchedLocation == '/login';

    if (!hasToken && !isLogin) {
      return '/login';
    }

    if (hasToken) {
      final me = await auth.getMe();

      if (me == null) {
        await SecureStorage.clear();
        return '/login';
      }

      if (isLogin) {
        return '/lista';
      }
    }

    return null;
  },

  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/lista', builder: (context, state) => const ListaScreen()),
  ],
);
