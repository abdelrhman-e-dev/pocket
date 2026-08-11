import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../features/transactions/models/transaction_with_details.dart';

class RecentTransactions extends StatelessWidget {
  const RecentTransactions({
    super.key,
    required this.transactions,
    required this.onViewAll,
  });

  final List<TransactionWithDetails> transactions;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (transactions.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.outlineVariant),
        ),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 36,
              color: colors.onSurfaceVariant,
            ),
            const SizedBox(height: 10),
            Text(
              'لا توجد عمليات حتى الآن',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    // نعرض آخر 5 عمليات فقط.
    final recentTransactions = transactions.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // العنوان
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'آخر العمليات',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
            ),

            TextButton(
              onPressed: () {
                context.go('/transactions');
              },
              child: const Text('عرض الكل'),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // العمليات
        ...recentTransactions.map((item) {
          final transaction = item.transaction;
          final account = item.account;
          final category = item.category;

          final isExpense = transaction.type == 'expense';

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.outlineVariant),
            ),
            child: Row(
              children: [
                // الأيقونة
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isExpense
                        ? colors.errorContainer
                        : colors.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isExpense
                        ? Icons.arrow_downward_rounded
                        : Icons.arrow_upward_rounded,
                    color: isExpense ? colors.error : colors.primary,
                    size: 21,
                  ),
                ),

                const SizedBox(width: 12),

                // البيانات
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        '${account.name} • ${_formatDate(transaction.transactionDate)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // المبلغ
                Text(
                  '${isExpense ? '-' : '+'}'
                  '${transaction.amount.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: isExpense ? colors.error : colors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
