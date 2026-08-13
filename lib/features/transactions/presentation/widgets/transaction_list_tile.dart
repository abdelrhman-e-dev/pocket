import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/utils/category_icon_mapper.dart';
import '../../models/transaction_with_details.dart';

class TransactionListTile extends StatelessWidget {
  const TransactionListTile({
    super.key,
    required this.item,
  });

  final TransactionWithDetails item;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final transaction = item.transaction;
    final category = item.category;
    final account = item.account;

    final isExpense = transaction.type == 'expense';
    final categoryColor = Color(category.color);

    final subtitle =
        (transaction.note != null &&
                transaction.note!.isNotEmpty)
            ? '${transaction.note} • ${account.name}'
            : account.name;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            context.push(
              '/transactions/details',
              extra: item,
            );
          },
          child: Ink(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest.withValues(
                alpha: 0.3,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(
                      alpha: 0.12,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    categoryIconFromKey(
                      category.icon,
                    ),
                    color: categoryColor,
                    size: 22,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        subtitle,
                        textDirection: TextDirection.rtl,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                Text(
                  '${isExpense ? '-' : '+'}${transaction.amount.toStringAsFixed(0)} ج.م',
                  style: TextStyle(
                    color: isExpense
                        ? colors.error
                        : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}