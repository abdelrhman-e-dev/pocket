import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/transaction_filter.dart';
import '../../providers/transaction_filter_provider.dart';

class TransactionFilterChips extends ConsumerWidget {
  const TransactionFilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(transactionFilterProvider);
    final colors = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        textDirection: TextDirection.rtl,
        children: TransactionFilter.values.map((filter) {
          final isSelected = filter == selected;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(filter.label),
              showCheckmark: false,
              selected: isSelected,
              onSelected: (_) {
                ref.read(transactionFilterProvider.notifier).state = filter;
              },
              selectedColor: colors.primary,
              labelStyle: TextStyle(
                color: isSelected ? colors.onPrimary : colors.onSurface,
                fontWeight: FontWeight.w600,
              ),
              backgroundColor: colors.surface,
              side: BorderSide(color: colors.outlineVariant),
            ),
          );
        }).toList(),
      ),
    );
  }
}