import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_controller.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = TextEditingController();
    final pass = TextEditingController();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: user,
              decoration: const InputDecoration(labelText: "Username"),
            ),
            TextField(
              controller: pass,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final ok = await ref
                    .read(authProvider.notifier)
                    .login(user.text, pass.text);

                if (ok) {
                  // depois vamos ligar router aqui
                }
              },
              child: const Text("Login"),
            ),
          ],
        ),
      ),
    );
  }
}
