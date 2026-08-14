import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';

class TransferRepository {
  TransferRepository(this._database);

  final AppDatabase _database;

  Future<void> createTransfer({
    required int fromAccountId,
    required int toAccountId,
    required double amount,
    String? note,
    required DateTime transferDate,
  }) async {
    if (fromAccountId == toAccountId) {
      throw Exception(
        'لا يمكن التحويل إلى نفس الحساب',
      );
    }

    if (amount <= 0) {
      throw Exception(
        'مبلغ التحويل يجب أن يكون أكبر من صفر',
      );
    }

    await _database.transaction(() async {
      // =========================
      // 1. Get source account
      // =========================
      final fromAccount = await (_database.select(
        _database.accounts,
      )..where(
          (table) => table.id.equals(fromAccountId),
        )).getSingle();

      // =========================
      // 2. Get destination account
      // =========================
      final toAccount = await (_database.select(
        _database.accounts,
      )..where(
          (table) => table.id.equals(toAccountId),
        )).getSingle();

      // =========================
      // 3. Check balance
      // =========================
      if (fromAccount.currentBalance < amount) {
        throw Exception(
          'الرصيد غير كافٍ لإتمام التحويل',
        );
      }

      // =========================
      // 4. Calculate new balances
      // =========================
      final newFromBalance =
          fromAccount.currentBalance - amount;

      final newToBalance =
          toAccount.currentBalance + amount;

      // =========================
      // 5. Update source account
      // =========================
      await (_database.update(
        _database.accounts,
      )..where(
          (table) => table.id.equals(fromAccountId),
        )).write(
        AccountsCompanion(
          currentBalance: Value(newFromBalance),
        ),
      );

      // =========================
      // 6. Update destination account
      // =========================
      await (_database.update(
        _database.accounts,
      )..where(
          (table) => table.id.equals(toAccountId),
        )).write(
        AccountsCompanion(
          currentBalance: Value(newToBalance),
        ),
      );

      // =========================
      // 7. Save transfer
      // =========================
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
}