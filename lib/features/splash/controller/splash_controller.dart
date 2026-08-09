import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';

final splashControllerProvider = Provider<SplashController>((ref) {
  final database = ref.read(databaseProvider);

  return SplashController(database);
});

class SplashController {
  SplashController(this._database);

  final AppDatabase _database;

  Future<bool> initialize() async {
    await Future.delayed(
      const Duration(milliseconds: 1200),
    );

    try {
      final accounts = await _database
          .select(_database.accounts)
          .get();

      debugPrint(
        'Splash: accounts count = ${accounts.length}',
      );

      return accounts.isNotEmpty;
    } catch (e, stackTrace) {
      debugPrint(
        'Splash initialization error: $e',
      );

      debugPrint(
        stackTrace.toString(),
      );

      return false;
    }
  }
}