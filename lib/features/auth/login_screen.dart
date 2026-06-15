import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ui/app_feedback_service.dart';
import 'auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final userCtrl = TextEditingController();
  final passCtrl = TextEditingController();

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
                    "Control Despesas",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 32),

                  TextField(
                    controller: userCtrl,
                    decoration: const InputDecoration(
                      labelText: "Username ou Email",
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: passCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: "Password"),
                    onSubmitted: (_) => _login(),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _login,
                      child: const Text("Login"),
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
