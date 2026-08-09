import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/dashboard_provider.dart';
import '../widgets/balance_card.dart';
import '../widgets/empty_dashboard.dart';
import '../widgets/recent_transactions.dart';
import '../../../transactions/providers/recent_transactions_with_details_provider.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_summary.dart';
import '../widgets/dashboard_accounts.dart';
import '../../providers/dashboard_summary_provider.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(dashboardProvider);
    final transactions = ref.watch(recentTransactionsWithDetailsProvider);
    final summary = ref.watch(dashboardSummaryProvider);
    return Scaffold(
      body: accounts.when(
        loading: () => const Center(child: CircularProgressIndicator()),

        error: (e, _) => Center(child: Text(e.toString())),

        data: (items) {
          if (items.isEmpty) {
            return const EmptyDashboard();
          }

          final total = items.fold<double>(
            0,
            (sum, account) => sum + account.currentBalance,
          );
          return summary.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text(error.toString())),
            data: (summaryData) {
              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const SizedBox(height: 40),
                  const DashboardHeader(),

                  const SizedBox(height: 24),

                  BalanceCard(total: total),

                  const SizedBox(height: 24),

                  DashboardSummary(
                    expenses: summaryData.expenses,
                    income: summaryData.income,
                    accountsCount: items.length,
                  ),

                  const SizedBox(height: 24),

                  DashboardAccounts(
                    accounts: items,
                    onViewAll: () {
                      // صفحة الحسابات سنعملها لاحقًا
                    },
                  ),

                  const SizedBox(height: 24),

                  transactions.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),

                    error: (error, stackTrace) => Text(
                      'حدث خطأ أثناء تحميل العمليات',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),

                    data: (items) => RecentTransactions(
                      transactions: items,
                      onViewAll: () {
                        context.push('/transactions');
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/add-transaction');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
