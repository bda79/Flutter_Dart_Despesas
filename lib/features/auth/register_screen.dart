import 'package:flutter/material.dart';
import 'package:flutter_app/core/ui/app_feedback_service.dart';
import 'package:flutter_app/core/utils/api_error_helper.dart';
import 'package:flutter_app/features/auth/auth_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final usernameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  @override
  void dispose() {
    usernameCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    try {
      await ref
          .read(authProvider.notifier)
          .register(
            username: usernameCtrl.text.trim(),
            email: emailCtrl.text.trim(),
            password: passwordCtrl.text,
          );

      if (!mounted) return;

      AppFeedbackService.showSuccess("Conta criada com sucesso");
      Navigator.pop(context);
    } catch (e) {
      final msg = ApiErrorHelper.getMessage(e);
      AppFeedbackService.showError(msg);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Criar Conta")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: usernameCtrl,
                    decoration: const InputDecoration(labelText: "Username"),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: emailCtrl,
                    decoration: const InputDecoration(labelText: "Email"),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: passwordCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: "Password"),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _register,
                      child: const Text("Criar Conta"),
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
