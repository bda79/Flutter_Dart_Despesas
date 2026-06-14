import 'package:dio/dio.dart';

import '../storage/secure_storage.dart';
import '../utils/constants.dart';
import '../../features/auth/auth_service.dart';

class DioClient {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  )..interceptors.add(_AuthInterceptor());
}

class _AuthInterceptor extends Interceptor {
  final AuthService auth = AuthService();

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await SecureStorage.getAccessToken();

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // 🔥 Se token expirou (401)
    if (err.response?.statusCode == 401) {
      final newToken = await auth.refreshToken();

      if (newToken != null) {
        final request = err.requestOptions;

        request.headers['Authorization'] = 'Bearer $newToken';

        final retry = await DioClient.dio.fetch(request);
        return handler.resolve(retry);
      } else {
        await auth.logout();
      }
    }

    handler.next(err);
  }
}
