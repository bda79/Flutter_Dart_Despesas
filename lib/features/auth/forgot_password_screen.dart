import 'package:flutter/material.dart';
import 'package:flutter_app/core/theme/app_theme.dart';
import 'package:flutter_app/core/ui/app_feedback_service.dart';
import 'package:flutter_app/core/utils/api_error_helper.dart';
import 'package:flutter_app/features/auth/auth_controller.dart';
import 'package:flutter_app/features/auth/reset_password_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final emailCtrl = TextEditingController();

  @override
  void dispose() {
    emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    final email = emailCtrl.text.trim();

    if (email.isEmpty) {
      AppFeedbackService.showError("Introduza o email");
      return;
    }

    try {
      final token = await ref.read(authProvider.notifier).resetPassword(email);

      if (!mounted) return;

      if (token != null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ResetPasswordScreen(token: token)),
        );
      } else {
        AppFeedbackService.showSuccess(
          "Se o email existir, receberá instruções",
        );
      }
    } catch (e) {
      if (!mounted) return;
      final msg = ApiErrorHelper.getMessage(e);
      AppFeedbackService.showError(msg);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Recuperar Password")),
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
                    "🔑 Recuperar Password",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    "Introduza o email associado à conta",
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 24),

                  TextField(
                    controller: emailCtrl,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _resetPassword,
                      child: const Text("Enviar Email"),
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Voltar ao Login"),
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
