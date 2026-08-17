import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/database/app_database.dart';
import '../../providers/account_activity_provider.dart';
import '../../../transactions/models/activity_item.dart';

class AccountDetailsPage extends ConsumerWidget {
  const AccountDetailsPage({
    super.key,
    required this.account,
  });

  final Account account;

  // ============================================================
  // Account Helpers
  // ============================================================

  String _getAccountTypeName(String type) {
    switch (type) {
      case 'cash':
        return 'نقدية';

      case 'bank':
        return 'حساب بنكي';

      case 'creditCard':
        return 'بطاقة ائتمانية';

      case 'digitalWallet':
        return 'محفظة إلكترونية';

      case 'savings':
        return 'حساب توفير';

      case 'investment':
        return 'استثمار';

      default:
        return type;
    }
  }

  IconData _getAccountIcon(String type) {
    switch (type) {
      case 'cash':
        return Icons.payments_rounded;

      case 'bank':
        return Icons.account_balance_rounded;

      case 'creditCard':
        return Icons.credit_card_rounded;

      case 'digitalWallet':
        return Icons.account_balance_wallet_rounded;

      case 'savings':
        return Icons.savings_rounded;

      case 'investment':
        return Icons.trending_up_rounded;

      default:
        return Icons.account_balance_wallet_rounded;
    }
  }

  // ============================================================
  // Build
  // ============================================================

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;

    final accountColor = Color(account.color);

    final isNegative = account.currentBalance < 0;

    final activityAsync =
        ref.watch(accountActivityProvider(account.id));

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: colors.surface,

        // ========================================================
        // App Bar
        // ========================================================

        appBar: AppBar(
          title: const Text('تفاصيل الحساب'),
          centerTitle: true,

          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: 'رجوع',
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/accounts');
              }
            },
          ),

          actions: [
            IconButton(
              tooltip: 'تعديل الحساب',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () {
                // هنربطه بـ EditAccountPage
                // في الخطوة القادمة.
              },
            ),
          ],
        ),

        // ========================================================
        // Body
        // ========================================================

        body: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(
              accountActivityProvider(account.id),
            );

            await ref.read(
              accountActivityProvider(account.id).future,
            );
          },

          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),

            padding: const EdgeInsets.fromLTRB(
              20,
              8,
              20,
              32,
            ),

            children: [
              // ==================================================
              // Account Header
              // ==================================================

              _AccountHeader(
                account: account,
                accountColor: accountColor,
                accountTypeName:
                    _getAccountTypeName(account.type),
                accountIcon:
                    _getAccountIcon(account.type),
              ),

              const SizedBox(height: 20),

              // ==================================================
              // Account Information
              // ==================================================

              _SectionTitle(
                title: 'معلومات الحساب',
              ),

              const SizedBox(height: 10),

              Container(
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: colors.outlineVariant.withValues(
                      alpha: 0.55,
                    ),
                  ),
                ),
                clipBehavior: Clip.antiAlias,

                child: Column(
                  children: [
                    _DetailRow(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'الرصيد الافتتاحي',
                      value:
                          '${account.openingBalance.toStringAsFixed(2)} جنيه',
                    ),

                    _Divider(),

                    _DetailRow(
                      icon: Icons.category_outlined,
                      title: 'نوع الحساب',
                      value:
                          _getAccountTypeName(account.type),
                    ),

                    _Divider(),

                    _DetailRow(
                      icon: Icons.account_balance_wallet_rounded,
                      title: 'الرصيد الحالي',
                      value:
                          '${account.currentBalance.toStringAsFixed(2)} جنيه',
                      valueColor: isNegative
                          ? colors.error
                          : colors.primary,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ==================================================
              // Activities Header
              // ==================================================

              Row(
                children: [
                  Expanded(
                    child: _SectionTitle(
                      title: 'آخر العمليات',
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

              const SizedBox(height: 8),

              // ==================================================
              // Activities
              // ==================================================

              activityAsync.when(
                loading: () {
                  return _ActivityLoading();
                },

                error: (error, stackTrace) {
                  return _ActivityError(
                    onRetry: () {
                      ref.invalidate(
                        accountActivityProvider(account.id),
                      );
                    },
                  );
                },

                data: (activities) {
                  if (activities.isEmpty) {
                    return _EmptyActivities();
                  }

                  // نعرض آخر 10 عمليات فقط
                  final visibleActivities =
                      activities.take(10).toList();

                  return Container(
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: colors.outlineVariant.withValues(
                          alpha: 0.55,
                        ),
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,

                    child: Column(
                      children: [
                        for (
                          int index = 0;
                          index < visibleActivities.length;
                          index++
                        ) ...[
                          _AccountActivityTile(
                            activity:
                                visibleActivities[index],
                            accountId: account.id,
                          ),

                          if (index !=
                              visibleActivities.length - 1)
                            _Divider(),
                        ],
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // ==================================================
              // Edit Account
              // ==================================================

              SizedBox(
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // هنربطه بـ EditAccountPage
                    // في الخطوة القادمة.
                  },
                  icon: const Icon(
                    Icons.edit_outlined,
                  ),
                  label: const Text(
                    'تعديل الحساب',
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ==================================================
              // Delete Account
              // ==================================================

              SizedBox(
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // هنضيف Delete Account
                    // بعد تجهيز Repository.
                  },
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color: colors.error,
                  ),
                  label: Text(
                    'حذف الحساب',
                    style: TextStyle(
                      color: colors.error,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =================================================================
// Account Header
// =================================================================

class _AccountHeader extends StatelessWidget {
  const _AccountHeader({
    required this.account,
    required this.accountColor,
    required this.accountTypeName,
    required this.accountIcon,
  });

  final Account account;
  final Color accountColor;
  final String accountTypeName;
  final IconData accountIcon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final isNegative =
        account.currentBalance < 0;

    return Container(
      padding: const EdgeInsets.all(24),

      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),

        border: Border.all(
          color: colors.outlineVariant.withValues(
            alpha: 0.55,
          ),
        ),
      ),

      child: Column(
        children: [
          // Icon
          Container(
            width: 76,
            height: 76,

            decoration: BoxDecoration(
              color: accountColor.withValues(
                alpha: 0.14,
              ),
              shape: BoxShape.circle,
            ),

            child: Icon(
              accountIcon,
              size: 36,
              color: accountColor,
            ),
          ),

          const SizedBox(height: 16),

          // Name
          Text(
            account.name,
            textAlign: TextAlign.center,

            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),

          const SizedBox(height: 4),

          // Type
          Text(
            accountTypeName,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
          ),

          const SizedBox(height: 22),

          // Current balance label
          Text(
            'الرصيد الحالي',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
          ),

          const SizedBox(height: 6),

          // Current balance
          Text(
            '${account.currentBalance.toStringAsFixed(2)} جنيه',

            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isNegative
                      ? colors.error
                      : colors.primary,
                ),
          ),
        ],
      ),
    );
  }
}

// =================================================================
// Section Title
// =================================================================

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context)
          .textTheme
          .titleLarge
          ?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }
}

// =================================================================
// Account Activity Tile
// =================================================================

class _AccountActivityTile extends StatelessWidget {
  const _AccountActivityTile({
    required this.activity,
    required this.accountId,
  });

  final ActivityItem activity;
  final int accountId;

  @override
  Widget build(BuildContext context) {
    final colors =
        Theme.of(context).colorScheme;

    final isTransfer =
        activity.type == ActivityType.transfer;

    String title;
    String subtitle;
    String amountText;

    Color amountColor;
    Color iconBackground;

    IconData icon;

    // ============================================================
    // Transfer
    // ============================================================

    if (isTransfer) {
      final transfer = activity.transfer!;

      final isOutgoing =
          transfer.fromAccount.id == accountId;

      if (isOutgoing) {
        title = 'تحويل صادر';

        subtitle =
            'إلى ${transfer.toAccount.name}';

        amountText =
            '-${transfer.transfer.amount.toStringAsFixed(2)} جنيه';

        amountColor = colors.error;

        icon = Icons.arrow_upward_rounded;

        iconBackground =
            colors.error.withValues(alpha: 0.12);
      } else {
        title = 'تحويل وارد';

        subtitle =
            'من ${transfer.fromAccount.name}';

        amountText =
            '+${transfer.transfer.amount.toStringAsFixed(2)} جنيه';

        amountColor = colors.primary;

        icon = Icons.arrow_downward_rounded;

        iconBackground =
            colors.primary.withValues(alpha: 0.12);
      }
    }

    // ============================================================
    // Normal Transaction
    // ============================================================

    else {
      final transaction =
          activity.transaction!;

      final isExpense =
          transaction.transaction.type ==
              'expense';

      if (isExpense) {
        title = 'مصروف';

        subtitle =
            transaction.category.name;

        amountText =
            '-${transaction.transaction.amount.toStringAsFixed(2)} جنيه';

        amountColor = colors.error;

        icon =
            Icons.arrow_downward_rounded;

        iconBackground =
            colors.error.withValues(alpha: 0.12);
      } else {
        title = 'دخل';

        subtitle =
            transaction.category.name;

        amountText =
            '+${transaction.transaction.amount.toStringAsFixed(2)} جنيه';

        amountColor = colors.primary;

        icon =
            Icons.arrow_upward_rounded;

        iconBackground =
            colors.primary.withValues(alpha: 0.12);
      }
    }

    return InkWell(
      onTap: () {
        // ========================================================
        // Transaction Details
        // ========================================================

        if (!isTransfer) {
          context.push(
            '/transactions/details',
            extra: activity.transaction,
          );

          return;
        }

        // ========================================================
        // Transfer Details
        // ========================================================

        context.push(
          '/transfers/details',
          extra: activity.transfer,
        );
      },

      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),

        child: Row(
          textDirection: TextDirection.rtl,

          children: [
            // ======================================================
            // Icon
            // ======================================================

            Container(
              width: 46,
              height: 46,

              decoration: BoxDecoration(
                color: iconBackground,
                shape: BoxShape.circle,
              ),

              child: Icon(
                icon,
                size: 22,
                color: amountColor,
              ),
            ),

            const SizedBox(width: 12),

            // ======================================================
            // Details
            // ======================================================

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Text(
                    title,

                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,

                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(
                          fontWeight:
                              FontWeight.w700,
                        ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    subtitle,

                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,

                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(
                          color:
                              colors.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // ======================================================
            // Amount
            // ======================================================

            Text(
              amountText,

              textAlign: TextAlign.left,

              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                    fontWeight:
                        FontWeight.bold,
                    color: amountColor,
                  ),
            ),

            const SizedBox(width: 4),

            Icon(
              Icons.chevron_left_rounded,
              size: 20,
              color: colors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

// =================================================================
// Empty Activities
// =================================================================

class _EmptyActivities extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors =
        Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 32,
      ),

      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),

        border: Border.all(
          color: colors.outlineVariant.withValues(
            alpha: 0.55,
          ),
        ),
      ),

      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,

            decoration: BoxDecoration(
              color:
                  colors.primaryContainer,
              shape: BoxShape.circle,
            ),

            child: Icon(
              Icons.receipt_long_outlined,
              size: 30,
              color:
                  colors.onPrimaryContainer,
            ),
          ),

          const SizedBox(height: 14),

          Text(
            'لا توجد عمليات لهذا الحساب',

            textAlign: TextAlign.center,

            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),

          const SizedBox(height: 6),

          Text(
            'ستظهر هنا المصروفات والدخل والتحويلات الخاصة بهذا الحساب.',
            textAlign: TextAlign.center,

            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(
                  color:
                      colors.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

// =================================================================
// Activity Loading
// =================================================================

class _ActivityLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors =
        Theme.of(context).colorScheme;

    return Container(
      height: 160,

      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),

      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

// =================================================================
// Activity Error
// =================================================================

class _ActivityError extends StatelessWidget {
  const _ActivityError({
    required this.onRetry,
  });

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors =
        Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),

      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),

        border: Border.all(
          color:
              colors.error.withValues(alpha: 0.25),
        ),
      ),

      child: Column(
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 40,
            color: colors.error,
          ),

          const SizedBox(height: 12),

          Text(
            'حدث خطأ أثناء تحميل العمليات',
            textAlign: TextAlign.center,

            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(
                  color: colors.error,
                  fontWeight: FontWeight.w600,
                ),
          ),

          const SizedBox(height: 12),

          TextButton(
            onPressed: onRetry,
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}

// =================================================================
// Detail Row
// =================================================================

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.title,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final colors =
        Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),

      child: Row(
        textDirection: TextDirection.rtl,

        children: [
          // Icon
          Container(
            width: 38,
            height: 38,

            decoration: BoxDecoration(
              color:
                  colors.primaryContainer,
              shape: BoxShape.circle,
            ),

            child: Icon(
              icon,
              size: 19,
              color:
                  colors.onPrimaryContainer,
            ),
          ),

          const SizedBox(width: 12),

          // Title
          Expanded(
            child: Text(
              title,

              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                    color:
                        colors.onSurfaceVariant,
                  ),
            ),
          ),

          const SizedBox(width: 12),

          // Value
          Text(
            value,

            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(
                  fontWeight: FontWeight.w700,
                  color:
                      valueColor ??
                          colors.onSurface,
                ),
          ),
        ],
      ),
    );
  }
}

// =================================================================
// Divider
// =================================================================

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors =
        Theme.of(context).colorScheme;

    return Divider(
      height: 1,
      indent: 16,
      endIndent: 16,
      color: colors.outlineVariant.withValues(
        alpha: 0.5,
      ),
    );
  }
}