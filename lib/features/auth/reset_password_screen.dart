import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ui/app_feedback_service.dart';
import 'auth_controller.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String token;

  const ResetPasswordScreen({super.key, required this.token});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final passCtrl = TextEditingController();

  @override
  void dispose() {
    passCtrl.dispose();
    super.dispose();
  }

  Future<void> _reset() async {
    if (passCtrl.text.isEmpty) {
      AppFeedbackService.showError("Introduz password");
      return;
    }

    try {
      await ref
          .read(authProvider.notifier)
          .confirmPasswordReset(widget.token, passCtrl.text);

      if (!mounted) return;

      AppFeedbackService.showSuccess("Password alterada com sucesso");
      Navigator.pop(context);
    } catch (_) {
      AppFeedbackService.showError("Erro ao alterar password");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nova Password")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Introduza a nova password",
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 24),

                  TextField(
                    controller: passCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Nova password",
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _reset,
                      child: const Text("Confirmar"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
