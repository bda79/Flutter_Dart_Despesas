import 'package:dio/dio.dart';

import '../storage/secure_storage.dart';
import '../utils/constants.dart';

class DioClient {
  static Function? onLogout;

  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      headers: {"Content-Type": "application/json"},
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  )..interceptors.add(AuthInterceptor());

  static final Dio refreshDio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      headers: {"Content-Type": "application/json"},
    ),
  );
}

class AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await SecureStorage.getAccessToken();

    if (token != null) {
      options.headers["Authorization"] = "Bearer $token";
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      final refresh = await SecureStorage.getRefreshToken();

      if (refresh != null) {
        try {
          final res = await DioClient.refreshDio.post(
            AppConstants.refresh,
            data: {"refresh": refresh},
          );

          final newToken = res.data["access"];

          await SecureStorage.saveAccessToken(newToken);

          final request = err.requestOptions;
          request.headers["Authorization"] = "Bearer $newToken";

          final retry = await DioClient.dio.fetch(request);

          return handler.resolve(retry);
        } catch (e) {
          await SecureStorage.clear();
          DioClient.onLogout?.call();
        }
      } else {
        await SecureStorage.clear();
        DioClient.onLogout?.call();
      }
    }

    handler.next(err);
  }
}
