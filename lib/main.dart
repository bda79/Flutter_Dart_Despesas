import 'package:flutter_app/app.dart';
import 'package:flutter_app/core/api/dio_client.dart';
import 'package:flutter_app/core/sync/sync_service.dart';
import 'package:flutter_app/core/ui/app_feedback_service.dart';
import 'package:flutter_app/features/auth/auth_controller.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  await Hive.initFlutter();

  await SyncService.start();

  final container = ProviderContainer();
  AppFeedbackService.init(container);

  DioClient.onLogout = () {
    container.read(authProvider.notifier).logout();
  };

  runApp(UncontrolledProviderScope(container: container, child: const App()));
}
