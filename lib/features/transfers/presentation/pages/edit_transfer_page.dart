import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/transfer_with_details.dart';
import '../../providers/transfer_repository_provider.dart';

import '../../../accounts/providers/account_repository_provider.dart';
import '../../../transactions/providers/transaction_accounts_provider.dart';

import '../../../dashboard/providers/dashboard_provider.dart';
import '../../../dashboard/providers/dashboard_summary_provider.dart';

import '../../../transactions/providers/all_transactions_provider.dart';
import '../../../transactions/providers/paginated_transactions_provider.dart';
import '../../../transactions/providers/activity_provider.dart';

class EditTransferPage extends ConsumerStatefulWidget {
  const EditTransferPage({
    super.key,
    required this.transfer,
  });

  final TransferWithDetails transfer;

  @override
  ConsumerState<EditTransferPage> createState() =>
      _EditTransferPageState();
}

class _EditTransferPageState
    extends ConsumerState<EditTransferPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _amountController;
  late final TextEditingController _noteController;

  late int _fromAccountId;
  late int _toAccountId;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();

    final transfer = widget.transfer;

    _fromAccountId = transfer.fromAccount.id;
    _toAccountId = transfer.toAccount.id;
    _selectedDate = transfer.transfer.transferDate;

    _amountController = TextEditingController(
      text: transfer.transfer.amount.toString(),
    );

    _noteController = TextEditingController(
      text: transfer.transfer.note ?? '',
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
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

    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: today,
    );

    if (selected == null) return;

    setState(() {
      _selectedDate = selected;
    });
  }

  Future<void> _showAccountPicker({
    required bool isFromAccount,
  }) async {
    final accountsAsync =
        ref.read(transactionAccountsProvider);

    final accounts = accountsAsync.valueOrNull ?? [];

    if (accounts.isEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لا توجد حسابات متاحة'),
        ),
      );

      return;
    }

    final currentSelectedId =
        isFromAccount ? _fromAccountId : _toAccountId;

    final otherAccountId =
        isFromAccount ? _toAccountId : _fromAccountId;

    final selectedId =
        await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      backgroundColor:
          Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (sheetContext) {
        final colors =
            Theme.of(sheetContext).colorScheme;

        return SafeArea(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(
                16,
                8,
                16,
                24,
              ),
              children: [
                Text(
                  isFromAccount
                      ? 'اختر حساب المصدر'
                      : 'اختر الحساب المستلم',
                  textAlign: TextAlign.center,
                  style: Theme.of(sheetContext)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),

                const SizedBox(height: 16),

                ...accounts.map((account) {
                  final isSelected =
                      account.id == currentSelectedId;

                  final isDisabled =
                      account.id == otherAccountId;

                  return Padding(
                    padding:
                        const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      enabled: !isDisabled,

                      onTap: isDisabled
                          ? null
                          : () {
                              Navigator.pop(
                                sheetContext,
                                account.id,
                              );
                            },

                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(14),
                        side: BorderSide(
                          color: isSelected
                              ? colors.primary
                              : colors.outlineVariant,
                        ),
                      ),

                      leading: Icon(
                        Icons
                            .account_balance_wallet_rounded,
                        color: isDisabled
                            ? colors.onSurfaceVariant
                            : colors.primary,
                      ),

                      title: Text(
                        account.name,
                        textAlign: TextAlign.right,
                      ),

                      subtitle: Text(
                        '${account.currentBalance.toStringAsFixed(2)} جنيه',
                        textAlign: TextAlign.right,
                      ),

                      trailing: isSelected
                          ? Icon(
                              Icons.check_circle_rounded,
                              color: colors.primary,
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
        _fromAccountId = selectedId;
      } else {
        _toAccountId = selectedId;
      }
    });
  }

  Future<void> _updateTransfer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final amount = double.tryParse(
      _amountController.text.trim(),
    );

    if (amount == null || amount <= 0) {
      _showMessage('من فضلك أدخل مبلغًا صحيحًا');
      return;
    }

    if (_fromAccountId == _toAccountId) {
      _showMessage(
        'لا يمكن التحويل إلى نفس الحساب',
      );
      return;
    }

    final note = _noteController.text.trim();

    try {
      await ref
          .read(transferRepositoryProvider)
          .updateTransfer(
            transferId: widget.transfer.transfer.id,
            fromAccountId: _fromAccountId,
            toAccountId: _toAccountId,
            amount: amount,
            note: note.isEmpty ? null : note,
            transferDate: _selectedDate,
          );

      // ==========================================================
      // Refresh
      // ==========================================================

      ref.invalidate(dashboardProvider);
      ref.invalidate(dashboardSummaryProvider);

      ref.invalidate(accountRepositoryProvider);
      ref.invalidate(transactionAccountsProvider);

      ref.invalidate(allTransactionsWithDetailsProvider);
      ref.invalidate(paginatedTransactionsProvider);

      ref.invalidate(activityProvider);
      ref.invalidate(transferRepositoryProvider);

      if (!mounted) return;

      context.pop(true);
    } catch (e) {
      if (!mounted) return;

      final message =
          e.toString().contains('الرصيد غير كافٍ')
              ? 'الرصيد غير كافٍ لإتمام التعديل'
              : e.toString().contains('نفس الحساب')
                  ? 'لا يمكن التحويل إلى نفس الحساب'
                  : 'حدث خطأ أثناء تعديل التحويل';

      _showMessage(message);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textDirection: TextDirection.rtl,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors =
        Theme.of(context).colorScheme;

    final accountsAsync =
        ref.watch(transactionAccountsProvider);

    final accounts =
        accountsAsync.valueOrNull ?? [];

    final fromAccount = accounts
        .where(
          (account) =>
              account.id == _fromAccountId,
        )
        .firstOrNull;

    final toAccount = accounts
        .where(
          (account) =>
              account.id == _toAccountId,
        )
        .firstOrNull;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: colors.surface,

        appBar: AppBar(
          title: const Text('تعديل التحويل'),
          centerTitle: true,

          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
            ),
            onPressed: () {
              context.pop();
            },
          ),
        ),

        body: Form(
          key: _formKey,

          child: ListView(
            padding: const EdgeInsets.all(20),

            children: [
              // ==================================================
              // Header
              // ==================================================

              Container(
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color:
                      colors.surfaceContainerLow,
                  borderRadius:
                      BorderRadius.circular(20),
                ),

                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,

                      decoration: BoxDecoration(
                        color:
                            colors.primaryContainer,
                        shape: BoxShape.circle,
                      ),

                      child: Icon(
                        Icons.swap_horiz_rounded,
                        size: 30,
                        color: colors.primary,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'تعديل التحويل',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ==================================================
              // From Account
              // ==================================================

              const Text(
                'من الحساب',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              InkWell(
                onTap: () {
                  _showAccountPicker(
                    isFromAccount: true,
                  );
                },

                borderRadius:
                    BorderRadius.circular(14),

                child: Container(
                  padding:
                      const EdgeInsets.all(16),

                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius:
                        BorderRadius.circular(14),
                    border: Border.all(
                      color:
                          colors.outlineVariant,
                    ),
                  ),

                  child: Row(
                    children: [
                      Icon(
                        Icons
                            .account_balance_wallet_rounded,
                        color: colors.primary,
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              fromAccount?.name ??
                                  'اختر الحساب',
                              style: const TextStyle(
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),

                            if (fromAccount != null)
                              Text(
                                '${fromAccount.currentBalance.toStringAsFixed(2)} جنيه',
                                style: TextStyle(
                                  color: colors
                                      .onSurfaceVariant,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),

                      Icon(
                        Icons.chevron_left_rounded,
                        color:
                            colors.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ==================================================
              // Amount
              // ==================================================

              TextFormField(
                controller: _amountController,

                keyboardType:
                    const TextInputType.numberWithOptions(
                  decimal: true,
                ),

                decoration:
                    const InputDecoration(
                  labelText: 'المبلغ',
                  border:
                      OutlineInputBorder(),
                  suffixText: 'ج.م',
                ),

                validator: (value) {
                  final amount =
                      double.tryParse(
                    value?.trim() ?? '',
                  );

                  if (amount == null ||
                      amount <= 0) {
                    return 'أدخل مبلغًا صحيحًا';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              // ==================================================
              // To Account
              // ==================================================

              const Text(
                'إلى الحساب',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              InkWell(
                onTap: () {
                  _showAccountPicker(
                    isFromAccount: false,
                  );
                },

                borderRadius:
                    BorderRadius.circular(14),

                child: Container(
                  padding:
                      const EdgeInsets.all(16),

                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius:
                        BorderRadius.circular(14),
                    border: Border.all(
                      color:
                          colors.outlineVariant,
                    ),
                  ),

                  child: Row(
                    children: [
                      Icon(
                        Icons
                            .account_balance_wallet_outlined,
                        color: colors.primary,
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              toAccount?.name ??
                                  'اختر الحساب',
                              style: const TextStyle(
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),

                            if (toAccount != null)
                              Text(
                                '${toAccount.currentBalance.toStringAsFixed(2)} جنيه',
                                style: TextStyle(
                                  color: colors
                                      .onSurfaceVariant,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),

                      Icon(
                        Icons.chevron_left_rounded,
                        color:
                            colors.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ==================================================
              // Date
              // ==================================================

              InkWell(
                onTap: _selectDate,

                borderRadius:
                    BorderRadius.circular(14),

                child: Container(
                  padding:
                      const EdgeInsets.all(16),

                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius:
                        BorderRadius.circular(14),
                    border: Border.all(
                      color:
                          colors.outlineVariant,
                    ),
                  ),

                  child: Row(
                    children: [
                      Icon(
                        Icons
                            .calendar_today_outlined,
                        color: colors.primary,
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'التاريخ',
                              style: TextStyle(
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),

                            const SizedBox(height: 3),

                            Text(
                              _formatDate(
                                _selectedDate,
                              ),
                              style: TextStyle(
                                color: colors.primary,
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Icon(
                        Icons.chevron_left_rounded,
                        color:
                            colors.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ==================================================
              // Note
              // ==================================================

              TextFormField(
                controller: _noteController,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                maxLines: 2,

                decoration:
                    const InputDecoration(
                  labelText:
                      'ملاحظة (اختياري)',
                  border:
                      OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 32),

              // ==================================================
              // Save
              // ==================================================

              SizedBox(
                height: 52,

                child: FilledButton(
                  onPressed: _updateTransfer,

                  child: const Text(
                    'حفظ التعديلات',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}