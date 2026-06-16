import 'package:flutter/foundation.dart';

import '../ui/app_feedback_service.dart';

class RequestManager {
  static Future<T> run<T>(
    Future<T> Function() request, {
    bool showLoading = true,
  }) async {
    try {
      if (showLoading) {
        AppFeedbackService.showLoading();
      }

      final result = await request();

      return result;
    } catch (e) {
      debugPrint("API ERROR: $e");
      rethrow;
    } finally {
      if (showLoading) {
        AppFeedbackService.hideLoading();
      }
    }
  }
}
