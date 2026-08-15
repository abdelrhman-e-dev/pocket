import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/activity_item.dart';
import '../providers/transaction_repository_provider.dart';
import '../../transfers/providers/transfer_repository_provider.dart';

final activityProvider = FutureProvider<List<ActivityItem>>((ref) async {
  final transactionRepository = ref.watch(
    transactionRepositoryProviderPage,
  );

  final transferRepository = ref.watch(
    transferRepositoryProvider,
  );

  final transactions =
      await transactionRepository.getAllTransactionsWithDetails();

  final transfers =
      await transferRepository.getAllTransfersWithDetails();

final activities = <ActivityItem>[
  ...transactions.map(
    (transaction) => ActivityItem.transaction(
      transaction: transaction,
    ),
  ),
  ...transfers.map(
    (transfer) => ActivityItem.transfer(
      transfer: transfer,
    ),
  ),
];

  activities.sort(
    (a, b) => b.date.compareTo(a.date),
  );

  return activities;
});