class AppFeedbackState {
  final bool isLoading;
  final String? error;
  final String? success;

  const AppFeedbackState({this.isLoading = false, this.error, this.success});

  AppFeedbackState copyWith({bool? isLoading, String? error, String? success}) {
    return AppFeedbackState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      success: success,
    );
  }
}
