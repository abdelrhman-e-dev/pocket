import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme.dart';
import '../../models/account_type.dart';
import '../../providers/selected_account_type_provider.dart';
import '../../providers/create_account_provider.dart';
import '../../../../shared/components/buttons/primary_button.dart';
import '../../../../shared/components/cards/account_type_card.dart';
import '../../../../shared/components/text_fields/app_text_field.dart';
import '../../../dashboard/providers/dashboard_provider.dart';

class CreateAccountPage extends ConsumerStatefulWidget {
  const CreateAccountPage({super.key});

  @override
  ConsumerState<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends ConsumerState<CreateAccountPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();

  final _balanceController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedType = ref.watch(selectedAccountTypeProvider);

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
                // =========================================
                // title
                // =========================================
                const Text(
                  'إنشاء حسابك الأول',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.textColor,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'أضف حسابك الأول وابدأ في إدارة أموالك بسهولة',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.subtitleColor,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 28),

                // =========================================
                // account preview
                // =========================================
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _nameController,
                  builder: (context, nameValue, _) {
                    return ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _balanceController,
                      builder: (context, balanceValue, _) {
                        return _AccountPreview(
                          accountName: nameValue.text.trim().isEmpty
                              ? 'حسابك الجديد'
                              : nameValue.text.trim(),

                          balance: balanceValue.text.trim().isEmpty
                              ? '0'
                              : balanceValue.text.trim(),

                          accountType: _getAccountTypeName(selectedType),
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 28),

                // =========================================
                // account type
                // =========================================
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
                    // cash
                    AccountTypeCard(
                      icon: Icons.payments_rounded,
                      title: 'نقدية',
                      subtitle: 'للمصاريف اليومية',
                      selected: selectedType == AccountType.cash,
                      onTap: () {
                        ref.read(selectedAccountTypeProvider.notifier).state =
                            AccountType.cash;
                      },
                    ),

                    // bank account
                    AccountTypeCard(
                      icon: Icons.account_balance_rounded,
                      title: 'حساب بنكي',
                      subtitle: 'حسابك البنكي',
                      selected: selectedType == AccountType.bank,
                      onTap: () {
                        ref.read(selectedAccountTypeProvider.notifier).state =
                            AccountType.bank;
                      },
                    ),

                    // credit card
                    AccountTypeCard(
                      icon: Icons.credit_card_rounded,
                      title: 'بطاقة ائتمانية',
                      subtitle: 'Visa / MasterCard',
                      selected: selectedType == AccountType.creditCard,
                      onTap: () {
                        ref.read(selectedAccountTypeProvider.notifier).state =
                            AccountType.creditCard;
                      },
                    ),

                    // digital wallet
                    AccountTypeCard(
                      icon: Icons.account_balance_wallet_rounded,
                      title: 'محفظة إلكترونية',
                      subtitle: 'Vodafone Cash / InstaPay',
                      selected: selectedType == AccountType.digitalWallet,
                      onTap: () {
                        ref.read(selectedAccountTypeProvider.notifier).state =
                            AccountType.digitalWallet;
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // =========================================
                // account name
                // =========================================
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

                // =========================================
                // opening balance
                // =========================================
                const Text(
                  'الرصيد الافتتاحي',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: AppTheme.textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                AppTextField(
                  controller: _balanceController,

                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),

                  hint: '0',

                  suffixText: 'جنيه',

                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'أدخل الرصيد';
                    }

                    final balance = double.tryParse(value.trim());

                    if (balance == null) {
                      return 'رقم غير صحيح';
                    }

                    if (balance < 0) {
                      return 'الرصيد لا يمكن أن يكون سالبًا';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 36),

                // =========================================
                // create account button
                // =========================================
                
                PrimaryButton(
                  text: 'إنشاء الحساب',
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) {
                      return;
                    }

                    final request = CreateAccountRequest(
                      name: _nameController.text.trim(),
                      type: selectedType.name,
                      openingBalance: double.parse(
                        _balanceController.text.trim(),
                      ),
                      color: AppTheme.primaryColor.value,
                      icon: selectedType.name,
                    );

                    await ref.read(createAccountProvider(request).future);

                    if (!context.mounted) {
                      return;
                    }

                    // Invalidate the dashboard cache so it refetches the
                    // updated account list instead of showing the empty state.
                    ref.invalidate(dashboardProvider);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم إنشاء الحساب بنجاح')),
                    );

                    context.go('/dashboard');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
}

// ======================================================
// account preview
// ======================================================

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
          // account name and type
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

          // balance
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
