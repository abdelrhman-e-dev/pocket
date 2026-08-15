import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../dashboard/providers/dashboard_provider.dart';
import '../../../dashboard/providers/dashboard_summary_provider.dart';
import '../../../accounts/providers/account_repository_provider.dart';
import '../../../transactions/providers/transaction_accounts_provider.dart';
import '../../providers/transfer_repository_provider.dart';
import '../../models/transfer_with_details.dart';

class AddTransferPage extends ConsumerStatefulWidget {
  const AddTransferPage({super.key, this.transfer});

  final TransferWithDetails? transfer;

  bool get isEditMode => transfer != null;

  @override
  ConsumerState<AddTransferPage> createState() => _AddTransferPageState();
}

class _AddTransferPageState extends ConsumerState<AddTransferPage> {
  final _formKey = GlobalKey<FormState>();

  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  int? _fromAccountId;
  int? _toAccountId;

  DateTime _selectedDate = DateTime.now();
  @override
  void initState() {
    super.initState();

    final transfer = widget.transfer;

    if (transfer != null) {
      _fromAccountId = transfer.fromAccount.id;
      _toAccountId = transfer.toAccount.id;

      _amountController.text = transfer.transfer.amount.toString();

      _noteController.text = transfer.transfer.note ?? '';

      _selectedDate = transfer.transfer.transferDate;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();

    final selected = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year, now.month, now.day),
    );

    if (selected == null) return;

    setState(() {
      _selectedDate = selected;
    });
  }

  Future<void> _saveTransfer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_fromAccountId == null) {
      _showMessage('من فضلك اختر الحساب المُرسل');
      return;
    }

    if (_toAccountId == null) {
      _showMessage('من فضلك اختر الحساب المستلم');
      return;
    }

    if (_fromAccountId == _toAccountId) {
      _showMessage('لا يمكن التحويل إلى نفس الحساب');
      return;
    }

    final amount = double.tryParse(_amountController.text.trim());

    if (amount == null || amount <= 0) {
      _showMessage('من فضلك أدخل مبلغًا صحيحًا');
      return;
    }

    try {
      final repository = ref.read(transferRepositoryProvider);

      final note = _noteController.text.trim();

      if (widget.isEditMode) {
        await repository.updateTransfer(
          transferId: widget.transfer!.transfer.id,
          fromAccountId: _fromAccountId!,
          toAccountId: _toAccountId!,
          amount: amount,
          note: note.isEmpty ? null : note,
          transferDate: _selectedDate,
        );
      } else {
        await repository.createTransfer(
          fromAccountId: _fromAccountId!,
          toAccountId: _toAccountId!,
          amount: amount,
          note: note.isEmpty ? null : note,
          transferDate: _selectedDate,
        );
      }

      ref.invalidate(dashboardProvider);
      ref.invalidate(accountsProvider);
      ref.invalidate(dashboardSummaryProvider);
      ref.invalidate(transactionAccountsProvider);

      if (!mounted) return;

      context.pop();
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        e.toString().contains('الرصيد غير كافٍ')
            ? 'الرصيد غير كافٍ لإتمام التحويل'
            : 'حدث خطأ أثناء حفظ التحويل',
      );
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(transactionAccountsProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.isEditMode ? 'تعديل التحويل' : 'تحويل بين الحسابات',
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.pop(),
          ),
        ),

        body: accountsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),

          error: (_, __) =>
              const Center(child: Text('حدث خطأ أثناء تحميل الحسابات')),

          data: (accounts) {
            if (accounts.length < 2) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'تحتاج إلى حسابين على الأقل لإجراء تحويل.',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            return Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  DropdownButtonFormField<int>(
                    initialValue: _fromAccountId,
                    decoration: const InputDecoration(
                      labelText: 'من الحساب',
                      border: OutlineInputBorder(),
                    ),
                    items: accounts.map((account) {
                      return DropdownMenuItem<int>(
                        value: account.id,
                        child: Text(
                          '${account.name} — ${account.currentBalance.toStringAsFixed(0)} ج.م',
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _fromAccountId = value;

                        if (_toAccountId == value) {
                          _toAccountId = null;
                        }
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'المبلغ',
                      border: OutlineInputBorder(),
                      suffixText: 'ج.م',
                    ),
                    validator: (value) {
                      final amount = double.tryParse(value?.trim() ?? '');

                      if (amount == null || amount <= 0) {
                        return 'أدخل مبلغًا صحيحًا';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  DropdownButtonFormField<int>(
                    initialValue: _toAccountId,
                    decoration: const InputDecoration(
                      labelText: 'إلى الحساب',
                      border: OutlineInputBorder(),
                    ),
                    items: accounts
                        .where((account) => account.id != _fromAccountId)
                        .map((account) {
                          return DropdownMenuItem<int>(
                            value: account.id,
                            child: Text(
                              '${account.name} — ${account.currentBalance.toStringAsFixed(0)} ج.م',
                            ),
                          );
                        })
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _toAccountId = value;
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_today_outlined),
                    title: const Text('التاريخ'),
                    subtitle: Text(_formatDate(_selectedDate)),
                    onTap: _selectDate,
                  ),

                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _noteController,
                    textAlign: TextAlign.right,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'ملاحظة (اختياري)',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 28),

                  SizedBox(
                    height: 52,
                    child: FilledButton(
                      onPressed: _saveTransfer,
                      child: Text(
                        widget.isEditMode ? 'حفظ التعديلات' : 'متابعة',
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
