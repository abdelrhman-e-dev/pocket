import 'transaction_with_details.dart';
import '../../transfers/models/transfer_with_details.dart';

enum ActivityType {
  transaction,
  transfer,
}

class ActivityItem {
  const ActivityItem.transaction({
    required TransactionWithDetails transaction,
  })  : transaction = transaction,
        transfer = null,
        type = ActivityType.transaction;

  const ActivityItem.transfer({
    required TransferWithDetails transfer,
  })  : transaction = null,
        transfer = transfer,
        type = ActivityType.transfer;

  final TransactionWithDetails? transaction;
  final TransferWithDetails? transfer;

  final ActivityType type;

  DateTime get date {
    if (type == ActivityType.transfer) {
      return transfer!.transfer.transferDate;
    }

    return transaction!.transaction.transactionDate;
  }
}