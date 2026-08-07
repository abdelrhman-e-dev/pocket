import 'package:flutter/material.dart';
import 'router/router.dart';
import 'theme.dart';
class PocketApp extends StatelessWidget {
  const PocketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Pocket',
      debugShowCheckedModeBanner: false,
      routerConfig:router,
      theme: AppTheme.lightTheme,
    );
  }
}
