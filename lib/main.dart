import 'package:flutter/material.dart';
import 'package:flutter_app/app.dart';
import 'package:flutter_app/core/api/dio_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/auth/auth_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final container = ProviderContainer();

  DioClient.onLogout = () {
    container.read(authProvider.notifier).logout();
  };

  await container.read(authProvider.notifier).init();

  runApp(UncontrolledProviderScope(container: container, child: const App()));
}
