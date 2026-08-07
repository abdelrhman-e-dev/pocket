import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/dashboard_provider.dart';
import '../widgets/account_title.dart';
import '../widgets/balance_card.dart';
import '../widgets/empty_dashboard.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(dashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Pocket"),
      ),

      body: accounts.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),

        error: (e, _) => Center(
          child: Text(e.toString()),
        ),

        data: (items) {
          if (items.isEmpty) {
            return const EmptyDashboard();
          }

          final total = items.fold<double>(
            0,
            (sum, account) => sum + account.currentBalance,
          );

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              BalanceCard(total: total),

              const SizedBox(height: 24),

              ...items.map(
                (account) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AccountTile(account: account),
                ),
              ),
            ],
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