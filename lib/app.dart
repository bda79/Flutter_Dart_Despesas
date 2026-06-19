import 'package:flutter/material.dart';
import 'package:flutter_app/core/ui/app_feedback_overlay.dart';
import 'package:flutter_app/core/utils/constants.dart';
import 'package:flutter_app/router/app_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: ref.watch(appRouterProvider),
      builder: (context, child) {
        return AppFeedbackOverlay(child: child!);
      },
      title: AppConstants.appName,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
    );
  }
}
