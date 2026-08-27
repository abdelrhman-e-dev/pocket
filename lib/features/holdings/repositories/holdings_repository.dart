import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';

class HoldingsRepository {
  HoldingsRepository(this._database);

  final AppDatabase _database;

  Stream<List<Holding>> watchHoldings() =>
      (_database.select(_database.holdings)
            ..orderBy([(table) => OrderingTerm.desc(table.updatedAt)]))
          .watch();

  Future<Holding> getHolding(int id) =>
      (_database.select(_database.holdings)..where((table) => table.id.equals(id)))
          .getSingle();

  Future<void> saveHolding({
    int? id,
    required String type,
    required double amount,
    int? goldKarat,
    String? label,
  }) async {
    final now = DateTime.now();
    final companion = HoldingsCompanion(
      type: Value(type),
      amount: Value(amount),
      goldKarat: Value(goldKarat),
      label: Value(label?.trim().isEmpty == true ? null : label?.trim()),
      updatedAt: Value(now),
    );

    if (id == null) {
      await _database.into(_database.holdings).insert(
            HoldingsCompanion.insert(
              type: type,
              amount: amount,
              goldKarat: Value(goldKarat),
              label: Value(label?.trim().isEmpty == true ? null : label?.trim()),
              createdAt: Value(now),
              updatedAt: Value(now),
            ),
          );
    } else {
      await (_database.update(_database.holdings)
            ..where((table) => table.id.equals(id)))
          .write(companion);
    }
  }

  Future<void> deleteHolding(int id) =>
      (_database.delete(_database.holdings)..where((table) => table.id.equals(id)))
          .go();

  Future<RateSnapshot?> getLatestRate() =>
      (_database.select(_database.rateSnapshots)
            ..orderBy([(table) => OrderingTerm.desc(table.fetchedAt)])
            ..limit(1))
          .getSingleOrNull();

  Future<void> saveRate({
    required double usdToEgp,
    required double goldPricePerGram24k,
    required String source,
  }) async {
    await _database.into(_database.rateSnapshots).insert(
          RateSnapshotsCompanion.insert(
            usdToEgp: usdToEgp,
            goldPricePerGram24k: goldPricePerGram24k,
            fetchedAt: DateTime.now(),
            source: source,
          ),
        );
  }
}