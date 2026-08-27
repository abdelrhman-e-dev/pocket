enum HoldingType {
  usd,
  gold;

  String get value => name;

  String get arabicName => this == usd ? 'دولار' : 'ذهب';
}