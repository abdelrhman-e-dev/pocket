import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../dashboard/providers/dashboard_summary_provider.dart';
import '../../models/transaction_with_details.dart';
import '../../providers/paginated_transactions_provider.dart';
import '../widgets/transaction_filter_chips.dart';
import '../widgets/transaction_list_tile.dart';
import '../widgets/transactions_summary_card.dart';
import '../../../../shared/components/navigation/app_bottom_navigation.dart';
import '../widgets/transaction_period_filter.dart';

class TransactionsPage extends ConsumerWidget {
  const TransactionsPage({super.key});

  Map<String, List<TransactionWithDetails>> _groupByDate(
    List<TransactionWithDetails> items,
  ) {
    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final yesterday = today.subtract(
      const Duration(days: 1),
    );

    final grouped = <String, List<TransactionWithDetails>>{};

    for (final item in items) {
      final date = item.transaction.transactionDate;

      final day = DateTime(
        date.year,
        date.month,
        date.day,
      );

      final String label;

      if (day == today) {
        label = 'اليوم';
      } else if (day == yesterday) {
        label = 'أمس';
      } else {
        label = '${date.day}/${date.month}/${date.year}';
      }

      grouped.putIfAbsent(
        label,
        () => [],
      ).add(item);
    }

    return grouped;
  }

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final paginationState =
        ref.watch(paginatedTransactionsProvider);

    final summaryAsync =
        ref.watch(dashboardSummaryProvider);

    final colors =
        Theme.of(context).colorScheme;

    final transactions =
        paginationState.items;

    final grouped =
        _groupByDate(transactions);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: colors.surface,

        appBar: AppBar(
          title: const Text('العمليات'),
          centerTitle: true,

          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
            ),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/dashboard');
              }
            },
          ),
        ),

        body: paginationState.isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ListView(
                padding: const EdgeInsets.all(20),

                children: [
                  // =========================
                  // Summary
                  // =========================
                  summaryAsync.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),

                    error: (_, __) =>
                        const SizedBox.shrink(),

                    data: (summary) =>
                        TransactionsSummaryCard(
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
                    child:
                        TransactionPeriodFilterDropdown(),
                  ),

                  const SizedBox(height: 20),

                  // =========================
                  // Empty State
                  // =========================
                  if (transactions.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(
                        top: 60,
                      ),
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
                    ...grouped.entries.expand(
                      (entry) {
                        return [
                          Padding(
                            padding:
                                const EdgeInsets.only(
                              bottom: 10,
                            ),
                            child: Text(
                              entry.key,
                              style: Theme.of(
                                context,
                              )
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight:
                                        FontWeight.bold,
                                    color: colors
                                        .onSurfaceVariant,
                                  ),
                            ),
                          ),

                          ...entry.value.map(
                            (item) =>
                                TransactionListTile(
                              item: item,
                            ),
                          ),

                          const SizedBox(
                            height: 8,
                          ),
                        ];
                      },
                    ),

                    // =========================
                    // Load More
                    // =========================
                    if (paginationState.hasMore)
                      Padding(
                        padding:
                            const EdgeInsets.only(
                          top: 12,
                          bottom: 20,
                        ),
                        child: Center(
                          child:
                              paginationState
                                      .isLoadingMore
                                  ? const Padding(
                                      padding:
                                          EdgeInsets.all(
                                        12,
                                      ),
                                      child:
                                          CircularProgressIndicator(),
                                    )
                                  : OutlinedButton.icon(
                                      onPressed: () {
                                        ref
                                            .read(
                                              paginatedTransactionsProvider
                                                  .notifier,
                                            )
                                            .loadMore();
                                      },
                                      icon: const Icon(
                                        Icons
                                            .expand_more_rounded,
                                      ),
                                      label: const Text(
                                        'تحميل المزيد',
                                      ),
                                    ),
                        ),
                      ),
                  ],
                ],
              ),

        bottomNavigationBar:
            const AppBottomNavigation(),
      ),
    );
  }
}