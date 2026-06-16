import 'package:dio/dio.dart';

import '../../core/api/dio_client.dart';
import '../../core/network/request_manager.dart';
import '../../core/storage/secure_storage.dart';
import '../../core/utils/constants.dart';

class AuthService {
  final Dio _dio = DioClient.dio;

  Future<bool> login(String user, String pass) async {
    return await RequestManager.run(() async {
      final res = await _dio.post(
        AppConstants.token,
        data: {"username": user, "password": pass},
      );

      await SecureStorage.saveAccessToken(res.data["access"]);
      await SecureStorage.saveRefreshToken(res.data["refresh"]);

      return true;
    }).catchError((_) => false);
  }

  Future<void> logout() async {
    final refresh = await SecureStorage.getRefreshToken();

    if (refresh != null) {
      try {
        await RequestManager.run(() async {
          await _dio.post(AppConstants.logout, data: {"refresh": refresh});
        });
      } catch (_) {}
    }

    await SecureStorage.clear();
  }

  Future<Map<String, dynamic>?> me() async {
    try {
      return await RequestManager.run(() async {
        final res = await _dio.get(AppConstants.me);
        return res.data;
      });
    } catch (_) {
      return null;
    }
  }

  Future<String?> refreshToken() async {
    try {
      final refresh = await SecureStorage.getRefreshToken();
      if (refresh == null) return null;

      return await RequestManager.run(() async {
        final res = await _dio.post(
          AppConstants.refresh,
          data: {"refresh": refresh},
        );

        final newAccess = res.data["access"];
        await SecureStorage.saveAccessToken(newAccess);

        return newAccess;
      });
    } catch (_) {
      return null;
    }
  }

  Future<void> register({
    required String username,
    required String email,
    required String password,
  }) async {
    await RequestManager.run(() async {
      final res = await _dio.post(
        AppConstants.register,
        data: {"username": username, "email": email, "password": password},
      );

      await SecureStorage.saveAccessToken(res.data["access"]);
      await SecureStorage.saveRefreshToken(res.data["refresh"]);
    });
  }

  Future<void> resetPassword(String email) async {
    await RequestManager.run(() async {
      await _dio.post(AppConstants.passwordReset, data: {"email": email});
    });
  }

  Future<void> confirmPasswordReset(String token, String password) async {
    await RequestManager.run(() async {
      await _dio.post(
        AppConstants.passwordResetConfirm,
        data: {"token": token, "password": password},
      );
    });
  }
}
