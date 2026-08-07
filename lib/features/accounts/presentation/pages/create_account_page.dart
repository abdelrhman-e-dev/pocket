import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/account_type.dart';
import '../../providers/selected_account_type_provider.dart';
import '../../providers/create_account_provider.dart';
import '../../../../shared/components/buttons/primary_button.dart';
import '../../../../shared/components/cards/account_type_card.dart';
import '../../../../shared/components/text_fields/app_text_field.dart';

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
      appBar: AppBar(title: const Text("إنشاء أول حساب")),

      body: Form(
        key: _formKey,

        child: ListView(
          padding: const EdgeInsets.all(20),

          children: [
            const Text(
              "اسم الحساب",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            AppTextField(
              controller: _nameController,
              hint: "مثال: المحفظة الشخصية",

              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "من فضلك أدخل اسم الحساب";
                }

                if (value.trim().length < 3) {
                  return "الاسم يجب أن يكون 3 أحرف على الأقل";
                }

                return null;
              },
            ),

            const SizedBox(height: 24),

            const Text(
              "نوع الحساب",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            AccountTypeCard(
              icon: Icons.payments,
              title: "نقدية",
              subtitle: "للمصاريف اليومية",

              selected: selectedType == AccountType.cash,

              onTap: () {
                ref.read(selectedAccountTypeProvider.notifier).state =
                    AccountType.cash;
              },
            ),

            const SizedBox(height: 12),

            AccountTypeCard(
              icon: Icons.account_balance,
              title: "حساب بنكي",
              subtitle: "الحسابات البنكية",

              selected: selectedType == AccountType.bank,

              onTap: () {
                ref.read(selectedAccountTypeProvider.notifier).state =
                    AccountType.bank;
              },
            ),

            const SizedBox(height: 12),

            AccountTypeCard(
              icon: Icons.credit_card,
              title: "بطاقة ائتمانية",
              subtitle: "Visa / MasterCard",

              selected: selectedType == AccountType.creditCard,

              onTap: () {
                ref.read(selectedAccountTypeProvider.notifier).state =
                    AccountType.creditCard;
              },
            ),

            const SizedBox(height: 12),

            AccountTypeCard(
              icon: Icons.account_balance_wallet,
              title: "محفظة إلكترونية",
              subtitle: "Vodafone Cash - InstaPay",

              selected: selectedType == AccountType.digitalWallet,

              onTap: () {
                ref.read(selectedAccountTypeProvider.notifier).state =
                    AccountType.digitalWallet;
              },
            ),

            const SizedBox(height: 24),

            const Text(
              "الرصيد الافتتاحي",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            AppTextField(
              controller: _balanceController,

              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),

              hint: "0",

              suffixText: "جنيه",

              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "أدخل الرصيد";
                }

                final balance = double.tryParse(value);

                if (balance == null) {
                  return "رقم غير صحيح";
                }

                if (balance < 0) {
                  return "الرصيد لا يمكن أن يكون سالبًا";
                }

                return null;
              },
            ),

            const SizedBox(height: 40),

            PrimaryButton(
              text: "متابعة",

              onPressed: () async {
                if (!_formKey.currentState!.validate()) {
                  return;
                }

                final request = CreateAccountRequest(
                  name: _nameController.text.trim(),
                  type: selectedType.name,
                  openingBalance: double.parse(_balanceController.text),
                  color: 0xFF3B82F6,
                  icon: selectedType.name,
                );

                await ref.read(createAccountProvider(request).future);

                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("تم إنشاء الحساب بنجاح")),
                );

                context.go('/');
              },
            ),
          ],
        ),
      ),
    );
  }
}
