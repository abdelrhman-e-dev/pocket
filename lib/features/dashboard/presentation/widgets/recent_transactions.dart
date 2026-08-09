import 'package:flutter/material.dart';

import '../../../../core/database/app_database.dart';

class RecentTransactions extends StatelessWidget {
  const RecentTransactions({
    super.key,
    required this.transactions,
    required this.onViewAll,
  });

  final List<Transaction> transactions;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (transactions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Text('لا توجد عمليات حتى الآن'),
        ),
      );
    }

    // نعرض آخر 5 عمليات فقط.
    final recentTransactions = transactions.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'آخر العمليات',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            TextButton(
              onPressed: onViewAll,
              child: const Text('عرض الكل'),
            ),
          ],
        ),

        const SizedBox(height: 12),

        ...recentTransactions.map(
          (transaction) {
            final isExpense = transaction.type == 'expense';

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isExpense
                      ? colors.errorContainer
                      : colors.primaryContainer,
                  child: Icon(
                    isExpense
                        ? Icons.arrow_downward
                        : Icons.arrow_upward,
                    color: isExpense
                        ? colors.error
                        : colors.primary,
                  ),
                ),

                title: Text(
                  transaction.note?.isNotEmpty == true
                      ? transaction.note!
                      : isExpense
                          ? 'مصروف'
                          : 'دخل',
                ),

                subtitle: Text(
                  _formatDate(transaction.transactionDate),
                ),

                trailing: Text(
                  '${isExpense ? '-' : '+'}'
                  '${transaction.amount.toStringAsFixed(2)} جنيه',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isExpense
                        ? colors.error
                        : colors.primary,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}