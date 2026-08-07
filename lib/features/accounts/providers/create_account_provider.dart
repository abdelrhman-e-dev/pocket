import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'account_repository_provider.dart';

final createAccountProvider =
    FutureProvider.family<void, CreateAccountRequest>((ref, request) async {
  final repository = ref.read(accountRepositoryProvider);

  await repository.createAccount(
    name: request.name,
    type: request.type,
    openingBalance: request.openingBalance,
    color: request.color,
    icon: request.icon,
  );
});

class CreateAccountRequest {
  final String name;
  final String type;
  final double openingBalance;
  final int color;
  final String icon;

  const CreateAccountRequest({
    required this.name,
    required this.type,
    required this.openingBalance,
    required this.color,
    required this.icon,
  });
}