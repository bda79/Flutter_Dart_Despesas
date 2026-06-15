import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_feedback_state.dart';

final appFeedbackProvider =
    StateNotifierProvider<AppFeedbackController, AppFeedbackState>(
      (ref) => AppFeedbackController(),
    );

class AppFeedbackController extends StateNotifier<AppFeedbackState> {
  AppFeedbackController() : super(const AppFeedbackState());

  void showLoading() {
    state = state.copyWith(isLoading: true, error: null, success: null);
  }

  void hideLoading() {
    state = state.copyWith(isLoading: false);
  }

  void showError(String message) {
    state = state.copyWith(isLoading: false, error: message);
  }

  void showSuccess(String message) {
    state = state.copyWith(isLoading: false, success: message);
  }

  void clear() {
    state = const AppFeedbackState();
  }
}
