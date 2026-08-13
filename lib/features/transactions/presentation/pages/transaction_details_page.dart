import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../dashboard/providers/dashboard_provider.dart';
import '../../../dashboard/providers/dashboard_summary_provider.dart';
import '../../models/transaction_with_details.dart';
import '../../providers/all_transactions_provider.dart';
import '../../providers/paginated_transactions_provider.dart';
import '../../providers/recent_transactions_with_details_provider.dart';
import '../../providers/transaction_repository_provider.dart';

class TransactionDetailsPage extends ConsumerWidget {
  const TransactionDetailsPage({
    super.key,
    required this.transaction,
  });

  final TransactionWithDetails transaction;

  bool get isExpense => transaction.transaction.type == 'expense';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;

    final amount = transaction.transaction.amount;

    final amountText =
        '${isExpense ? '-' : '+'}${amount.toStringAsFixed(2)} جنيه';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: colors.surface,

        appBar: AppBar(
          title: const Text('تفاصيل العملية'),
          centerTitle: true,

          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/transactions');
              }
            },
          ),
        ),

        body: ListView(
          padding: const EdgeInsets.all(20),

          children: [
            // =========================
            // Amount Card
            // =========================
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: isExpense
                          ? colors.errorContainer
                          : colors.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isExpense
                          ? Icons.arrow_downward_rounded
                          : Icons.arrow_upward_rounded,
                      size: 30,
                      color: isExpense ? colors.error : colors.primary,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    isExpense ? 'مصروف' : 'دخل',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    amountText,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isExpense ? colors.error : colors.primary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // =========================
            // Details
            // =========================
            Container(
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20),
              ),
              clipBehavior: Clip.antiAlias,

              child: Column(
                children: [
                  _DetailRow(
                    icon: Icons.category_outlined,
                    title: 'التصنيف',
                    value: transaction.category.name,
                  ),

                  const _Divider(),

                  _DetailRow(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'الحساب',
                    value: transaction.account.name,
                  ),

                  const _Divider(),

                  _DetailRow(
                    icon: Icons.calendar_today_outlined,
                    title: 'التاريخ',
                    value: _formatDate(
                      transaction.transaction.transactionDate,
                    ),
                  ),

                  if (transaction.transaction.note != null &&
                      transaction.transaction.note!.trim().isNotEmpty) ...[
                    const _Divider(),

                    _DetailRow(
                      icon: Icons.notes_outlined,
                      title: 'الملاحظة',
                      value: transaction.transaction.note!,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // =========================
            // Edit Button
            // =========================
            SizedBox(
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () {
                  context.push(
                    '/transactions/edit',
                    extra: transaction,
                  );
                },
                icon: const Icon(Icons.edit_outlined),
                label: const Text('تعديل العملية'),
              ),
            ),

            const SizedBox(height: 12),

            // =========================
            // Delete Button
            // =========================
            SizedBox(
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () {
                  _deleteTransaction(context, ref);
                },
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: colors.error,
                ),
                label: Text(
                  'حذف العملية',
                  style: TextStyle(
                    color: colors.error,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteTransaction(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('حذف العملية'),
          content: const Text(
            'هل أنت متأكد من حذف هذه العملية؟\n'
            'سيتم تعديل رصيد الحساب تلقائيًا.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('حذف'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await ref
          .read(transactionRepositoryProvider)
          .deleteTransaction(
            transactionId: transaction.transaction.id,
          );

      if (!context.mounted) return;

      // =========================
      // Refresh dashboard
      // =========================
      ref.invalidate(dashboardProvider);
      ref.invalidate(dashboardSummaryProvider);

      // =========================
      // Refresh transactions
      // =========================
      ref.invalidate(recentTransactionsWithDetailsProvider);
      ref.invalidate(allTransactionsWithDetailsProvider);
      ref.invalidate(paginatedTransactionsProvider);

      // =========================
      // Back to transactions
      // =========================
      context.pop();
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('حدث خطأ أثناء حذف العملية'),
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 22,
            color: colors.primary,
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Divider(
      height: 1,
      color: colors.outlineVariant.withValues(alpha: 0.5),
    );
  }
}