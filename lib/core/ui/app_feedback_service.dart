import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_feedback_controller.dart';

class AppFeedbackService {
  static ProviderContainer? _container;

  static void init(ProviderContainer container) {
    _container = container;
  }

  static void showLoading() {
    _container?.read(appFeedbackProvider.notifier).showLoading();
  }

  static void hideLoading() {
    _container?.read(appFeedbackProvider.notifier).hideLoading();
  }

  static void showError(String message) {
    _container?.read(appFeedbackProvider.notifier).showError(message);

    Timer(const Duration(seconds: 3), clear);
  }

  static void showSuccess(String message) {
    _container?.read(appFeedbackProvider.notifier).showSuccess(message);

    Timer(const Duration(seconds: 3), clear);
  }

  static void clear() {
    _container?.read(appFeedbackProvider.notifier).clear();
  }
}
