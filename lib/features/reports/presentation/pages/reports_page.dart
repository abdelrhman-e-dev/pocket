import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';

import '../../../transactions/models/transaction_period_filter.dart';
import '../../providers/report_period_filter_provider.dart';
import '../../providers/report_summary_provider.dart';
import '../../../transactions/providers/recent_transactions_with_details_provider.dart';
import '../../../transactions/models/transaction_with_details.dart';
import '../../repositories/reports_repository.dart';
import '../../../../shared/components/navigation/app_bottom_navigation.dart';
import '../../../../shared/utils/category_icon_mapper.dart';
import '../widgets/reports_header.dart';

class ReportsPage extends ConsumerWidget {
  const ReportsPage({super.key});

  Future<void> _selectCustomRange(BuildContext context, WidgetRef ref) async {
    final currentRange = ref.read(reportCustomDateRangeProvider);
    final now = DateTime.now();

    final initialRange =
        currentRange ??
        DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: DateTime(now.year, now.month, now.day),
        );

    final pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange: initialRange,
      helpText: 'اختر فترة التقرير',
      cancelText: 'إلغاء',
      confirmText: 'تأكيد',
      saveText: 'حفظ',
    );

    if (pickedRange == null) return;
    ref.read(reportCustomDateRangeProvider.notifier).state = pickedRange;
  }

  void _handlePeriodChanged(
    BuildContext context,
    WidgetRef ref,
    TransactionPeriodFilter period,
  ) {
    ref.read(reportPeriodFilterProvider.notifier).state = period;
    if (period == TransactionPeriodFilter.custom) {
      _selectCustomRange(context, ref);
    }
  }

  DateTimeRange _reportRange(
    TransactionPeriodFilter period,
    DateTimeRange? customRange,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (period) {
      case TransactionPeriodFilter.today:
        return DateTimeRange(
          start: today,
          end: today.add(const Duration(days: 1)),
        );
      case TransactionPeriodFilter.thisWeek:
        final start = today.subtract(Duration(days: today.weekday - 1));
        return DateTimeRange(
          start: start,
          end: today.add(const Duration(days: 1)),
        );
      case TransactionPeriodFilter.thisMonth:
        return DateTimeRange(
          start: DateTime(today.year, today.month, 1),
          end: DateTime(today.year, today.month + 1, 1),
        );
      case TransactionPeriodFilter.custom:
        final selected =
            customRange ?? DateTimeRange(start: today, end: today);
        return DateTimeRange(
          start: selected.start,
          end: selected.end.add(const Duration(days: 1)),
        );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPeriod = ref.watch(reportPeriodFilterProvider);
    final customRange = ref.watch(reportCustomDateRangeProvider);
    final range = _reportRange(selectedPeriod, customRange);

    final summary = ref.watch(reportSummaryProvider(range));
    final categories = ref.watch(reportCategoriesProvider(range));
    final dailyReports = ref.watch(dailyReportsProvider(range));
    final transactions = ref.watch(recentTransactionsWithDetailsProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              ReportsHeader(
                selectedPeriod: selectedPeriod,
                customRange: customRange,
                onPeriodChanged: (period) =>
                    _handlePeriodChanged(context, ref, period),
              ),

              const SizedBox(height: 20),

              summary.when(
                loading: () => const _HeroPlaceholder(),
                error: (_, __) => const _ReportError(),
                data: (data) => _HeroSummaryCard(summary: data),
              ),

              const SizedBox(height: 28),
              const _SectionTitle(title: 'المصروفات حسب التصنيف'),
              const SizedBox(height: 12),
              categories.when(
                loading: () => const _ChartPlaceholder(),
                error: (_, __) => const _ChartPlaceholder(),
                data: (data) => _CategorySection(categories: data),
              ),

              const SizedBox(height: 28),
              const _SectionTitle(title: 'المصروفات اليومية'),
              const SizedBox(height: 12),
              dailyReports.when(
                loading: () => const _ChartPlaceholder(),
                error: (_, __) => const _ChartPlaceholder(),
                data: (data) => _DailyExpenseChart(reports: data),
              ),

              const SizedBox(height: 28),
              categories.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (data) => _TopCategories(categories: data),
              ),

              const SizedBox(height: 28),
              _AccountPerformance(
                transactions: transactions.valueOrNull ?? const [],
              ),

              const SizedBox(height: 28),
              _RecentReportTransactions(
                transactions: transactions.valueOrNull ?? const [],
                isLoading: transactions.isLoading,
              ),
            ],
          ),
        ),
        bottomNavigationBar: const AppBottomNavigation(),
      ),
    );
  }
}

// ============================================================
// Hero Summary Card
// ============================================================

class _HeroSummaryCard extends StatelessWidget {
  const _HeroSummaryCard({required this.summary});
  final ReportSummary summary;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isPositive = summary.net >= 0;
    final savingsRate = summary.income > 0
        ? (summary.net / summary.income).clamp(-1.0, 1.0)
        : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [colors.primary, colors.primary.withValues(alpha: 0.78)],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'صافي التدفق',
            style: TextStyle(
              color: colors.onPrimary.withValues(alpha: 0.85),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 8),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isPositive ? '' : '-'}${summary.net.abs().toStringAsFixed(0)}',
                style: TextStyle(
                  color: colors.onPrimary,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'ج.م',
                  style: TextStyle(
                    color: colors.onPrimary.withValues(alpha: 0.85),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: _HeroPill(
                  icon: Icons.arrow_downward_rounded,
                  label: 'الدخل',
                  value: summary.income,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HeroPill(
                  icon: Icons.arrow_upward_rounded,
                  label: 'المصروفات',
                  value: summary.expenses,
                ),
              ),
            ],
          ),

          if (summary.income > 0) ...[
            const SizedBox(height: 18),
            Row(
              children: [
                Text(
                  'نسبة التوفير',
                  style: TextStyle(
                    color: colors.onPrimary.withValues(alpha: 0.85),
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                Text(
                  '${(savingsRate * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: colors.onPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: savingsRate.clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: colors.onPrimary.withValues(alpha: 0.18),
                valueColor: AlwaysStoppedAnimation(colors.onPrimary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  const _HeroPill({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.onPrimary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: colors.onPrimary),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: colors.onPrimary.withValues(alpha: 0.85),
                    fontSize: 11,
                  ),
                ),
                Text(
                  '${value.toStringAsFixed(0)} ج.م',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.onPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroPlaceholder extends StatelessWidget {
  const _HeroPlaceholder();
  @override
  Widget build(BuildContext context) => Container(
    height: 190,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(22),
    ),
    child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
  );
}

// ============================================================
// Section title
// ============================================================

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;
  @override
  Widget build(BuildContext context) => Text(
    title,
    style: Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
  );
}

// ============================================================
// Category donut + legend
// ============================================================

class _CategorySection extends StatelessWidget {
  const _CategorySection({required this.categories});
  final List<ExpenseByCategory> categories;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const _EmptyReport(text: 'لا توجد مصروفات في هذه الفترة');
    }

    final colors = Theme.of(context).colorScheme;
    final total = categories.fold<double>(0, (sum, item) => sum + item.amount);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 190,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 3,
                    centerSpaceRadius: 52,
                    sections: categories.take(6).map((item) {
                      return PieChartSectionData(
                        value: item.amount,
                        color: Color(item.color),
                        radius: 46,
                        showTitle: false,
                      );
                    }).toList(),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'الإجمالي',
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      total.toStringAsFixed(0),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...categories.take(6).map((item) {
            final ratio = total == 0 ? 0.0 : item.amount / total;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Color(item.color),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        categoryIconFromKey(item.icon),
                        size: 15,
                        color: Color(item.color),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item.categoryName,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Text(
                        '${(ratio * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${item.amount.toStringAsFixed(0)} ج.م',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: ratio,
                      minHeight: 5,
                      backgroundColor: colors.surfaceContainerHigh,
                      valueColor: AlwaysStoppedAnimation(Color(item.color)),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ============================================================
// Daily trend chart
// ============================================================

class _DailyExpenseChart extends StatelessWidget {
  const _DailyExpenseChart({required this.reports});
  final List<DailyReport> reports;

  @override
  Widget build(BuildContext context) {
    if (reports.isEmpty) {
      return const _EmptyReport(text: 'لا توجد مصروفات يومية في هذه الفترة');
    }

    final colors = Theme.of(context).colorScheme;
    final maxValue = reports
        .map((item) => item.amount)
        .reduce((a, b) => a > b ? a : b);

    return _ChartCard(
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxValue == 0 ? 100 : maxValue * 1.25,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: const FlTitlesData(show: false),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => colors.primary,
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              isCurved: true,
              color: colors.primary,
              barWidth: 3,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colors.primary.withValues(alpha: 0.25),
                    colors.primary.withValues(alpha: 0.0),
                  ],
                ),
              ),
              spots: reports.asMap().entries.map((entry) {
                return FlSpot(entry.key.toDouble(), entry.value.amount);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// Ranked top categories
// ============================================================

class _TopCategories extends StatelessWidget {
  const _TopCategories({required this.categories});
  final List<ExpenseByCategory> categories;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();

    final colors = Theme.of(context).colorScheme;
    final top = categories.take(3).toList();
    final maxAmount = top.first.amount == 0 ? 1 : top.first.amount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(title: 'أعلى التصنيفات إنفاقًا'),
        const SizedBox(height: 12),
        ...top.asMap().entries.map((entry) {
          final rank = entry.key + 1;
          final item = entry.value;
          final ratio = item.amount / maxAmount;

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.outlineVariant),
            ),
            child: Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Color(item.color).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$rank',
                    style: TextStyle(
                      color: Color(item.color),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            categoryIconFromKey(item.icon),
                            size: 15,
                            color: Color(item.color),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              item.categoryName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            '${item.amount.toStringAsFixed(0)} ج.م',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: ratio,
                          minHeight: 5,
                          backgroundColor: colors.surfaceContainerHigh,
                          valueColor: AlwaysStoppedAnimation(
                            Color(item.color),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

// ============================================================
// Account performance — horizontal cards
// ============================================================

class _AccountPerformance extends StatelessWidget {
  const _AccountPerformance({required this.transactions});
  final List<TransactionWithDetails> transactions;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final accountTotals = <String, double>{};
    for (final item in transactions) {
      final signedAmount = item.transaction.type == 'expense'
          ? -item.transaction.amount
          : item.transaction.amount;

      accountTotals.update(
        item.account.name,
        (value) => value + signedAmount,
        ifAbsent: () => signedAmount,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(title: 'أداء الحسابات'),
        const SizedBox(height: 12),
        if (accountTotals.isEmpty)
          const _EmptyReport(text: 'لا توجد بيانات للحسابات')
        else
          SizedBox(
            height: 96,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: accountTotals.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final entry = accountTotals.entries.elementAt(index);
                final isPositive = entry.value >= 0;

                return Container(
                  width: 160,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: colors.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 18,
                        color: colors.primary,
                      ),
                      const Spacer(),
                      Text(
                        entry.key,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${isPositive ? '+' : '-'}${entry.value.abs().toStringAsFixed(0)} ج.م',
                        style: TextStyle(
                          color: isPositive ? Colors.green : colors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

// ============================================================
// Recent transactions
// ============================================================

class _RecentReportTransactions extends StatelessWidget {
  const _RecentReportTransactions({
    required this.transactions,
    required this.isLoading,
  });

  final List<TransactionWithDetails> transactions;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(title: 'آخر العمليات'),
        const SizedBox(height: 10),
        if (isLoading)
          const _ReportLoading()
        else if (transactions.isEmpty)
          const _EmptyReport(text: 'لا توجد عمليات حتى الآن')
        else
          ...transactions.take(4).map((item) {
            final isExpense = item.transaction.type == 'expense';

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colors.outlineVariant),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isExpense
                          ? colors.errorContainer
                          : colors.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      categoryIconFromKey(item.category.icon),
                      size: 19,
                      color: isExpense ? colors.error : colors.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.category.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          item.account.name,
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${isExpense ? '-' : '+'}${item.transaction.amount.toStringAsFixed(0)} ج.م',
                    style: TextStyle(
                      color: isExpense ? colors.error : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.center,
          child: TextButton.icon(
            onPressed: () => context.push('/transactions'),
            icon: const Icon(Icons.arrow_back_rounded, size: 18),
            label: const Text('عرض الكل'),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// Shared helpers
// ============================================================

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.child, this.height = 220});
  final Widget child;
  final double height;
  @override
  Widget build(BuildContext context) => Container(
    height: height,
    padding: const EdgeInsets.fromLTRB(12, 18, 12, 10),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
    ),
    child: child,
  );
}

class _ChartPlaceholder extends StatelessWidget {
  const _ChartPlaceholder();
  @override
  Widget build(BuildContext context) => const _ChartCard(
    child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
  );
}

class _ReportLoading extends StatelessWidget {
  const _ReportLoading();
  @override
  Widget build(BuildContext context) => const SizedBox(
    height: 130,
    child: Center(child: CircularProgressIndicator()),
  );
}

class _ReportError extends StatelessWidget {
  const _ReportError();
  @override
  Widget build(BuildContext context) =>
      const _EmptyReport(text: 'تعذر تحميل بيانات التقرير');
}

class _EmptyReport extends StatelessWidget {
  const _EmptyReport({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );
  }
}