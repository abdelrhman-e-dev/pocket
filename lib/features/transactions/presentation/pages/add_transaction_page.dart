import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/transaction_categories_provider.dart';
import '../widgets/category_selector.dart';
import '../../../../shared/components/buttons/primary_button.dart';
import '../../../../shared/components/text_fields/app_text_field.dart';
import '../../models/transaction_type.dart';
import '../../providers/transaction_type_provider.dart';
import '../widgets/transaction_type_card.dart';
import '../../providers/transaction_accounts_provider.dart';
import '../widgets/account_selector.dart';
import '../../providers/transaction_repository_provider.dart';
import 'package:go_router/go_router.dart';
import '../../../dashboard/providers/dashboard_provider.dart';
import '../../providers/recent_transactions_provider.dart';
class AddTransactionPage extends ConsumerStatefulWidget {
  const AddTransactionPage({super.key});

  @override
  ConsumerState<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends ConsumerState<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();

  final _amountController = TextEditingController();
  int? _selectedAccountId;
  int? _selectedCategoryId;
  final _notesController = TextEditingController();
  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedType = ref.watch(transactionTypeProvider);
    final accountsAsync = ref.watch(transactionAccountsProvider);
    final categoriesAsync = ref.watch(
      transactionCategoriesProvider(selectedType),
    );

    DateTime selectedDate = DateTime.now();
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة عملية')),

      body: Form(
        key: _formKey,

        child: ListView(
          padding: const EdgeInsets.all(20),

          children: [
            const Text(
              'نوع العملية',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                TransactionTypeCard(
                  title: 'مصروف',
                  icon: Icons.arrow_downward_rounded,
                  selected: selectedType == TransactionType.expense,
                  onTap: () {
                    ref.read(transactionTypeProvider.notifier).state =
                        TransactionType.expense;

                    setState(() {
                      _selectedCategoryId = null;
                    });
                  },
                ),

                const SizedBox(width: 12),

                TransactionTypeCard(
                  title: 'دخل',
                  icon: Icons.arrow_upward_rounded,
                  selected: selectedType == TransactionType.income,
                  onTap: () {
                    ref.read(transactionTypeProvider.notifier).state =
                        TransactionType.income;

                    setState(() {
                      _selectedCategoryId = null;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 28),
            // amount
            const Text('المبلغ', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            // amount text field
            AppTextField(
              controller: _amountController,
              hint: 'مثال: 150',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              suffixText: 'جنيه',

              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'من فضلك أدخل المبلغ';
                }

                final amount = double.tryParse(value.trim());

                if (amount == null) {
                  return 'من فضلك أدخل رقمًا صحيحًا';
                }

                if (amount <= 0) {
                  return 'المبلغ يجب أن يكون أكبر من صفر';
                }

                return null;
              },
            ),
            // account
            const SizedBox(height: 24),
            const Text('الحساب', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            accountsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),

              error: (error, stackTrace) => Text(
                'حدث خطأ أثناء تحميل الحسابات',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),

              data: (accounts) {
                if (accounts.isEmpty) {
                  return const Text('لا يوجد حسابات متاحة');
                }

                return AccountSelector(
                  accounts: accounts,
                  selectedAccountId: _selectedAccountId,
                  onChanged: (value) {
                    setState(() {
                      _selectedAccountId = value;
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 24),

            const Text(
              'التصنيف',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            categoriesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),

              error: (error, stackTrace) => Text(
                'حدث خطأ أثناء تحميل التصنيفات',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),

              data: (categories) {
                if (categories.isEmpty) {
                  return const Text('لا توجد تصنيفات');
                }

                return CategorySelector(
                  categories: categories,
                  selectedCategoryId: _selectedCategoryId,
                  onChanged: (value) {
                    setState(() {
                      _selectedCategoryId = value;
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 24),
            // date
            const Text(
              'التاريخ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );

                if (date == null) return;

                setState(() {
                  selectedDate = date;
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                ),
                child: Text(
                  '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                ),
              ),
            ),
            const SizedBox(height: 8),
            // notes
            const SizedBox(height: 24),
            const Text(
              'ملاحظات',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            AppTextField(
              controller: _notesController,
              hint: 'أدخل ملاحظاتك هنا',
              maxLines: 3,
            ),
            const SizedBox(height: 40),
            PrimaryButton(
              text: 'متابعة',
              onPressed: () async {
                if (!_formKey.currentState!.validate()) {
                  return;
                }

                if (_selectedAccountId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('من فضلك اختر الحساب')),
                  );

                  return;
                }

                if (_selectedCategoryId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('من فضلك اختر التصنيف')),
                  );

                  return;
                }

                final amount = double.parse(_amountController.text.trim());

                final type = selectedType == TransactionType.expense
                    ? 'expense'
                    : 'income';

                final note = _notesController.text.trim();

                try {
                  await ref
                      .read(transactionRepositoryProvider)
                      .createTransaction(
                        accountId: _selectedAccountId!,
                        categoryId: _selectedCategoryId!,
                        type: type,
                        amount: amount,
                        note: note.isEmpty ? null : note,
                        transactionDate: selectedDate,
                      );
                  // reload the dashboard
                  if (!context.mounted) return;
                  ref.invalidate(dashboardProvider);
                  ref.invalidate(recentTransactionsProvider);
                  // return to dashboard
                  context.pop();
                } catch (e) {
                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('حدث خطأ أثناء حفظ العملية')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
