import 'package:dio/dio.dart';
import 'package:flutter_app/core/storage/secure_storage.dart';
import 'package:flutter_app/core/utils/constants.dart';

class DioClient {
  static Function? onLogout;

  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      headers: {"Content-Type": "application/json"},
      connectTimeout: Duration(seconds: 45),
      receiveTimeout: Duration(seconds: 45),
      sendTimeout: Duration(seconds: 45),
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
  bool _isRefreshing = false;
  final List<RequestOptions> _queue = [];

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
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    final refresh = await SecureStorage.getRefreshToken();

    if (refresh == null) {
      await SecureStorage.clear();
      return handler.next(err);
    }

    try {
      if (_isRefreshing) {
        _queue.add(err.requestOptions);
        return;
      }

      _isRefreshing = true;

      final res = await DioClient.refreshDio.post(
        AppConstants.refresh,
        data: {"refresh": refresh},
      );

      final newToken = res.data["access"];

      await SecureStorage.saveAccessToken(newToken);

      _isRefreshing = false;

      // retry request original
      final request = err.requestOptions;
      request.headers["Authorization"] = "Bearer $newToken";

      final retry = await DioClient.dio.fetch(request);

      return handler.resolve(retry);
    } catch (e) {
      _isRefreshing = false;

      await SecureStorage.clear();

      DioClient.onLogout?.call();

      return handler.next(err);
    }
  }
}
