import 'package:flutter/material.dart';

import '../../../../core/database/app_database.dart';

class AccountTile extends StatelessWidget {
  const AccountTile({
    super.key,
    required this.account,
  });

  final Account account;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(
        child: Icon(Icons.account_balance_wallet),
      ),
      title: Text(account.name),
      subtitle: Text(account.type),
      trailing: Text(
        "${account.currentBalance.toStringAsFixed(2)} ج",
      ),
    );
  }
}