import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'app/router/router.dart';
import 'core/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.initialize(
    onNotificationTap: (payload) {
      if (payload == '/add-transaction') router.go(payload!);
    },
  );
  await NotificationService.instance.restoreFromPreferences(
    SharedPreferencesAsync(),
  );
  runApp(
    const ProviderScope(
      child: PocketApp(),
    ),
  );
}