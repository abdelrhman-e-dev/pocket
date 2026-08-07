import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final splashControllerProvider = Provider((ref) {
  return SplashController();
});

class SplashController {
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 2));
  }
}