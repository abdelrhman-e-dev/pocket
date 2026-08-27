import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/database/app_database.dart';
import '../../../../shared/components/app_top_bar.dart';
import '../../models/holding_type.dart';
import '../../providers/holdings_providers.dart';

class HoldingsPage extends ConsumerWidget {
  const HoldingsPage({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    try {
      await ref.read(ratesRepositoryProvider).fetchAndSave();
      ref.invalidate(latestRateProvider);
    } catch (_) {
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final holdingsAsync = ref.watch(holdingsProvider);
    final rateAsync = ref.watch(latestRateProvider);
    final rate = rateAsync.valueOrNull;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppTopBar(
        title: 'المدخرات',
        subtitle: 'دولار وذهب خارج الحسابات',
        leading: IconButton(
          tooltip: 'رجوع',
          onPressed: () => context.go('/dashboard'),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        actions: [
          IconButton(
            tooltip: 'تحديث الأسعار',
            onPressed: () => _refresh(ref),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/holdings/add'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('إضافة'),
      ),
      body: holdingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('تعذر تحميل المدخرات')),
        data: (holdings) {
          final total = holdings.fold<double>(
            0,
            (sum, holding) => sum + holdingValue(holding, rate),
          );
          return RefreshIndicator(
            onRefresh: () => _refresh(ref),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              children: [
                _SummaryCard(total: total, rate: rate),
                const SizedBox(height: 24),
                if (holdings.isEmpty)
                  _EmptyHoldings(onAdd: () => context.push('/holdings/add'))
                else
                  ...holdings.map(
                    (holding) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _HoldingTile(
                        holding: holding,
                        value: rate == null ? null : holdingValue(holding, rate),
                        onTap: () => context.push(
                          '/holdings/details',
                          extra: holding,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.total, required this.rate});

  final double total;
  final RateSnapshot? rate;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('إجمالي قيمة المدخرات', style: TextStyle(color: colors.onPrimaryContainer)),
          const SizedBox(height: 8),
          Text(
            rate == null ? '—' : '${total.toStringAsFixed(2)} جنيه',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: colors.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            rate == null
                ? 'بانتظار الاتصال بالإنترنت لجلب الأسعار'
                : 'آخر تحديث: ${DateFormat('dd/MM/yyyy - HH:mm').format(rate!.fetchedAt)}',
            style: TextStyle(color: colors.onPrimaryContainer.withValues(alpha: .75)),
          ),
        ],
      ),
    );
  }
}

class _HoldingTile extends StatelessWidget {
  const _HoldingTile({required this.holding, required this.value, required this.onTap});

  final Holding holding;
  final double? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isGold = holding.type == HoldingType.gold.value;
    final raw = isGold
        ? '${holding.amount} جم عيار ${holding.goldKarat}'
        : '${holding.amount} دولار';
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      tileColor: colors.surfaceContainerLow,
      leading: CircleAvatar(
        backgroundColor: isGold ? Colors.amber.shade100 : colors.secondaryContainer,
        child: Icon(isGold ? Icons.workspace_premium_rounded : Icons.attach_money_rounded),
      ),
      title: Text(holding.label?.isNotEmpty == true ? holding.label! : (isGold ? 'ذهب' : 'دولار')),
      subtitle: Text(raw),
      trailing: Text(
        value == null ? '—' : '${value!.toStringAsFixed(2)} جنيه',
        style: TextStyle(fontWeight: FontWeight.bold, color: colors.primary),
      ),
    );
  }
}

class _EmptyHoldings extends StatelessWidget {
  const _EmptyHoldings({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          children: [
            const SizedBox(height: 48),
            const Icon(Icons.savings_outlined, size: 56),
            const SizedBox(height: 12),
            const Text('لا توجد مدخرات بعد'),
            const SizedBox(height: 16),
            OutlinedButton.icon(onPressed: onAdd, icon: const Icon(Icons.add), label: const Text('إضافة مدخر')),
          ],
        ),
      );
}