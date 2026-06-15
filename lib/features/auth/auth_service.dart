import 'package:dio/dio.dart';

import '../../core/api/dio_client.dart';
import '../../core/storage/secure_storage.dart';
import '../../core/utils/constants.dart';

class AuthService {
  final Dio _dio = DioClient.dio;

  Future<bool> login(String user, String pass) async {
    try {
      final res = await _dio.post(
        AppConstants.token,
        data: {"username": user, "password": pass},
      );

      await SecureStorage.saveAccessToken(res.data["access"]);

      await SecureStorage.saveRefreshToken(res.data["refresh"]);

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

  Future<Map<String, dynamic>?> me() async {
    try {
      final res = await _dio.get(AppConstants.me);
      return res.data;
    } catch (_) {
      return null;
    }
  }

  Future<String?> refreshToken() async {
    try {
      final refresh = await SecureStorage.getRefreshToken();

      final res = await _dio.post(
        AppConstants.refresh,
        data: {"refresh": refresh},
      );

      final newAccess = res.data["access"];
      await SecureStorage.saveAccessToken(newAccess);

      return newAccess;
    } catch (_) {
      return null;
    }
  }
}
