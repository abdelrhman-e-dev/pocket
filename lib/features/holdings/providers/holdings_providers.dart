import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../repositories/holdings_repository.dart';
import '../repositories/rates_repository.dart';

final holdingsRepositoryProvider = Provider<HoldingsRepository>(
  (ref) => HoldingsRepository(ref.watch(databaseProvider)),
);

final ratesRepositoryProvider = Provider<RatesRepository>(
  (ref) => RatesRepository(ref.watch(holdingsRepositoryProvider)),
);

final holdingsProvider = StreamProvider<List<Holding>>(
  (ref) => ref.watch(holdingsRepositoryProvider).watchHoldings(),
);

final latestRateProvider = FutureProvider<RateSnapshot?>(
  (ref) => ref.watch(holdingsRepositoryProvider).getLatestRate(),
);

final holdingDetailsProvider = FutureProvider.family<Holding, int>(
  (ref, id) => ref.watch(holdingsRepositoryProvider).getHolding(id),
);

double holdingValue(Holding holding, RateSnapshot? rate) {
  if (rate == null) return 0;
  if (holding.type == 'usd') return holding.amount * rate.usdToEgp;
  final karatRatio = (holding.goldKarat ?? 24) / 24;
  return holding.amount * rate.goldPricePerGram24k * karatRatio;
}