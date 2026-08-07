import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({
    super.key,
    required this.total,
  });

  final double total;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.primary,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              "إجمالي الرصيد",
              style: TextStyle(
                color: Colors.white70,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              "${total.toStringAsFixed(2)} جنيه",
              style: const TextStyle(
                fontSize: 28,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}