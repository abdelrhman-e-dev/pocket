import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router/router.dart';
import 'theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../features/app_lock/presentation/app_lock_gate.dart';
import '../core/theme/theme_mode_provider.dart';

class PocketApp extends ConsumerWidget {
  const PocketApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Pocket',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,

      locale: const Locale('ar'),

      supportedLocales: const [Locale('ar')],

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AppLockGate(child: child!),
        );
      },

      routerConfig: router,
    );
  }
}
