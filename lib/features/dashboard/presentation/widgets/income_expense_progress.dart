import 'package:flutter/material.dart';

class IncomeExpenseProgress extends StatelessWidget {
  const IncomeExpenseProgress({
    super.key,
    required this.income,
    required this.expenses,
  });

  final double income;
  final double expenses;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final total = income + expenses;
    final incomeRatio = total == 0 ? 0.5 : income / total;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الدخل مقابل المصروفات',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 10,
                child: Row(
                  children: [
                    Expanded(
                      flex: (incomeRatio * 100).round().clamp(1, 99),
                      child: Container(color: colors.primary),
                    ),
                    Expanded(
                      flex: 100 - (incomeRatio * 100).round().clamp(1, 99),
                      child: Container(color: colors.error),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _Legend(color: colors.primary, label: 'دخل ${income.toStringAsFixed(0)}'),
                _Legend(color: colors.error, label: 'مصروف ${expenses.toStringAsFixed(0)}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}