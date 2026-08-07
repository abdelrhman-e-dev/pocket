import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controller/splash_controller.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      await ref.read(splashControllerProvider).initialize();

      if (!mounted) return;

      // navigation later
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ColoredBox(
        color: Theme.of(context).colorScheme.primary,
        child: const Center(
          child: FlutterLogo(size: 90),
        ),
      ),
    );
  }
}