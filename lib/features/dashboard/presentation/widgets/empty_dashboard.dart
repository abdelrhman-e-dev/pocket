import 'package:flutter/material.dart';

class EmptyDashboard extends StatelessWidget {
  const EmptyDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 70,
          ),

          SizedBox(height: 16),

          Text(
            "لا يوجد أي حساب",
            style: TextStyle(
              fontSize: 20,
            ),
          ),

          SizedBox(height: 8),

          Text(
            "ابدأ بإنشاء أول حساب",
          ),
        ],
      ),
    );
  }
}