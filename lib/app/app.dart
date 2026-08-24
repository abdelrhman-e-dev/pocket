import 'package:flutter/material.dart';
import 'router/router.dart';
import 'theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../features/app_lock/presentation/app_lock_gate.dart';

class PocketApp extends StatelessWidget {
  const PocketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Pocket',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,

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
