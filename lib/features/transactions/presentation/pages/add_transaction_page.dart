import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/transaction_type.dart';
import '../../providers/transaction_type_provider.dart';
import '../widgets/transaction_type_card.dart';

class AddTransactionPage extends ConsumerWidget {
  const AddTransactionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(transactionTypeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("إضافة عملية"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            Row(
              children: [
                TransactionTypeCard(
                  title: "مصروف",
                  icon: Icons.arrow_downward_rounded,
                  selected: selected == TransactionType.expense,
                  onTap: () {
                    ref
                        .read(transactionTypeProvider.notifier)
                        .state = TransactionType.expense;
                  },
                ),

                const SizedBox(width: 12),

                TransactionTypeCard(
                  title: "دخل",
                  icon: Icons.arrow_upward_rounded,
                  selected: selected == TransactionType.income,
                  onTap: () {
                    ref
                        .read(transactionTypeProvider.notifier)
                        .state = TransactionType.income;
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}