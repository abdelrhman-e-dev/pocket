import 'package:flutter/material.dart';

import '../../models/transaction_with_details.dart';

class EditTransactionPage extends StatefulWidget {
  const EditTransactionPage({
    super.key,
    required this.transaction,
  });

  final TransactionWithDetails transaction;

  @override
  State<EditTransactionPage> createState() =>
      _EditTransactionPageState();
}

class _EditTransactionPageState
    extends State<EditTransactionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تعديل العملية'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('صفحة تعديل العملية'),
      ),
    );
  }
}