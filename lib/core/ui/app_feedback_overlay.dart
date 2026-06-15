import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_feedback_controller.dart';

class AppFeedbackOverlay extends ConsumerWidget {
  final Widget child;

  const AppFeedbackOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appFeedbackProvider);

    return Stack(
      children: [
        child,

        // LOADING
        if (state.isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),

        // ERROR
        if (state.error != null)
          _Toast(message: state.error!, color: Colors.red),

        // SUCCESS
        if (state.success != null)
          _Toast(message: state.success!, color: Colors.green),
      ],
    );
  }
}

class _Toast extends StatelessWidget {
  final String message;
  final Color color;

  const _Toast({required this.message, required this.color});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 50,
      left: 20,
      right: 20,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            message,
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
