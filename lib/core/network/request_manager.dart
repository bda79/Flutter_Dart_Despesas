import 'package:flutter/foundation.dart';
import '../ui/loading_overlay.dart';

class RequestManager {
  static Future<T> run<T>(
    Future<T> Function() request, {
    bool showLoading = true,
  }) async {
    try {
      if (showLoading) {
        LoadingOverlay.loading.value = true;
      }

      final result = await request();

      return result;
    } catch (e) {
      debugPrint("API ERROR: $e");
      rethrow;
    } finally {
      if (showLoading) {
        LoadingOverlay.loading.value = false;
      }
    }
  }
}
