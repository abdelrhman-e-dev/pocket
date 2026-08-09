import 'package:flutter/material.dart';

import '../../../../core/database/app_database.dart';

class DashboardAccounts extends StatelessWidget {
  const DashboardAccounts({
    super.key,
    required this.accounts,
    required this.onViewAll,
  });

  final List<Account> accounts;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // العنوان
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'الحسابات',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
            ),

            TextButton(
              onPressed: onViewAll,
              child: const Text('عرض الكل'),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // الحسابات
        SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: accounts.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final account = accounts[index];

              return _AccountCard(
                account: account,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({
    required this.account,
  });

  final Account account;

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

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: 180,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getAccountIcon(account.type),
                  color: colors.primary,
                  size: 22,
                ),
              ),

              const Spacer(),

              Icon(
                Icons.more_horiz_rounded,
                color: colors.onSurfaceVariant,
              ),
            ],
          ),

          const Spacer(),

          Text(
            account.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),

          const SizedBox(height: 2),

          Text(
            _getAccountTypeName(account.type),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
          ),

          const SizedBox(height: 6),

          Text(
            '${account.currentBalance.toStringAsFixed(2)} جنيه',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}