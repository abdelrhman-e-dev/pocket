import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../transactions/models/transaction_period_filter.dart';
import '../../providers/report_period_filter_provider.dart';
import '../widgets/reports_header.dart';

class ReportsPage extends ConsumerWidget {
  const ReportsPage({super.key});

  Future<void> _selectCustomRange(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final currentRange = ref.read(
      reportCustomDateRangeProvider,
    );

    final now = DateTime.now();

    final initialRange =
        currentRange ??
        DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: DateTime(
            now.year,
            now.month,
            now.day,
          ),
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

    ref
        .read(reportCustomDateRangeProvider.notifier)
        .state = pickedRange;
  }

  void _handlePeriodChanged(
    BuildContext context,
    WidgetRef ref,
    TransactionPeriodFilter period,
  ) {
    ref
        .read(reportPeriodFilterProvider.notifier)
        .state = period;

    if (period == TransactionPeriodFilter.custom) {
      _selectCustomRange(context, ref);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPeriod = ref.watch(
      reportPeriodFilterProvider,
    );

    final customRange = ref.watch(
      reportCustomDateRangeProvider,
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,

        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              20,
              16,
              20,
              32,
            ),

            children: [
              // =====================================================
              // Header
              // =====================================================

              ReportsHeader(
                selectedPeriod: selectedPeriod,
                customRange: customRange,
                onPeriodChanged: (period) {
                  _handlePeriodChanged(
                    context,
                    ref,
                    period,
                  );
                },
              ),

              const SizedBox(height: 28),

              // =====================================================
              // Reports content will be added here
              // =====================================================

              _ComingSoonSection(),
            ],
          ),
        ),
      ),
    );
  }
}

// ================================================================
// Temporary Placeholder
// ================================================================

class _ComingSoonSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),

      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: colors.outlineVariant.withValues(
            alpha: 0.55,
          ),
        ),
      ),

      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,

            decoration: BoxDecoration(
              color: colors.primaryContainer,
              shape: BoxShape.circle,
            ),

            child: Icon(
              Icons.bar_chart_rounded,
              size: 32,
              color: colors.onPrimaryContainer,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'التقارير',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'سيتم عرض التحليلات المالية هنا',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}