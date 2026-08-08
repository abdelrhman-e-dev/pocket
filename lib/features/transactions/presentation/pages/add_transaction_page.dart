import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/components/buttons/primary_button.dart';
import '../../../../shared/components/text_fields/app_text_field.dart';
import '../../models/transaction_type.dart';
import '../../providers/transaction_type_provider.dart';
import '../widgets/transaction_type_card.dart';

class AddTransactionPage extends ConsumerStatefulWidget {
  const AddTransactionPage({super.key});

  @override
  ConsumerState<AddTransactionPage> createState() =>
      _AddTransactionPageState();
}

class _AddTransactionPageState
    extends ConsumerState<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();

  final _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedType = ref.watch(transactionTypeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة عملية'),
      ),

      body: Form(
        key: _formKey,

        child: ListView(
          padding: const EdgeInsets.all(20),

          children: [
            const Text(
              'نوع العملية',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                TransactionTypeCard(
                  title: 'مصروف',
                  icon: Icons.arrow_downward_rounded,
                  selected:
                      selectedType == TransactionType.expense,
                  onTap: () {
                    ref
                        .read(transactionTypeProvider.notifier)
                        .state = TransactionType.expense;
                  },
                ),

                const SizedBox(width: 12),

                TransactionTypeCard(
                  title: 'دخل',
                  icon: Icons.arrow_upward_rounded,
                  selected:
                      selectedType == TransactionType.income,
                  onTap: () {
                    ref
                        .read(transactionTypeProvider.notifier)
                        .state = TransactionType.income;
                  },
                ),
              ],
            ),

            const SizedBox(height: 28),

            const Text(
              'المبلغ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            AppTextField(
              controller: _amountController,
              hint: 'مثال: 150',
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
              suffixText: 'جنيه',

              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'من فضلك أدخل المبلغ';
                }

                final amount =
                    double.tryParse(value.trim());

                if (amount == null) {
                  return 'من فضلك أدخل رقمًا صحيحًا';
                }

                if (amount <= 0) {
                  return 'المبلغ يجب أن يكون أكبر من صفر';
                }

                return null;
              },
            ),

            const SizedBox(height: 40),

            PrimaryButton(
              text: 'متابعة',
              onPressed: () {
                if (!_formKey.currentState!.validate()) {
                  return;
                }

                final amount = double.parse(
                  _amountController.text.trim(),
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      selectedType == TransactionType.expense
                          ? 'مصروف: $amount جنيه'
                          : 'دخل: $amount جنيه',
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}