import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/transaction_type.dart';

final transactionTypeProvider =
    StateProvider<TransactionType>((ref) {
  return TransactionType.expense;
});