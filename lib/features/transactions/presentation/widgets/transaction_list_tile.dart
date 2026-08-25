import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/utils/category_icon_mapper.dart';
import '../../models/transaction_with_details.dart';
import '../../providers/transaction_repository_provider.dart';
import '../../providers/all_transactions_provider.dart';
import '../../providers/paginated_transactions_provider.dart';
import '../../providers/activity_provider.dart';
import '../../providers/recent_transactions_with_details_provider.dart';
import '../../../dashboard/providers/dashboard_provider.dart';
import '../../../dashboard/providers/dashboard_summary_provider.dart';

class TransactionListTile extends ConsumerWidget {
  const TransactionListTile({super.key, required this.item});

  final TransactionWithDetails item;

  Future<bool> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف العملية'),
        content: const Text('سيتم حذف العملية وتعديل رصيد الحساب تلقائيًا.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;

    final transaction = item.transaction;
    final category = item.category;
    final account = item.account;

    final isExpense = transaction.type == 'expense';
    final categoryColor = Color(category.color);

    final subtitle = (transaction.note != null && transaction.note!.isNotEmpty)
        ? '${transaction.note} • ${account.name}'
        : account.name;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: ValueKey('transaction_${transaction.id}'),
        direction: DismissDirection.endToStart,
        confirmDismiss: (_) => _confirmDelete(context),
        onDismissed: (_) async {
          await ref
              .read(transactionRepositoryProviderPage)
              .deleteTransaction(transactionId: transaction.id);

          ref.invalidate(dashboardProvider);
          ref.invalidate(dashboardSummaryProvider);
          ref.invalidate(recentTransactionsWithDetailsProvider);
          ref.invalidate(allTransactionsWithDetailsProvider);
          ref.invalidate(paginatedTransactionsProvider);
          ref.invalidate(activityProvider);
        },
        background: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: colors.error,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(Icons.delete_outline_rounded, color: colors.onError),
        ),
        child: Material(
          color: colors.surface.withValues(alpha: 0),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => context.push('/transactions/details', extra: item),
            child: Ink(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      categoryIconFromKey(category.icon),
                      color: categoryColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${isExpense ? '-' : '+'}${transaction.amount.toStringAsFixed(0)} ج.م',
                    style: TextStyle(
                      color: isExpense ? colors.error : colors.tertiary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
