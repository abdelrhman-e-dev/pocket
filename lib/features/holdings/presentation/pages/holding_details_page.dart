import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/database/app_database.dart';
import '../../../../shared/components/app_top_bar.dart';
import '../../providers/holdings_providers.dart';

class HoldingDetailsPage extends ConsumerWidget {
  const HoldingDetailsPage({super.key, required this.holding});
  final Holding holding;

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المدخر؟'),
        content: const Text('سيتم حذف هذا المدخر نهائيًا.'),
        actions: [
          TextButton(onPressed: () => context.pop(false), child: const Text('إلغاء')),
          FilledButton(onPressed: () => context.pop(true), child: const Text('حذف')),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(holdingsRepositoryProvider).deleteHolding(holding.id);
    ref.invalidate(holdingsProvider);
    if (context.mounted) context.go('/holdings');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rate = ref.watch(latestRateProvider).valueOrNull;
    final currentValue = rate == null ? null : holdingValue(holding, rate);
    final isGold = holding.type == 'gold';
    return Scaffold(
      appBar: AppTopBar(
        title: 'تفاصيل المدخر',
        leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back_rounded)),
        actions: [
          IconButton(tooltip: 'تعديل', onPressed: () => context.push('/holdings/edit', extra: holding), icon: const Icon(Icons.edit_outlined)),
          IconButton(tooltip: 'حذف', onPressed: () => _delete(context, ref), icon: const Icon(Icons.delete_outline_rounded)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(holding.label?.isNotEmpty == true ? holding.label! : (isGold ? 'ذهب' : 'دولار'), style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 20),
          _InfoRow(title: 'النوع', value: isGold ? 'ذهب' : 'دولار'),
          _InfoRow(title: isGold ? 'الوزن' : 'المبلغ', value: isGold ? '${holding.amount} جم' : '${holding.amount} USD'),
          if (isGold) _InfoRow(title: 'العيار', value: '${holding.goldKarat}'),
          _InfoRow(title: 'تاريخ الإضافة', value: DateFormat('dd/MM/yyyy').format(holding.createdAt)),
          const Divider(height: 32),
          Text('القيمة الحالية', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(currentValue == null ? '—' : '${currentValue.toStringAsFixed(2)} جنيه', style: Theme.of(context).textTheme.headlineMedium),
          if (rate != null) Text('بحسب آخر سعر تحديث: ${DateFormat('dd/MM/yyyy HH:mm').format(rate.fetchedAt)}'),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.title, required this.value});
  final String title;
  final String value;
  @override
  Widget build(BuildContext context) => ListTile(contentPadding: EdgeInsets.zero, title: Text(title), trailing: Text(value));
}