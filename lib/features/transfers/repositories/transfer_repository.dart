import 'package:drift/drift.dart';
import '../models/transfer_with_details.dart';
import '../../../core/database/app_database.dart';

class TransferRepository {
  TransferRepository(this._database);

  final AppDatabase _database;

  // ============================================================
  // Create Transfer
  // ============================================================

  Future<void> createTransfer({
    required int fromAccountId,
    required int toAccountId,
    required double amount,
    String? note,
    required DateTime transferDate,
  }) async {
    if (fromAccountId == toAccountId) {
      throw Exception('لا يمكن التحويل إلى نفس الحساب');
    }

    if (amount <= 0) {
      throw Exception('مبلغ التحويل يجب أن يكون أكبر من صفر');
    }

    await _database.transaction(() async {
      // 1. Get source account
      final fromAccount = await (_database.select(
        _database.accounts,
      )..where((table) => table.id.equals(fromAccountId))).getSingle();

      // 2. Get destination account
      final toAccount = await (_database.select(
        _database.accounts,
      )..where((table) => table.id.equals(toAccountId))).getSingle();

      // 3. Check balance
      if (fromAccount.currentBalance < amount) {
        throw Exception('الرصيد غير كافٍ لإتمام التحويل');
      }

      // 4. Calculate new balances
      final newFromBalance = fromAccount.currentBalance - amount;

      final newToBalance = toAccount.currentBalance + amount;

      // 5. Update source account
      await (_database.update(_database.accounts)
            ..where((table) => table.id.equals(fromAccountId)))
          .write(AccountsCompanion(currentBalance: Value(newFromBalance)));

      // 6. Update destination account
      await (_database.update(_database.accounts)
            ..where((table) => table.id.equals(toAccountId)))
          .write(AccountsCompanion(currentBalance: Value(newToBalance)));

      // 7. Save transfer
      await _database
          .into(_database.transfers)
          .insert(
            TransfersCompanion.insert(
              fromAccountId: fromAccountId,
              toAccountId: toAccountId,
              amount: amount,
              note: Value(note),
              transferDate: transferDate,
            ),
          );
    });
  }

  // ============================================================
  // Get All Transfers
  // ============================================================

Future<List<TransferWithDetails>> getAllTransfersWithDetails() async {
  final toAccountAlias = _database.accounts.createAlias('to_account');

  final query = _database.select(_database.transfers).join([
    innerJoin(
      _database.accounts,
      _database.accounts.id.equalsExp(
        _database.transfers.fromAccountId,
      ),
    ),
    innerJoin(
      toAccountAlias,
      toAccountAlias.id.equalsExp(
        _database.transfers.toAccountId,
      ),
    ),
  ]);

  query.orderBy([
    OrderingTerm(
      expression: _database.transfers.transferDate,
      mode: OrderingMode.desc,
    ),
  ]);

  final rows = await query.get();

  return rows.map((row) {
    return TransferWithDetails(
      transfer: row.readTable(_database.transfers),
      fromAccount: row.readTable(_database.accounts),
      toAccount: row.readTable(toAccountAlias),
    );
  }).toList();
}
  // ============================================================
  // Get Recent Transfers
  // ============================================================

  Future<List<TransferWithDetails>> getRecentTransfersWithDetails({
    int limit = 5,
  }) async {
    final transfers =
        await (_database.select(_database.transfers)
              ..orderBy([
                (table) => OrderingTerm(
                  expression: table.transferDate,
                  mode: OrderingMode.desc,
                ),
              ])
              ..limit(limit))
            .get();

    final result = <TransferWithDetails>[];

    for (final transfer in transfers) {
      final fromAccount = await (_database.select(
        _database.accounts,
      )..where((table) => table.id.equals(transfer.fromAccountId))).getSingle();

      final toAccount = await (_database.select(
        _database.accounts,
      )..where((table) => table.id.equals(transfer.toAccountId))).getSingle();

      result.add(
        TransferWithDetails(
          transfer: transfer,
          fromAccount: fromAccount,
          toAccount: toAccount,
        ),
      );
    }

    return result;
  }
}
