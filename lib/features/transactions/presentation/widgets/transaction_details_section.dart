import 'package:flutter/material.dart';

class TransactionDetailsSection extends StatelessWidget {
  const TransactionDetailsSection({
    super.key,
    required this.accountName,
    required this.accountType,
    required this.date,
    required this.onAccountTap,
    required this.onDateTap,
    required this.onNoteTap,
  });

  final String accountName;
  final String accountType;
  final DateTime date;

  final VoidCallback onAccountTap;
  final VoidCallback onDateTap;
  final VoidCallback onNoteTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _TransactionDetailRow(
            icon: Icons.account_balance_wallet_outlined,
            title: 'الحساب',
            value: accountName,
            secondaryValue: accountType,
            onTap: onAccountTap,
          ),

          Divider(
            height: 1,
            color: colors.outlineVariant.withValues(alpha: 0.7),
          ),

          _TransactionDetailRow(
            icon: Icons.calendar_today_outlined,
            title: 'التاريخ',
            value: _formatDate(date),
            onTap: onDateTap,
          ),

          Divider(
            height: 1,
            color: colors.outlineVariant.withValues(alpha: 0.7),
          ),

          _TransactionDetailRow(
            icon: Icons.edit_note_rounded,
            title: 'إضافة ملاحظة (اختياري)...',
            onTap: onNoteTap,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _TransactionDetailRow extends StatelessWidget {
  const _TransactionDetailRow({
    required this.icon,
    required this.title,
    this.value,
    this.secondaryValue,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? value;
  final String? secondaryValue;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 68,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              // الأيقونة - يمين
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 21,
                  color: colors.onSurfaceVariant,
                ),
              ),

              const SizedBox(width: 12),

              // المحتوى
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (value != null)
                      Text(
                        title,
                        textDirection: TextDirection.rtl,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                      ),

                    Text(
                      value ?? title,
                      textDirection: TextDirection.rtl,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                            color: value == null
                                ? colors.onSurfaceVariant
                                : colors.onSurface,
                            fontWeight: value != null
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                    ),

                    if (secondaryValue != null)
                      Text(
                        secondaryValue!,
                        textDirection: TextDirection.rtl,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                      ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // السهم - يسار
              Icon(
                Icons.chevron_left_rounded,
                color: colors.onSurfaceVariant,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}