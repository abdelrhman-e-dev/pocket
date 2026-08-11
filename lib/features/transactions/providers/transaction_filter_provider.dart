import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/transaction_filter.dart';

final transactionFilterProvider =
    StateProvider<TransactionFilter>((ref) => TransactionFilter.all);