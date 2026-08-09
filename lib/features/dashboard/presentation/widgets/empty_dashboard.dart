import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EmptyDashboard extends StatelessWidget {
  const EmptyDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.account_balance_wallet_outlined,
            size: 70,
          ),
          const SizedBox(height: 16),
          const Text(
            "لا يوجد أي حساب",
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "ابدأ بإنشاء أول حساب",
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.push('/create-account'),
            icon: const Icon(Icons.add),
            label: const Text("إنشاء حساب"),
          ),
        ],
      ),
    );
  }
}