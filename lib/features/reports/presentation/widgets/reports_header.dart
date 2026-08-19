import 'package:flutter/material.dart';

import '../../../transactions/models/transaction_period_filter.dart';
import 'report_period_selector.dart';

class ReportsHeader extends StatelessWidget {
  const ReportsHeader({
    super.key,
    required this.selectedPeriod,
    required this.customRange,
    required this.onPeriodChanged,
  });

  final TransactionPeriodFilter selectedPeriod;
  final DateTimeRange? customRange;
  final ValueChanged<TransactionPeriodFilter> onPeriodChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'التقارير',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.onSurface,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          'نظرة شاملة على وضعك المالي',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),

        const SizedBox(height: 18),

        Align(
          alignment: Alignment.centerRight,
          child: ReportPeriodSelector(
            selectedPeriod: selectedPeriod,
            customRange: customRange,
            onChanged: onPeriodChanged,
          ),
        ),
      ],
    );
  }
}