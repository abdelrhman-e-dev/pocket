import 'package:flutter/material.dart';

import '../../models/transaction_type.dart';

class TransactionHeader extends StatelessWidget {
  const TransactionHeader({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
    required this.onSave,
  });

  final TransactionType selectedType;
  final ValueChanged<TransactionType> onTypeChanged;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        const SizedBox(height: 12),

        // =========================
        // Header
        // =========================
        Row(
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
              tooltip: 'رجوع',
            ),

            Expanded(
              child: Center(
                child: Text(
                  'إضافة معاملة',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // =========================
        // Transaction Type
        // =========================
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: colors.surfaceContainer,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Expanded(
                child: _TypeButton(
                  title: 'مصروف',
                  selected: selectedType == TransactionType.expense,
                  onTap: () {
                    onTypeChanged(TransactionType.expense);
                  },
                ),
              ),

              Expanded(
                child: _TypeButton(
                  title: 'دخل',
                  selected: selectedType == TransactionType.income,
                  onTap: () {
                    onTypeChanged(TransactionType.income);
                  },
                ),
              ),

              Expanded(
                child: _TypeButton(
                  title: 'تحويل',
                  selected: selectedType == TransactionType.transfer,
                  onTap: () {
                    onTypeChanged(TransactionType.transfer);
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TypeButton extends StatelessWidget {
  const _TypeButton({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: 44,
      decoration: BoxDecoration(
        color: selected ? colors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(11),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(11),
        onTap: onTap,
        child: Center(
          child: Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: selected ? colors.onPrimary : colors.onSurface,
              fontWeight: selected
                  ? FontWeight.w700
                  : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}