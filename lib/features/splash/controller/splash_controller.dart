import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../accounts/providers/account_repository_provider.dart';

final splashControllerProvider = Provider(
  (ref) => SplashController(ref),
);

class SplashController {
  SplashController(this.ref);

  final Ref ref;

  Future<bool> hasAccounts() async {
    await Future.delayed(const Duration(seconds: 2));

    final repository = ref.read(accountRepositoryProvider);

    final accounts = await repository.getAccounts();

    return accounts.isNotEmpty;
  }
}