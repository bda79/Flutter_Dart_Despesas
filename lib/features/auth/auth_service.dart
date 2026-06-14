import 'package:dio/dio.dart';

import '../../core/storage/secure_storage.dart';
import '../../core/utils/constants.dart';

class AuthService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      headers: {'Content-Type': 'application/json'},
    ),
  );

  Future<bool> login(String username, String password) async {
    try {
      final response = await _dio.post(
        AppConstants.token,
        data: {'username': username, 'password': password},
      );

      await SecureStorage.saveAccessToken(response.data['access']);

      await SecureStorage.saveRefreshToken(response.data['refresh']);

      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> logout() async {
    final refresh = await SecureStorage.getRefreshToken();

    if (refresh != null) {
      try {
        await _dio.post(AppConstants.logout, data: {"refresh": refresh});
      } catch (_) {}
    }

    await SecureStorage.clear();
  }

  Future<Map<String, dynamic>?> getMe() async {
    try {
      final response = await _dio.get(AppConstants.me);
      return response.data;
    } catch (_) {
      return null;
    }
  }

  Future<String?> refreshToken() async {
    try {
      final refresh = await SecureStorage.getRefreshToken();

      final res = await _dio.post(
        AppConstants.refresh,
        data: {'refresh': refresh},
      );

      final newAccess = res.data['access'];
      await SecureStorage.saveAccessToken(newAccess);

      return newAccess;
    } catch (_) {
      return null;
    }
  }
}
