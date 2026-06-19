import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/core/theme/app_theme.dart';
import 'package:flutter_app/core/ui/app_feedback_service.dart';
import 'package:flutter_app/core/utils/constants.dart';
import 'package:flutter_app/features/auth/auth_controller.dart';
import 'package:flutter_app/features/auth/forgot_password_screen.dart';
import 'package:flutter_app/features/auth/register_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final userCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    userCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (userCtrl.text.trim().isEmpty || passCtrl.text.trim().isEmpty) {
      AppFeedbackService.showError("Preencha utilizador e password");
      return;
    }

    try {
      final ok = await ref
          .read(authProvider.notifier)
          .login(userCtrl.text.trim(), passCtrl.text);

      if (!ok) {
        AppFeedbackService.showError("Utilizador ou password inválidos");
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        AppFeedbackService.showError(
          "Servidor a arrancar. Tente novamente dentro de alguns segundos.",
        );
      } else {
        AppFeedbackService.showError("Erro de ligação ao servidor");
      }
    } catch (e) {
      AppFeedbackService.showError("Erro desconhecido");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    "🔐 ${AppConstants.appName}",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  TextField(
                    controller: userCtrl,
                    decoration: const InputDecoration(
                      labelText: "Username ou Email",
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: passCtrl,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: "Password",
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
                    onSubmitted: (_) => _login(),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _login,
                      child: const Text("Login"),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Align(
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ForgotPasswordScreen(),
                          ),
                        );
                      },
                      child: const Text("Esqueceu-se da password?"),
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Não tem conta?"),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: const Text("Criar conta"),
                      ),
                    ],
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
