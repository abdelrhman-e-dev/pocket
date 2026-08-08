import 'package:flutter/material.dart';

import '../../../../core/database/app_database.dart';

class AccountSelector extends StatelessWidget {
  const AccountSelector({
    super.key,
    required this.accounts,
    required this.selectedAccountId,
    required this.onChanged,
  });

  final List<Account> accounts;
  final int? selectedAccountId;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      initialValue: selectedAccountId,

      decoration: const InputDecoration(
        labelText: '',
        hintText: 'اختر الحساب',
        prefixIcon: Icon(
          Icons.account_balance_wallet_outlined,
        ),
      ),

      items: accounts.map((account) {
        return DropdownMenuItem<int>(
          value: account.id,
          child: Text(account.name),
        );
      }).toList(),

      onChanged: onChanged,

      validator: (value) {
        if (value == null) {
          return 'من فضلك اختر الحساب';
        }

        return null;
      },
    );
  }
}