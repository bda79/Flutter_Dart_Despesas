import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/ui/app_feedback_service.dart';
import 'features/auth/auth_controller.dart';
import 'core/api/dio_client.dart';
import 'core/sync/sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  await SyncService.start();

  final container = ProviderContainer();
  AppFeedbackService.init(container);
  DioClient.onLogout = () {
    container.read(authProvider.notifier).logout();
  };
  await container.read(authProvider.notifier).init();

  runApp(UncontrolledProviderScope(container: container, child: const App()));
}
