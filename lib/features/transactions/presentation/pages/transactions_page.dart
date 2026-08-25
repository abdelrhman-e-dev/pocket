import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../dashboard/providers/dashboard_summary_provider.dart';
import '../../models/activity_item.dart';
import '../../providers/activity_provider.dart';
import '../../providers/filtered_transactions_provider.dart';
import '../widgets/transaction_filter_chips.dart';
import '../widgets/transaction_list_tile.dart';
import '../widgets/transactions_summary_card.dart';
import '../../../../shared/components/app_top_bar.dart';
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

  double _dayTotal(List<ActivityItem> items) {
    double total = 0;
    for (final item in items) {
      if (item.type == ActivityType.transaction) {
        final t = item.transaction!.transaction;
        total += t.type == 'expense' ? -t.amount : t.amount;
      }
    }
    return total;
  }

  Future<void> _onRefresh(WidgetRef ref) async {
    ref.invalidate(activityProvider);
    ref.invalidate(dashboardSummaryProvider);
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
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () => _onRefresh(ref),
            child: CustomScrollView(
              slivers: [
                // =========================
                // App Bar
                // =========================
                SliverAppBar(
                  pinned: true,
                  backgroundColor: colors.surface,
                  surfaceTintColor: colors.surface.withValues(alpha: 0),
                  automaticallyImplyLeading: false,
                  toolbarHeight: 72,
                  titleSpacing: 0,
                  title: Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: 12,
                      end: 8,
                    ),
                    child: Row(
                      textDirection: TextDirection.rtl,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go('/dashboard');
                            }
                          },
                        ),
                        const Expanded(
                          child: Text(
                            'العمليات',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                ),

                // =========================
                // Summary
                // =========================
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: summaryAsync.when(
                      loading: () => const SizedBox(
                        height: 100,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (_, __) => const SizedBox.shrink(),
                      data: (summary) => TransactionsSummaryCard(
                        income: summary.income,
                        expenses: summary.expenses,
                      ),
                    ),
                  ),
                ),

                // =========================
                // Filters
                // =========================
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: const [
                        TransactionFilterChips(),
                        SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TransactionPeriodFilterDropdown(),
                        ),
                        SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),

                // =========================
                // Content
                // =========================
                activitiesAsync.when(
                  loading: () => const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, stackTrace) => SliverFillRemaining(
                    child: Center(child: Text('حدث خطأ: $error')),
                  ),
                  data: (activities) {
                    if (activities.isEmpty) {
                      return const SliverFillRemaining(
                        hasScrollBody: false,
                        child: _EmptyTransactions(),
                      );
                    }

                    final grouped = _groupByDate(activities);

                    return SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          for (final entry in grouped.entries) ...[
                            _DateSectionHeader(
                              label: entry.key,
                              total: _dayTotal(entry.value),
                            ),
                            const SizedBox(height: 8),
                            ...entry.value.map((item) {
                              if (item.type == ActivityType.transfer) {
                                return _TransferListTile(item: item);
                              }
                              return TransactionListTile(
                                item: item.transaction!,
                              );
                            }),
                            const SizedBox(height: 16),
                          ],
                        ]),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),

        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push('/add-transaction'),
          icon: const Icon(Icons.add),
          label: const Text('عملية جديدة'),
        ),

        bottomNavigationBar: const AppBottomNavigation(),
      ),
    );
  }
}

// ======================================================
// Date section header with daily total
// ======================================================
class _DateSectionHeader extends StatelessWidget {
  const _DateSectionHeader({required this.label, required this.total});

  final String label;
  final double total;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isPositive = total >= 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.onSurfaceVariant,
          ),
        ),
        Text(
          '${isPositive ? '+' : ''}${total.toStringAsFixed(0)} ج.م',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: isPositive ? colors.tertiary : colors.error,
          ),
        ),
      ],
    );
  }
}

// ======================================================
// Empty state
// ======================================================
class _EmptyTransactions extends StatelessWidget {
  const _EmptyTransactions();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: 42,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'لا توجد عمليات حتى الآن',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'ابدأ بإضافة أول عملية لمتابعة مصروفاتك ودخلك',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================
// Transfer tile (unchanged behavior, kept local)
// ======================================================
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
        onTap: () => context.push('/transfers/details', extra: transfer),
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
