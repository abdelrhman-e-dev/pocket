import '../../../core/database/app_database.dart';

class TransferWithDetails {
  const TransferWithDetails({
    required this.transfer,
    required this.fromAccount,
    required this.toAccount,
  });

  final Transfer transfer;
  final Account fromAccount;
  final Account toAccount;
}