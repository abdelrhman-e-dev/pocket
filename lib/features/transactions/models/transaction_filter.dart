enum TransactionFilter { all, expense, income, transfer }

extension TransactionFilterExtension on TransactionFilter {
  String get label {
    switch (this) {
      case TransactionFilter.all:
        return 'الكل';
      case TransactionFilter.expense:
        return 'مصاريف';
      case TransactionFilter.income:
        return 'دخل';
      case TransactionFilter.transfer:
        return 'تحويلات';
    }
  }

  String? get dbType {
    switch (this) {
      case TransactionFilter.all:
        return null;
      case TransactionFilter.expense:
        return 'expense';
      case TransactionFilter.income:
        return 'income';
      case TransactionFilter.transfer:
        return 'transfer';
    }
  }
}