import 'package:dio/dio.dart';

class ApiErrorHelper {
  static String getMessage(dynamic error) {
    if (error is DioException) {
      final dataFromError = error.error;
      final dataFromResponse = error.response?.data;

      if (dataFromError is Map && dataFromError["message"] != null) {
        return dataFromError["message"];
      }

      if (dataFromResponse is Map && dataFromResponse["message"] != null) {
        return dataFromResponse["message"];
      }

      if (dataFromResponse is Map && dataFromResponse["error"] != null) {
        return dataFromResponse["error"];
      }

      return "Erro de rede: Servidor a arrancar, tente novamente.";
    }

    return "Erro inesperado";
  }
}
