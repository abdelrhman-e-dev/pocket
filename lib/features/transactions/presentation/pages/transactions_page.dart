import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../dashboard/providers/dashboard_summary_provider.dart';
import '../../models/activity_item.dart';
import '../../providers/filtered_transactions_provider.dart';
import '../widgets/transaction_filter_chips.dart';
import '../widgets/transaction_list_tile.dart';
import '../widgets/transactions_summary_card.dart';
import '../../../../shared/components/navigation/app_bottom_navigation.dart';
import '../widgets/transaction_period_filter.dart';

class TransactionsPage extends ConsumerWidget {
  const TransactionsPage({super.key});

  Map<String, List<ActivityItem>> _groupByDate(List<ActivityItem> items) {
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);

    final yesterday = today.subtract(const Duration(days: 1));

    final grouped = <String, List<ActivityItem>>{};

    for (final item in items) {
      final date = item.date;

      final day = DateTime(date.year, date.month, date.day);

      final String label;

      if (day == today) {
        label = 'اليوم';
      } else if (day == yesterday) {
        label = 'أمس';
      } else {
        label = '${date.day}/${date.month}/${date.year}';
      }

      grouped.putIfAbsent(label, () => []).add(item);
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(filteredActivitiesProvider);
    final summaryAsync = ref.watch(dashboardSummaryProvider);

    final colors = Theme.of(context).colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: colors.surface,

        appBar: AppBar(
          title: const Text('العمليات'),
          centerTitle: true,

          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/dashboard');
              }
            },
          ),
        ),

        body: activitiesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(child: Text('حدث خطأ: $error')),
          data: (activities) {
            final grouped = _groupByDate(activities);

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // =========================
                // Summary
                // =========================
                summaryAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),

                  error: (_, __) => const SizedBox.shrink(),

                  data: (summary) => TransactionsSummaryCard(
                    income: summary.income,
                    expenses: summary.expenses,
                  ),
                ),

                const SizedBox(height: 20),

                // =========================
                // Type Filter
                // =========================
                const TransactionFilterChips(),

                const SizedBox(height: 12),

                // =========================
                // Period Filter
                // =========================
                const Align(
                  alignment: Alignment.centerRight,
                  child: TransactionPeriodFilterDropdown(),
                ),

                const SizedBox(height: 20),

                // =========================
                // Empty State
                // =========================
                if (activities.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 60),
                    child: Center(
                      child: Text(
                        'لا توجد عمليات حتى الآن',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                // =========================
                // Transactions
                // =========================
                else ...[
                  ...grouped.entries.expand((entry) {
                    return [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          entry.key,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colors.onSurfaceVariant,
                              ),
                        ),
                      ),

                      ...entry.value.map((item) {
                        if (item.type == ActivityType.transfer) {
                          return _TransferListTile(item: item);
                        }

                        return TransactionListTile(item: item.transaction!);
                      }),

                      const SizedBox(height: 8),
                    ];
                  }),
                ],
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

        bottomNavigationBar: const AppBottomNavigation(),
      ),
    );
  }
}

class _TransferListTile extends StatelessWidget {
  const _TransferListTile({required this.item});

  final ActivityItem item;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final transfer = item.transfer!;
    final fromAccount = transfer.fromAccount;
    final toAccount = transfer.toAccount;

    final note = transfer.transfer.note;

    final subtitle = note != null && note.trim().isNotEmpty
        ? '$note • ${fromAccount.name}'
        : fromAccount.name;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          context.push('/transfers/details', extra: transfer);
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.swap_horiz_rounded,
                  color: colors.primary,
                  size: 24,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${fromAccount.name} → ${toAccount.name}',
                      textDirection: TextDirection.rtl,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      subtitle,
                      textDirection: TextDirection.rtl,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Text(
                '${transfer.transfer.amount.toStringAsFixed(0)} ج.م',
                style: TextStyle(
                  color: colors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
