import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/transfer_with_details.dart';
import '../../providers/transfer_repository_provider.dart';

import '../../../dashboard/providers/dashboard_provider.dart';
import '../../../dashboard/providers/dashboard_summary_provider.dart';

import '../../../transactions/providers/transaction_accounts_provider.dart';
import '../../../transactions/providers/activity_provider.dart';

class TransferDetailsPage extends ConsumerWidget {
  const TransferDetailsPage({super.key, required this.transfer});

  final TransferWithDetails transfer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;

    final amount = transfer.transfer.amount;

    final amountText = '${amount.toStringAsFixed(2)} جنيه';

    return Directionality(
      textDirection: TextDirection.rtl,

      child: Scaffold(
        backgroundColor: colors.surface,

        appBar: AppBar(
          title: const Text('تفاصيل التحويل'),
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
            // =====================================================
            // Amount Card
            // =====================================================
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
                      color: colors.primaryContainer,
                      shape: BoxShape.circle,
                    ),

                    child: Icon(
                      Icons.swap_horiz_rounded,
                      size: 30,
                      color: colors.primary,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    'تحويل',
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
                      color: colors.primary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // =====================================================
            // Details
            // =====================================================
            Container(
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20),
              ),

              clipBehavior: Clip.antiAlias,

              child: Column(
                children: [
                  // -------------------------------------------------
                  // From Account
                  // -------------------------------------------------
                  _DetailRow(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'من الحساب',
                    value: transfer.fromAccount.name,
                  ),

                  const _Divider(),

                  // -------------------------------------------------
                  // To Account
                  // -------------------------------------------------
                  _DetailRow(
                    icon: Icons.account_balance_wallet_rounded,
                    title: 'إلى الحساب',
                    value: transfer.toAccount.name,
                  ),

                  const _Divider(),

                  // -------------------------------------------------
                  // Date
                  // -------------------------------------------------
                  _DetailRow(
                    icon: Icons.calendar_today_outlined,
                    title: 'التاريخ',
                    value: _formatDate(transfer.transfer.transferDate),
                  ),

                  // -------------------------------------------------
                  // Note
                  // -------------------------------------------------
                  if (transfer.transfer.note != null &&
                      transfer.transfer.note!.trim().isNotEmpty) ...[
                    const _Divider(),

                    _DetailRow(
                      icon: Icons.notes_outlined,
                      title: 'الملاحظة',
                      value: transfer.transfer.note!,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // =====================================================
            // Edit Button
            // =====================================================
            SizedBox(
              height: 52,

              child: OutlinedButton.icon(
                onPressed: () async {
                  final updated = await context.push<bool>(
                    '/transfers/edit',
                    extra: transfer,
                  );

                  if (updated == true && context.mounted) {
                    context.go('/transactions');
                  }
                },

                icon: const Icon(Icons.edit_outlined),

                label: const Text('تعديل التحويل'),
              ),
            ),

            const SizedBox(height: 12),

            // =====================================================
            // Delete Button
            // =====================================================
            SizedBox(
              height: 52,

              child: OutlinedButton.icon(
                onPressed: () {
                  _deleteTransfer(context, ref);
                },

                icon: Icon(Icons.delete_outline_rounded, color: colors.error),

                label: Text(
                  'حذف التحويل',
                  style: TextStyle(color: colors.error),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===============================================================
  // Format Date
  // ===============================================================

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');

    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  // ===============================================================
  // Delete Transfer
  // ===============================================================

  Future<void> _deleteTransfer(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,

      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('حذف التحويل'),

          content: const Text(
            'هل أنت متأكد من حذف هذا التحويل؟\n'
            'سيتم إرجاع المبلغ إلى الحساب المصدر '
            'وخصمه من الحساب المستلم.',
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

    if (confirmed != true) {
      return;
    }

    try {
      await ref
          .read(transferRepositoryProvider)
          .deleteTransfer(transferId: transfer.transfer.id);

      if (!context.mounted) {
        return;
      }

      // ===========================================================
      // Refresh Dashboard
      // ===========================================================

      ref.invalidate(dashboardProvider);

      ref.invalidate(dashboardSummaryProvider);

      // ===========================================================
      // Refresh Accounts
      // ===========================================================

      ref.invalidate(transactionAccountsProvider);

      // ===========================================================
      // Refresh Activity
      // ===========================================================

      ref.invalidate(activityProvider);

      // ===========================================================
      // Back to Transactions
      // ===========================================================

      context.go('/transactions');
    } catch (e) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدث خطأ أثناء حذف التحويل')),
      );
    }
  }
}

// ===================================================================
// Detail Row
// ===================================================================

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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),

      child: Row(
        children: [
          Icon(icon, size: 22, color: colors.primary),

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

                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ===================================================================
// Divider
// ===================================================================

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
