import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/account_type.dart';

final selectedAccountTypeProvider =
    StateProvider<AccountType>((ref) {
  return AccountType.cash;
});