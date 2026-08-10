import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/transaction_categories_provider.dart';
import '../../../../shared/components/buttons/primary_button.dart';
import '../../models/transaction_type.dart';
import '../../providers/transaction_type_provider.dart';
import '../../providers/transaction_accounts_provider.dart';
import '../../providers/transaction_repository_provider.dart';
import 'package:go_router/go_router.dart';
import '../../../dashboard/providers/dashboard_provider.dart';
import '../../providers/recent_transactions_with_details_provider.dart';
import '../../../dashboard/providers/dashboard_summary_provider.dart'
    hide transactionRepositoryProvider;
import '../widgets/transaction_header.dart';
import '../../../../shared/components/text_fields/amount_field.dart';
import '../widgets/transaction_category_grid.dart';

class AddTransactionPage extends ConsumerStatefulWidget {
  const AddTransactionPage({super.key});

  @override
  ConsumerState<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends ConsumerState<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();

  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final _noteFocusNode = FocusNode();

  int? _selectedAccountId;
  int? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    _noteFocusNode.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final initialDate = _selectedDate.isAfter(today)
        ? today
        : _selectedDate;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: today,
    );

    if (pickedDate == null) return;

    setState(() {
      _selectedDate = pickedDate;
    });
  }

  Future<void> _showAccountPicker() async {
    final accountsAsync = ref.read(transactionAccountsProvider);
    final accounts = accountsAsync.valueOrNull ?? [];

    if (accounts.isEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'لا توجد حسابات متاحة',
            textDirection: TextDirection.rtl,
          ),
        ),
      );

      return;
    }

    final selectedId = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                Text(
                  'اختر الحساب',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                ...accounts.map((account) {
                  final isSelected = account.id == _selectedAccountId;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      onTap: () {
                        Navigator.pop(context, account.id);
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outlineVariant,
                        ),
                      ),
                      leading: Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      title: Text(account.name, textAlign: TextAlign.right),
                      subtitle: Text(
                        '${account.currentBalance.toStringAsFixed(2)} جنيه',
                        textAlign: TextAlign.right,
                      ),
                      trailing: isSelected
                          ? Icon(
                              Icons.check_circle_rounded,
                              color: Theme.of(context).colorScheme.primary,
                            )
                          : null,
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );

    if (selectedId == null) return;

    setState(() {
      _selectedAccountId = selectedId;
    });
  }

  void _focusNoteField() {
    _noteFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final selectedType = ref.watch(transactionTypeProvider);
    final accountsAsync = ref.watch(transactionAccountsProvider);
    final accounts = accountsAsync.valueOrNull;
    final categoriesAsync = ref.watch(
      transactionCategoriesProvider(selectedType),
    );
    final selectedAccount = accounts
        ?.where((account) => account.id == _selectedAccountId)
        .firstOrNull;

    return Scaffold(
      body: Form(
        key: _formKey,

        child: ListView(
          padding: const EdgeInsets.all(20),

          children: [
            TransactionHeader(
              selectedType: selectedType,
              onTypeChanged: (type) {
                ref.read(transactionTypeProvider.notifier).state = type;

                setState(() {
                  _selectedCategoryId = null;
                });
              },
              onSave: () {
                // هنربطه بزر الحفظ الموجود حاليًا بعدين
              },
            ),

            const SizedBox(height: 28),
            // amount
            const Text(
              'المبلغ',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.normal),
            ),

            const SizedBox(height: 12),

            AmountField(controller: _amountController),
            // =========================
            // categories
            // =========================
            const SizedBox(height: 24),

            const Text(
              'التصنيف',
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
            ),
            const SizedBox(height: 12),
            categoriesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Text(
                'حدث خطأ أثناء تحميل التصنيفات',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              data: (categories) {
                return TransactionCategoryGrid(
                  categories: categories,
                  selectedCategoryId: _selectedCategoryId,
                  onCategorySelected: (categoryId) {
                    setState(() {
                      _selectedCategoryId = categoryId;
                    });
                  },
                );
              },
            ),

            const SizedBox(height: 16),

            // =========================
            // Transaction Details
            // =========================
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  // =========================
                  // Account
                  // =========================
                  InkWell(
                    onTap: _showAccountPicker,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        textDirection: TextDirection.rtl,
                        children: [
                          // Icon - Right
                          _DetailIcon(
                            icon: Icons.account_balance_wallet_rounded,
                          ),

                          const SizedBox(width: 12),

                          // Text - Center
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'الحساب',
                                  textDirection: TextDirection.rtl,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                      ),
                                ),

                                const SizedBox(height: 3),

                                Text(
                                  selectedAccount?.name ?? 'اختر الحساب',
                                  textDirection: TextDirection.rtl,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: selectedAccount == null
                                            ? Theme.of(
                                                context,
                                              ).colorScheme.onSurfaceVariant
                                            : Theme.of(
                                                context,
                                              ).colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Arrow - Left
                          Icon(
                            Icons.chevron_left_rounded,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                            size: 22,
                          ),
                        ],
                      ),
                    ),
                  ),

                  Divider(
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                    color: Theme.of(
                      context,
                    ).colorScheme.outlineVariant.withValues(alpha: 0.6),
                  ),

                  // =========================
                  // Date
                  // =========================
                  InkWell(
                    onTap: _selectDate,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        textDirection: TextDirection.rtl,
                        children: [
                          // Icon - Right
                          _DetailIcon(icon: Icons.calendar_month_outlined),

                          const SizedBox(width: 12),

                          // Text - Center
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'التاريخ',
                                  textDirection: TextDirection.rtl,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                      ),
                                ),

                                const SizedBox(height: 3),

                                Text(
                                  _formatDate(_selectedDate),
                                  textDirection: TextDirection.rtl,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Arrow - Left
                          Icon(
                            Icons.chevron_left_rounded,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                            size: 22,
                          ),
                        ],
                      ),
                    ),
                  ),

                  Divider(
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                    color: Theme.of(
                      context,
                    ).colorScheme.outlineVariant.withValues(alpha: 0.6),
                  ),

                  // =========================
                  // Note
                  // =========================
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      textDirection: TextDirection.rtl,
                      children: [
                        // Icon - Right
                        _DetailIcon(icon: Icons.notes_rounded),

                        const SizedBox(width: 12),

                        // Text Field - Center
                        Expanded(
                          child: TextField(
                            controller: _notesController,
                            focusNode: _noteFocusNode,
                            textAlign: TextAlign.right,
                            textDirection: TextDirection.rtl,
                            maxLines: 1,
                            decoration: InputDecoration(
                              hintText: 'إضافة ملاحظة (اختياري)...',
                              hintTextDirection: TextDirection.rtl,
                              hintStyle: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Arrow - Left
                        Icon(
                          Icons.chevron_left_rounded,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
                        transactionDate: _selectedDate,
                      );
                  // reload the dashboard
                  if (!context.mounted) return;
                  ref.invalidate(dashboardProvider);
                  ref.invalidate(dashboardSummaryProvider);
                  ref.invalidate(recentTransactionsWithDetailsProvider);
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

class _DetailIcon extends StatelessWidget {
  const _DetailIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 22, color: colors.primary),
    );
  }
}
