import '../../../core/database/app_database.dart';

class TransactionWithDetails {
  const TransactionWithDetails({
    required this.transaction,
    required this.account,
    required this.category,
  });

  final Transaction transaction;
  final Account account;
  final Category category;
}