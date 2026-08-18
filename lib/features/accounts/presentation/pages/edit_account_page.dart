import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme.dart';
import '../../models/account_type.dart';
import '../../providers/account_repository_provider.dart';
import '../../providers/selected_account_type_provider.dart';
import '../../../../shared/components/buttons/primary_button.dart';
import '../../../../shared/components/cards/account_type_card.dart';
import '../../../../shared/components/text_fields/app_text_field.dart';
import '../../../dashboard/providers/dashboard_provider.dart';

import '../../../transactions/providers/transaction_accounts_provider.dart';
import '../../providers/account_details_provider.dart';
import '../../../../core/database/app_database.dart';

class EditAccountPage extends ConsumerStatefulWidget {
  const EditAccountPage({super.key, required this.account});

  final Account account;

  @override
  ConsumerState<EditAccountPage> createState() => _EditAccountPageState();
}

class _EditAccountPageState extends ConsumerState<EditAccountPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;

  late AccountType _selectedType;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.account.name);

    _selectedType = _parseAccountType(widget.account.type);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      ref.read(selectedAccountTypeProvider.notifier).state = _selectedType;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // ============================================================
  // Parse Account Type
  // ============================================================

  AccountType _parseAccountType(String type) {
    return AccountType.values.firstWhere(
      (value) => value.name == type,
      orElse: () => AccountType.cash,
    );
  }

  // ============================================================
  // Account Type Name
  // ============================================================

  String _getAccountTypeName(AccountType type) {
    switch (type) {
      case AccountType.cash:
        return 'نقدية';

      case AccountType.bank:
        return 'حساب بنكي';

      case AccountType.creditCard:
        return 'بطاقة ائتمانية';

      case AccountType.digitalWallet:
        return 'محفظة إلكترونية';

      case AccountType.savings:
        return 'حساب توفير';

      case AccountType.investment:
        return 'استثمار';
    }
  }

  // ============================================================
  // Save
  // ============================================================

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = _nameController.text.trim();

    try {
      await ref
          .read(accountRepositoryProvider)
          .updateAccount(
            accountId: widget.account.id,
            name: name,
            type: _selectedType.name,
            color: AppTheme.primaryColor.value,
            icon: _selectedType.name,
          );

      ref.invalidate(accountDetailsProvider(widget.account.id));
      ref.invalidate(accountRepositoryProvider);
      if (!mounted) return;
      // تحديث Dashboard
      ref.invalidate(dashboardProvider);

      // تحديث الحسابات المستخدمة في المعاملات
      ref.invalidate(transactionAccountsProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تم تعديل الحساب بنجاح',
            textDirection: TextDirection.rtl,
          ),
        ),
      );

      context.pop();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'حدث خطأ أثناء تعديل الحساب: $e',
            textDirection: TextDirection.rtl,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedType = ref.watch(selectedAccountTypeProvider);

    final balance = widget.account.currentBalance.toStringAsFixed(2);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,

      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,

          child: Form(
            key: _formKey,

            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),

              children: [
                // ==================================================
                // Header
                // ==================================================
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        context.pop();
                      },
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),

                    Expanded(
                      child: Text(
                        'تعديل الحساب',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppTheme.textColor,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(width: 48),
                  ],
                ),

                const SizedBox(height: 8),

                const Text(
                  'عدّل بيانات الحساب بدون التأثير على رصيده الحالي',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.subtitleColor,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 28),

                // ==================================================
                // Preview
                // ==================================================
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _nameController,

                  builder: (context, nameValue, _) {
                    return _AccountPreview(
                      accountName: nameValue.text.trim().isEmpty
                          ? 'حسابك'
                          : nameValue.text.trim(),

                      balance: balance,

                      accountType: _getAccountTypeName(selectedType),
                    );
                  },
                ),

                const SizedBox(height: 28),

                // ==================================================
                // Account Type
                // ==================================================
                const Text(
                  'نوع الحساب',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: AppTheme.textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.15,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),

                  children: [
                    AccountTypeCard(
                      icon: Icons.payments_rounded,
                      title: 'نقدية',
                      subtitle: 'للمصاريف اليومية',
                      selected: selectedType == AccountType.cash,
                      onTap: () {
                        setState(() {
                          _selectedType = AccountType.cash;
                        });

                        ref.read(selectedAccountTypeProvider.notifier).state =
                            AccountType.cash;
                      },
                    ),

                    AccountTypeCard(
                      icon: Icons.account_balance_rounded,
                      title: 'حساب بنكي',
                      subtitle: 'حسابك البنكي',
                      selected: selectedType == AccountType.bank,
                      onTap: () {
                        setState(() {
                          _selectedType = AccountType.bank;
                        });

                        ref.read(selectedAccountTypeProvider.notifier).state =
                            AccountType.bank;
                      },
                    ),

                    AccountTypeCard(
                      icon: Icons.credit_card_rounded,
                      title: 'بطاقة ائتمانية',
                      subtitle: 'Visa / MasterCard',
                      selected: selectedType == AccountType.creditCard,
                      onTap: () {
                        setState(() {
                          _selectedType = AccountType.creditCard;
                        });

                        ref.read(selectedAccountTypeProvider.notifier).state =
                            AccountType.creditCard;
                      },
                    ),

                    AccountTypeCard(
                      icon: Icons.account_balance_wallet_rounded,
                      title: 'محفظة إلكترونية',
                      subtitle: 'Vodafone Cash / InstaPay',
                      selected: selectedType == AccountType.digitalWallet,
                      onTap: () {
                        setState(() {
                          _selectedType = AccountType.digitalWallet;
                        });

                        ref.read(selectedAccountTypeProvider.notifier).state =
                            AccountType.digitalWallet;
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // ==================================================
                // Account Name
                // ==================================================
                const Text(
                  'اسم الحساب',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: AppTheme.textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                AppTextField(
                  controller: _nameController,
                  hint: 'مثال: المحفظة الشخصية',

                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'من فضلك أدخل اسم الحساب';
                    }

                    if (value.trim().length < 3) {
                      return 'الاسم يجب أن يكون 3 أحرف على الأقل';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // ==================================================
                // Current Balance
                // ==================================================
                Container(
                  padding: const EdgeInsets.all(16),

                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLow,

                    borderRadius: BorderRadius.circular(16),

                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),

                  child: Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            const Text(
                              'الرصيد الحالي',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              '$balance جنيه',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Icon(Icons.lock_outline_rounded, size: 20),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'الرصيد الحالي لا يتم تعديله من هنا.',
                  textAlign: TextAlign.right,
                  style: TextStyle(color: AppTheme.subtitleColor, fontSize: 12),
                ),

                const SizedBox(height: 36),

                // ==================================================
                // Save
                // ==================================================
                PrimaryButton(text: 'حفظ التعديلات', onPressed: _save),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =================================================================
// Account Preview
// =================================================================

class _AccountPreview extends StatelessWidget {
  const _AccountPreview({
    required this.accountName,
    required this.balance,
    required this.accountType,
  });

  final String accountName;
  final String balance;
  final String accountType;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(20),
      ),

      child: Row(
        textDirection: TextDirection.rtl,

        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,

                  decoration: BoxDecoration(
                    color: colors.onPrimary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),

                  child: Icon(
                    Icons.account_balance_wallet_rounded,
                    color: colors.onPrimary,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        accountName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,

                        style: TextStyle(
                          color: colors.onPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        accountType,
                        style: TextStyle(
                          color: colors.onPrimary.withValues(alpha: 0.75),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,

            children: [
              Text(
                'الرصيد',
                style: TextStyle(
                  color: colors.onPrimary.withValues(alpha: 0.75),
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 4),

              Row(
                mainAxisSize: MainAxisSize.min,

                crossAxisAlignment: CrossAxisAlignment.baseline,

                textBaseline: TextBaseline.alphabetic,

                children: [
                  Text(
                    'جنيه',
                    style: TextStyle(color: colors.onPrimary, fontSize: 12),
                  ),

                  const SizedBox(width: 4),

                  Text(
                    balance,
                    style: TextStyle(
                      color: colors.onPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
