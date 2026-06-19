import 'package:flutter/material.dart';
import 'package:flutter_app/core/theme/app_theme.dart';
import 'package:flutter_app/core/ui/app_feedback_service.dart';
import 'package:flutter_app/core/utils/api_error_helper.dart';
import 'package:flutter_app/features/auth/auth_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String token;

  const ResetPasswordScreen({super.key, required this.token});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final passCtrl = TextEditingController();
  final confirmPassCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    passCtrl.dispose();
    confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _reset() async {
    final password = passCtrl.text;
    final confirmPassword = confirmPassCtrl.text;

    if (password.isEmpty || confirmPassword.isEmpty) {
      AppFeedbackService.showError("Preencha todos os campos");
      return;
    }

    if (password != confirmPassword) {
      AppFeedbackService.showError("As passwords não coincidem");
      return;
    }

    if (password.length < 6) {
      AppFeedbackService.showError("Password deve ter pelo menos 6 caracteres");
      return;
    }

    try {
      await ref
          .read(authProvider.notifier)
          .confirmPasswordReset(widget.token, password);

      if (!mounted) return;

      AppFeedbackService.showSuccess("Password alterada com sucesso");
      Navigator.pop(context);
    } catch (e) {
      final msg = ApiErrorHelper.getMessage(e);
      AppFeedbackService.showError(msg);
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
                    "🔐 Nova Password",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    "Introduza a nova password",
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 24),

                  TextField(
                    controller: passCtrl,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: "Nova Password",
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: confirmPassCtrl,
                    obscureText: _obscureConfirm,
                    decoration: InputDecoration(
                      labelText: "Confirmar Password",
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirm = !_obscureConfirm;
                          });
                        },
                      ),
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
                      onPressed: _reset,
                      child: const Text("Atualizar Password"),
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextButton(
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
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
