import 'package:flutter/material.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({
    super.key,
    required this.total,
  });

  final double total;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_balance_wallet_rounded,
                  color: colors.onPrimary,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  'إجمالي الرصيد',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                        color: colors.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  total.toStringAsFixed(2),
                  style: Theme.of(context)
                      .textTheme
                      .headlineLarge
                      ?.copyWith(
                        color: colors.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                ),

                const SizedBox(width: 8),

                Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Text(
                    'جنيه',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          color: colors.onPrimary.withValues(alpha: 0.85),
                        ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            Text(
              'إجمالي أرصدة جميع حساباتك',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(
                    color: colors.onPrimary.withValues(alpha: 0.8),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}