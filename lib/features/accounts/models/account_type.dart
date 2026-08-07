enum AccountType {
  cash,
  bank,
  creditCard,
  digitalWallet,
  savings,
  investment,
}

extension AccountTypeExtension on AccountType {
  String get title {
    switch (this) {
      case AccountType.cash:
        return 'نقدية';
      case AccountType.bank:
        return 'حساب بنكي';
      case AccountType.creditCard:
        return 'بطاقة ائتمانية';
      case AccountType.digitalWallet:
        return 'محفظة إلكترونية';
      case AccountType.savings:
        return 'مدخرات';
      case AccountType.investment:
        return 'استثمار';
    }
  }
}