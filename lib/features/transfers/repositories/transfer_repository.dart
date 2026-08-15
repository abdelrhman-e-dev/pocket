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
        _database.accounts.id.equalsExp(_database.transfers.fromAccountId),
      ),
      innerJoin(
        toAccountAlias,
        toAccountAlias.id.equalsExp(_database.transfers.toAccountId),
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
  // ============================================================
  // Update Transfer
  // ============================================================

  Future<void> updateTransfer({
    required int transferId,
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
      // 1. Get old transfer
      final oldTransfer = await (_database.select(
        _database.transfers,
      )..where((table) => table.id.equals(transferId))).getSingle();

      // 2. Get old source account
      final oldFromAccount =
          await (_database.select(_database.accounts)
                ..where((table) => table.id.equals(oldTransfer.fromAccountId)))
              .getSingle();

      // 3. Get old destination account
      final oldToAccount =
          await (_database.select(_database.accounts)
                ..where((table) => table.id.equals(oldTransfer.toAccountId)))
              .getSingle();

      // ========================================================
      // 4. Undo old transfer
      // ========================================================

      var oldFromBalance = oldFromAccount.currentBalance + oldTransfer.amount;

      var oldToBalance = oldToAccount.currentBalance - oldTransfer.amount;

      // ========================================================
      // 5. If the accounts are changing, get the new accounts
      // ========================================================

      final newFromAccount = await (_database.select(
        _database.accounts,
      )..where((table) => table.id.equals(fromAccountId))).getSingle();

      final newToAccount = await (_database.select(
        _database.accounts,
      )..where((table) => table.id.equals(toAccountId))).getSingle();

      // ========================================================
      // 6. Restore old balances
      // ========================================================

      if (oldTransfer.fromAccountId == oldTransfer.toAccountId) {
        throw Exception('بيانات التحويل غير صحيحة');
      }

      await (_database.update(_database.accounts)
            ..where((table) => table.id.equals(oldTransfer.fromAccountId)))
          .write(AccountsCompanion(currentBalance: Value(oldFromBalance)));

      await (_database.update(_database.accounts)
            ..where((table) => table.id.equals(oldTransfer.toAccountId)))
          .write(AccountsCompanion(currentBalance: Value(oldToBalance)));

      // ========================================================
      // 7. Check new source balance
      // ========================================================

      final availableBalance = newFromAccount.id == oldTransfer.fromAccountId
          ? oldFromBalance
          : newFromAccount.currentBalance;

      if (availableBalance < amount) {
        throw Exception('الرصيد غير كافٍ لإتمام التحويل الجديد');
      }

      // ========================================================
      // 8. Apply new transfer
      // ========================================================

      if (fromAccountId == toAccountId) {
        throw Exception('لا يمكن التحويل إلى نفس الحساب');
      }

      // لو الحساب المصدر هو نفسه الحساب القديم
      // نستخدم الرصيد بعد إلغاء التحويل القديم.
      final currentNewFromBalance = fromAccountId == oldTransfer.fromAccountId
          ? oldFromBalance
          : newFromAccount.currentBalance;

      final currentNewToBalance = toAccountId == oldTransfer.toAccountId
          ? oldToBalance
          : newToAccount.currentBalance;

      await (_database.update(
        _database.accounts,
      )..where((table) => table.id.equals(fromAccountId))).write(
        AccountsCompanion(
          currentBalance: Value(currentNewFromBalance - amount),
        ),
      );

      await (_database.update(
        _database.accounts,
      )..where((table) => table.id.equals(toAccountId))).write(
        AccountsCompanion(currentBalance: Value(currentNewToBalance + amount)),
      );

      // ========================================================
      // 9. Update transfer record
      // ========================================================

      await (_database.update(
        _database.transfers,
      )..where((table) => table.id.equals(transferId))).write(
        TransfersCompanion(
          fromAccountId: Value(fromAccountId),
          toAccountId: Value(toAccountId),
          amount: Value(amount),
          note: Value(note),
          transferDate: Value(transferDate),
        ),
      );
    });
  }
  // ============================================================
  // Delete Transfer
  // ============================================================

  Future<void> deleteTransfer({required int transferId}) async {
    await _database.transaction(() async {
      // 1. Get transfer
      final transfer = await (_database.select(
        _database.transfers,
      )..where((table) => table.id.equals(transferId))).getSingle();

      // 2. Get source account
      final fromAccount = await (_database.select(
        _database.accounts,
      )..where((table) => table.id.equals(transfer.fromAccountId))).getSingle();

      // 3. Get destination account
      final toAccount = await (_database.select(
        _database.accounts,
      )..where((table) => table.id.equals(transfer.toAccountId))).getSingle();

      // 4. Reverse the original transfer
      final newFromBalance = fromAccount.currentBalance + transfer.amount;

      final newToBalance = toAccount.currentBalance - transfer.amount;

      // 5. Restore source account
      await (_database.update(_database.accounts)
            ..where((table) => table.id.equals(transfer.fromAccountId)))
          .write(AccountsCompanion(currentBalance: Value(newFromBalance)));

      // 6. Restore destination account
      await (_database.update(_database.accounts)
            ..where((table) => table.id.equals(transfer.toAccountId)))
          .write(AccountsCompanion(currentBalance: Value(newToBalance)));

      // 7. Delete transfer
      await (_database.delete(
        _database.transfers,
      )..where((table) => table.id.equals(transferId))).go();
    });
  }
}
