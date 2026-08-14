import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/transaction_categories_provider.dart';
import '../../../../shared/components/buttons/primary_button.dart';
import '../../models/transaction_type.dart';
import '../../providers/transaction_type_provider.dart';
import '../../providers/transaction_accounts_provider.dart';
import '../../providers/transaction_repository_provider.dart' as repo;
import 'package:go_router/go_router.dart';
import '../../../dashboard/providers/dashboard_provider.dart';
import '../../../dashboard/providers/dashboard_summary_provider.dart'
    hide transactionRepositoryProvider;
import '../widgets/transaction_header.dart';
import '../../../../shared/components/text_fields/amount_field.dart';
import '../widgets/transaction_category_grid.dart';
import '../../providers/all_transactions_provider.dart';
import '../../models/transaction_with_details.dart';
import '../../providers/paginated_transactions_provider.dart';
import '../../../transfers/providers/transfer_repository_provider.dart';

class AddTransactionPage extends ConsumerStatefulWidget {
  const AddTransactionPage({super.key, this.transaction});

  final TransactionWithDetails? transaction;

  @override
  ConsumerState<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends ConsumerState<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  bool get isEditMode => widget.transaction != null;
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final _noteFocusNode = FocusNode();

  int? _selectedAccountId;
  int? _selectedToAccountId;
  int? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();
  bool get isTransfer {
    final type = ref.read(transactionTypeProvider);

    return type == TransactionType.transfer;
  }

  @override
  void initState() {
    super.initState();

    final transaction = widget.transaction;

    if (transaction != null) {
      _amountController.text = transaction.transaction.amount.toString();

      _selectedAccountId = transaction.transaction.accountId;

      _selectedCategoryId = transaction.transaction.categoryId;

      _selectedDate = transaction.transaction.transactionDate;

      _notesController.text = transaction.transaction.note ?? '';

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        ref
            .read(transactionTypeProvider.notifier)
            .state = transaction.transaction.type == 'expense'
            ? TransactionType.expense
            : TransactionType.income;
      });
    }
  }

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

    final today = DateTime(now.year, now.month, now.day);

    final initialDate = _selectedDate.isAfter(today) ? today : _selectedDate;

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

    final selectedToAccount = accounts
        ?.where((account) => account.id == _selectedToAccountId)
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
                  _selectedAccountId = null;
                  _selectedToAccountId = null;
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
            if (!isTransfer) ...[
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
            ],

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
                  if (isTransfer) ...[
                    InkWell(
                      onTap: () => _showAccountPicker(isFromAccount: true),
                      child: _AccountDetailRow(
                        icon: Icons.arrow_upward_rounded,
                        title: 'من الحساب',
                        value: selectedAccount?.name ?? 'اختر الحساب',
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

                    InkWell(
                      onTap: () => _showAccountPicker(isFromAccount: false),
                      child: _AccountDetailRow(
                        icon: Icons.arrow_downward_rounded,
                        title: 'إلى الحساب',
                        value: selectedToAccount?.name ?? 'اختر الحساب',
                      ),
                    ),
                  ] else ...[
                    // بلوك الحساب الحالي كما هو
                  ],

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

                if (selectedType == TransactionType.transfer) {
                  if (_selectedToAccountId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('من فضلك اختر الحساب المستلم'),
                      ),
                    );

                    return;
                  }

                  if (_selectedAccountId == _selectedToAccountId) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('لا يمكن التحويل إلى نفس الحساب'),
                      ),
                    );

                    return;
                  }
                } else {
                  if (_selectedCategoryId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('من فضلك اختر التصنيف')),
                    );

                    return;
                  }
                }

                final amount = double.parse(_amountController.text.trim());

                final type = selectedType == TransactionType.expense
                    ? 'expense'
                    : 'income';

                final note = _notesController.text.trim();

                try {
                  if (selectedType == TransactionType.transfer) {
                    final transferRepository = ref.read(
                      transferRepositoryProvider,
                    );

                    await transferRepository.createTransfer(
                      fromAccountId: _selectedAccountId!,
                      toAccountId: _selectedToAccountId!,
                      amount: amount,
                      note: note.isEmpty ? null : note,
                      transferDate: _selectedDate,
                    );
                  } else {
                    final repository = ref.read(
                      repo.transactionRepositoryProviderPage,
                    );

                    if (isEditMode) {
                      await repository.updateTransaction(
                        transactionId: widget.transaction!.transaction.id,
                        accountId: _selectedAccountId!,
                        categoryId: _selectedCategoryId!,
                        type: type,
                        amount: amount,
                        note: note.isEmpty ? null : note,
                        transactionDate: _selectedDate,
                      );
                    } else {
                      await repository.createTransaction(
                        accountId: _selectedAccountId!,
                        categoryId: _selectedCategoryId!,
                        type: type,
                        amount: amount,
                        note: note.isEmpty ? null : note,
                        transactionDate: _selectedDate,
                      );
                    }
                  }

                  if (!context.mounted) return;

                  ref.invalidate(dashboardProvider);
                  ref.invalidate(dashboardSummaryProvider);
                  ref.invalidate(transactionAccountsProvider);
                  ref.invalidate(allTransactionsWithDetailsProvider);
                  ref.invalidate(paginatedTransactionsProvider);
                  ref.invalidate(transferRepositoryProvider);
                  context.go('/transactions');
                } catch (e) {
                  if (!context.mounted) return;

                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('خطأ: $e')));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAccountPicker({required bool isFromAccount}) async {
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
                  isFromAccount ? 'اختر حساب المصدر' : 'اختر الحساب المستلم',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                ...accounts.map((account) {
                  final selectedId = isFromAccount
                      ? _selectedAccountId
                      : _selectedToAccountId;

                  final isSelected = account.id == selectedId;

                  // في التحويل لا نسمح بنفس الحساب
                  final otherAccountId = isFromAccount
                      ? _selectedToAccountId
                      : _selectedAccountId;

                  final isDisabled = account.id == otherAccountId;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      enabled: !isDisabled,

                      onTap: isDisabled
                          ? null
                          : () {
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
                        color: isDisabled
                            ? Theme.of(context).colorScheme.onSurfaceVariant
                            : Theme.of(context).colorScheme.primary,
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
      if (isFromAccount) {
        _selectedAccountId = selectedId;
      } else {
        _selectedToAccountId = selectedId;
      }
    });
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

class _AccountDetailRow extends StatelessWidget {
  const _AccountDetailRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          _DetailIcon(icon: icon),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 3),

                Text(
                  value,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          Icon(Icons.chevron_left_rounded, color: colors.onSurfaceVariant),
        ],
      ),
    );
  }
}
