import 'package:flutter/material.dart';

import '../../../../shared/components/cards/account_type_card.dart';

class CreateAccountPage extends StatelessWidget {
  const CreateAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("إنشاء أول حساب"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [

          const Text(
            "اسم الحساب",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          TextFormField(
            decoration: const InputDecoration(
              hintText: "مثال: المحفظة الشخصية",
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            "نوع الحساب",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          AccountTypeCard(
            icon: Icons.payments,
            title: "نقدية",
            subtitle: "للمصاريف اليومية",
            selected: true,
            onTap: () {},
          ),

          const SizedBox(height: 12),

          AccountTypeCard(
            icon: Icons.account_balance,
            title: "حساب بنكي",
            subtitle: "الحسابات البنكية",
            selected: false,
            onTap: () {},
          ),

          const SizedBox(height: 12),

          AccountTypeCard(
            icon: Icons.credit_card,
            title: "بطاقة ائتمانية",
            subtitle: "Visa / MasterCard",
            selected: false,
            onTap: () {},
          ),

          const SizedBox(height: 12),

          AccountTypeCard(
            icon: Icons.account_balance_wallet,
            title: "محفظة إلكترونية",
            subtitle: "Vodafone Cash - InstaPay",
            selected: false,
            onTap: () {},
          ),

          const SizedBox(height: 24),

          const Text(
            "الرصيد الافتتاحي",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          TextFormField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: "0",
              suffixText: "جنيه",
            ),
          ),

          const SizedBox(height: 40),

          SizedBox(
            height: 54,
            child: FilledButton(
              onPressed: () {},
              child: const Text("متابعة"),
            ),
          ),
        ],
      ),
    );
  }
}