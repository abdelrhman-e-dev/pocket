import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../../transactions/repositories/transaction_repository.dart';

final transactionRepositoryProvider =
    Provider<TransactionRepository>((ref) {
  final database = ref.watch(databaseProvider);

  return TransactionRepository(database);
});

final dashboardSummaryProvider =
    FutureProvider<DashboardSummaryData>((ref) async {
  final repository = ref.watch(transactionRepositoryProvider);

  final expenses = await repository.getCurrentMonthExpenses();
  final income = await repository.getCurrentMonthIncome();

  return DashboardSummaryData(
    expenses: expenses,
    income: income,
  );
});

class DashboardSummaryData {
  const DashboardSummaryData({
    required this.expenses,
    required this.income,
  });

  final double expenses;
  final double income;
}