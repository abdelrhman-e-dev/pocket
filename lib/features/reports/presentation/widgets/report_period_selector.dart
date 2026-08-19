import 'package:flutter/material.dart';

import '../../../transactions/models/transaction_period_filter.dart';

class ReportPeriodSelector extends StatelessWidget {
  const ReportPeriodSelector({
    super.key,
    required this.selectedPeriod,
    required this.customRange,
    required this.onChanged,
  });

  final TransactionPeriodFilter selectedPeriod;
  final DateTimeRange? customRange;
  final ValueChanged<TransactionPeriodFilter> onChanged;

  String _getLabel() {
    switch (selectedPeriod) {
      case TransactionPeriodFilter.today:
        return 'اليوم';

      case TransactionPeriodFilter.thisWeek:
        return 'هذا الأسبوع';

      case TransactionPeriodFilter.thisMonth:
        return 'هذا الشهر';

      case TransactionPeriodFilter.custom:
        if (customRange == null) {
          return 'فترة مخصصة';
        }

        return '${customRange!.start.day}/${customRange!.start.month}'
            ' - '
            '${customRange!.end.day}/${customRange!.end.month}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return PopupMenuButton<TransactionPeriodFilter>(
      onSelected: onChanged,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),

      itemBuilder: (context) {
        return const [
          PopupMenuItem(
            value: TransactionPeriodFilter.today,
            child: Text('اليوم'),
          ),
          PopupMenuItem(
            value: TransactionPeriodFilter.thisWeek,
            child: Text('هذا الأسبوع'),
          ),
          PopupMenuItem(
            value: TransactionPeriodFilter.thisMonth,
            child: Text('هذا الشهر'),
          ),
          PopupMenuItem(
            value: TransactionPeriodFilter.custom,
            child: Text('فترة مخصصة'),
          ),
        ];
      },

      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),

        decoration: BoxDecoration(
          color: colors.surfaceContainer,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.6),
          ),
        ),

        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: colors.primary,
            ),

            const SizedBox(width: 8),

            Text(
              _getLabel(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(width: 4),

            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 20,
              color: colors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}