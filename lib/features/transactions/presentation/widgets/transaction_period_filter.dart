import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/transaction_period_filter.dart';
import '../../providers/transaction_period_filter_provider.dart';

class TransactionPeriodFilterDropdown extends ConsumerWidget {
  const TransactionPeriodFilterDropdown({super.key});

  String _label(TransactionPeriodFilter filter) {
    switch (filter) {
      case TransactionPeriodFilter.today:
        return 'اليوم';

      case TransactionPeriodFilter.thisWeek:
        return 'هذا الأسبوع';

      case TransactionPeriodFilter.thisMonth:
        return 'هذا الشهر';

      case TransactionPeriodFilter.custom:
        return 'فترة مخصصة';
    }
  }

  Future<void> _selectCustomRange(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final now = DateTime.now();

    final currentRange =
        ref.read(customTransactionDateRangeProvider);

    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange: currentRange ??
          DateTimeRange(
            start: DateTime(now.year, now.month, 1),
            end: DateTime(now.year, now.month, now.day),
          ),
    );

    if (range == null) return;

    ref.read(customTransactionDateRangeProvider.notifier).state = range;

    ref.read(transactionPeriodFilterProvider.notifier).state =
        TransactionPeriodFilter.custom;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(transactionPeriodFilterProvider);

    final colors = Theme.of(context).colorScheme;

    return PopupMenuButton<TransactionPeriodFilter>(
      onSelected: (value) async {
        if (value == TransactionPeriodFilter.custom) {
          await _selectCustomRange(context, ref);
          return;
        }

        ref.read(transactionPeriodFilterProvider.notifier).state = value;
      },
      itemBuilder: (context) {
        return TransactionPeriodFilter.values.map((filter) {
          return PopupMenuItem<TransactionPeriodFilter>(
            value: filter,
            child: Row(
              children: [
                if (filter == selected)
                  Icon(
                    Icons.check,
                    size: 20,
                    color: colors.primary,
                  )
                else
                  const SizedBox(width: 20),

                const SizedBox(width: 8),

                Text(_label(filter)),
              ],
            ),
          );
        }).toList();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: colors.outlineVariant,
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
              _label(selected),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),

            const SizedBox(width: 4),

            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}