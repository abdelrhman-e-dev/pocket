import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/database/app_database.dart';
import '../../../../shared/components/app_top_bar.dart';
import '../../models/holding_type.dart';
import '../../providers/holdings_providers.dart';

class HoldingFormPage extends ConsumerStatefulWidget {
  const HoldingFormPage({super.key, this.holding});
  final Holding? holding;

  @override
  ConsumerState<HoldingFormPage> createState() => _HoldingFormPageState();
}

class _HoldingFormPageState extends ConsumerState<HoldingFormPage> {
  late final TextEditingController _amountController;
  late final TextEditingController _labelController;
  late HoldingType _type;
  late int _karat;

  @override
  void initState() {
    super.initState();
    final holding = widget.holding;
    _type = holding?.type == HoldingType.gold.value ? HoldingType.gold : HoldingType.usd;
    _karat = holding?.goldKarat ?? 24;
    _amountController = TextEditingController(text: holding?.amount.toString() ?? '');
    _labelController = TextEditingController(text: holding?.label ?? '');
  }

  @override
  void dispose() {
    _amountController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amountController.text.replaceAll(',', '.'));
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('أدخل قيمة أكبر من صفر')));
      return;
    }
    await ref.read(holdingsRepositoryProvider).saveHolding(
          id: widget.holding?.id,
          type: _type.value,
          amount: amount,
          goldKarat: _type == HoldingType.gold ? _karat : null,
          label: _labelController.text,
        );
    ref.invalidate(latestRateProvider);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final rate = ref.watch(latestRateProvider).valueOrNull;
    final amount = double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 0;
    final preview = rate == null ? null : holdingValue(
      Holding(
        id: 0,
        type: _type.value,
        amount: amount,
        goldKarat: _type == HoldingType.gold ? _karat : null,
        label: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      rate,
    );
    return Scaffold(
      appBar: AppTopBar(
        title: widget.holding == null ? 'إضافة مدخر' : 'تعديل المدخر',
        leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back_rounded)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SegmentedButton<HoldingType>(
            segments: const [
              ButtonSegment(value: HoldingType.usd, label: Text('دولار'), icon: Icon(Icons.attach_money)),
              ButtonSegment(value: HoldingType.gold, label: Text('ذهب'), icon: Icon(Icons.workspace_premium_outlined)),
            ],
            selected: {_type},
            onSelectionChanged: (selected) => setState(() => _type = selected.first),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _amountController,
            onChanged: (_) => setState(() {}),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: _type == HoldingType.gold ? 'الوزن بالجرام' : 'المبلغ بالدولار',
              suffixText: _type == HoldingType.gold ? 'جم' : 'USD',
              border: const OutlineInputBorder(),
            ),
          ),
          if (_type == HoldingType.gold) ...[
            const SizedBox(height: 20),
            DropdownButtonFormField<int>(
              initialValue: _karat,
              decoration: const InputDecoration(labelText: 'العيار', border: OutlineInputBorder()),
              items: [18, 21, 24].map((karat) => DropdownMenuItem(value: karat, child: Text('عيار $karat'))).toList(),
              onChanged: (value) => setState(() => _karat = value ?? 24),
            ),
          ],
          const SizedBox(height: 20),
          TextField(
            controller: _labelController,
            decoration: const InputDecoration(labelText: 'ملاحظة (اختياري)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 24),
          if (preview != null)
            Text('القيمة الحالية: ${preview.toStringAsFixed(2)} جنيه', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 28),
          FilledButton.icon(onPressed: _save, icon: const Icon(Icons.check_rounded), label: const Text('حفظ')),
        ],
      ),
    );
  }
}