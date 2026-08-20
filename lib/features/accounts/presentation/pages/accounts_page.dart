import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/components/app_top_bar.dart';
import '../../../../shared/components/navigation/app_bottom_navigation.dart';
import '../../providers/account_repository_provider.dart';

class AccountsPage extends ConsumerWidget {
  const AccountsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final accountsAsync = ref.watch(accountsProvider);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;

          context.go('/dashboard');
        },

        child: Scaffold(
          backgroundColor: colors.surface,

          appBar: AppTopBar(
            title: 'الحسابات',
            subtitle: 'إدارة أموالك وحساباتك',
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () {
                context.go('/dashboard');
              },
            ),

            actions: [
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 12),
                child: IconButton.filledTonal(
                  tooltip: 'إضافة حساب',
                  onPressed: () async {
                    await context.push('/create-account');

                    ref.invalidate(accountsProvider);
                  },
                  icon: const Icon(Icons.add_rounded),
                ),
              ),
            ],
          ),

          body: accountsAsync.when(
            loading: () {
              return const Center(child: CircularProgressIndicator());
            },

            error: (error, stackTrace) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 48,
                        color: colors.error,
                      ),

                      const SizedBox(height: 12),

                      Text(
                        'حدث خطأ أثناء تحميل الحسابات',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),

                      const SizedBox(height: 16),

                      FilledButton.icon(
                        onPressed: () {
                          ref.invalidate(accountsProvider);
                        },
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                ),
              );
            },

            data: (accounts) {
              if (accounts.isEmpty) {
                return _EmptyAccounts(
                  onAdd: () async {
                    await context.push('/create-account');

                    ref.invalidate(accountsProvider);
                  },
                );
              }

              final totalBalance = accounts.fold<double>(
                0,
                (sum, account) => sum + account.currentBalance,
              );

              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(accountsProvider);

                  await ref.read(accountsProvider.future);
                },

                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),

                  children: [
                    // ==========================================
                    // Total Balance
                    // ==========================================
                    _TotalBalanceCard(
                      totalBalance: totalBalance,
                      accountsCount: accounts.length,
                    ),

                    const SizedBox(height: 28),

                    // ==========================================
                    // Section Header
                    // ==========================================
                    Row(
                      children: [
                        Text(
                          'حساباتك',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),

                        const Spacer(),

                        Text(
                          '${accounts.length} حساب',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: colors.onSurfaceVariant),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // ==========================================
                    // Accounts
                    // ==========================================
                    ...accounts.map((account) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            context.push('/accounts/details', extra: account);
                          },
                          child: _AccountCard(
                            name: account.name,
                            type: account.type,
                            balance: account.currentBalance,
                            color: Color(account.color),
                            icon: account.icon,
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 8),

                    // ==========================================
                    // Add Account
                    // ==========================================
                    SizedBox(
                      height: 54,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await context.push('/create-account');

                          ref.invalidate(accountsProvider);
                        },
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('إضافة حساب جديد'),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ==========================================
                    // Hint
                    // ==========================================
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline_rounded,
                            size: 20,
                            color: colors.primary,
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: Text(
                              'يمكنك استخدام التحويلات لنقل الأموال بين حساباتك بسهولة.',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: colors.onSurfaceVariant),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          bottomNavigationBar: const AppBottomNavigation(),
        ),
      ),
    );
  }
}

// ============================================================
// Total Balance Card
// ============================================================

class _TotalBalanceCard extends StatelessWidget {
  const _TotalBalanceCard({
    required this.totalBalance,
    required this.accountsCount,
  });

  final double totalBalance;
  final int accountsCount;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final isNegative = totalBalance < 0;
    return Container(
      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(24),
      ),

      child: Column(
        children: [
          Text(
            'إجمالي رصيدك',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colors.onPrimary.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            '${totalBalance.toStringAsFixed(2)} جنيه',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: colors.onPrimary,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.2,
            ),
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),

            decoration: BoxDecoration(
              color: colors.onPrimary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),

            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isNegative
                      ? Icons.trending_down_rounded
                      : Icons.account_balance_wallet_rounded,
                  size: 16,
                  color: colors.onPrimary,
                ),

                const SizedBox(width: 6),

                Text(
                  '$accountsCount حساب نشط',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colors.onPrimary,
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

// ============================================================
// Account Card
// ============================================================

class _AccountCard extends StatelessWidget {
  const _AccountCard({
    required this.name,
    required this.type,
    required this.balance,
    required this.color,
    required this.icon,
  });

  final String name;
  final String type;
  final double balance;
  final Color color;
  final String icon;

  String _getAccountTypeName() {
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

  IconData _getAccountIcon() {
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
    final isNegative = balance < 0;

    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),

        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.6)),
      ),

      child: Row(
        children: [
          // ==========================================
          // Icon
          // ==========================================
          Container(
            width: 52,
            height: 52,

            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),

            child: Icon(_getAccountIcon(), color: color, size: 25),
          ),

          const SizedBox(width: 14),

          // ==========================================
          // Name + Type
          // ==========================================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,

                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  _getAccountTypeName(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,

                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // ==========================================
          // Balance
          // ==========================================
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'الرصيد',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                '${balance.toStringAsFixed(2)} جنيه',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isNegative ? colors.error : colors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Empty State
// ============================================================

class _EmptyAccounts extends StatelessWidget {
  const _EmptyAccounts({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,

              decoration: BoxDecoration(
                color: colors.primaryContainer,
                shape: BoxShape.circle,
              ),

              child: Icon(
                Icons.account_balance_wallet_rounded,
                size: 42,
                color: colors.primary,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'لا توجد حسابات',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              'أضف حسابك الأول لبدء إدارة أموالك ومتابعة أرصدتك.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
            ),

            const SizedBox(height: 24),

            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: const Text('إضافة حساب'),
            ),
          ],
        ),
      ),
    );
  }
}
