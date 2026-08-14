import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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

          appBar: AppBar(
            title: const Text('الحسابات'),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () {
                context.go('/dashboard');
              },
            ),
          ),

          body: accountsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),

            error: (error, stackTrace) => Center(
              child: Text(
                'حدث خطأ أثناء تحميل الحسابات',
                style: TextStyle(color: colors.error),
              ),
            ),

            data: (accounts) {
              if (accounts.isEmpty) {
                return _EmptyAccounts(
                  onAdd: () async {
                    await context.push('/create-account');

                    ref.invalidate(accountsProvider);
                  },
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(accountsProvider);
                  await ref.read(accountsProvider.future);
                },

                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    ...accounts.map(
                      (account) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _AccountCard(
                          name: account.name,
                          balance: account.currentBalance,
                          color: Color(account.color),
                          icon: account.icon,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await context.push('/create-account');

                          ref.invalidate(accountsProvider);
                        },
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('إضافة حساب'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({
    required this.name,
    required this.balance,
    required this.color,
    required this.icon,
  });

  final String name;
  final double balance;
  final Color color;
  final String icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.account_balance_wallet_rounded,
              color: color,
              size: 25,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  'الرصيد الحالي',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          Text(
            '${balance.toStringAsFixed(0)} ج.م',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: balance < 0 ? colors.error : colors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyAccounts extends StatelessWidget {
  const _EmptyAccounts({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_balance_wallet_outlined, size: 64),

            const SizedBox(height: 20),

            Text(
              'لا توجد حسابات',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            const Text('أضف حسابًا جديدًا للبدء', textAlign: TextAlign.center),

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
