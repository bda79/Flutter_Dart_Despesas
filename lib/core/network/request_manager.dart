import 'package:dio/dio.dart';
import 'package:flutter_app/core/ui/app_feedback_service.dart';

class RequestManager {
  static Future<T> run<T>(
    Future<T> Function() action, {
    bool showLoading = true,
  }) async {
    try {
      if (showLoading) {
        AppFeedbackService.showLoading();
      }

      final result = await action();

      return result;
    } on DioException catch (e) {
      final data = e.response?.data;

      if (data is Map) {
        throw DioException(
          requestOptions: e.requestOptions,
          response: e.response,
          type: e.type,
          error: data, // mantém payload do backend
        );
      }

      rethrow;
    } catch (e) {
      rethrow;
    } finally {
      if (showLoading) {
        AppFeedbackService.hideLoading();
      }
    }
  }
}
