import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/transaction_with_details.dart';
import '../models/transaction_filter.dart';
import '../models/transaction_period_filter.dart';
import 'transaction_filter_provider.dart';
import 'transaction_period_filter_provider.dart';
import 'transaction_repository_provider.dart';

class PaginatedTransactionsState {
  const PaginatedTransactionsState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
  });

  final List<TransactionWithDetails> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;

  PaginatedTransactionsState copyWith({
    List<TransactionWithDetails>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
  }) {
    return PaginatedTransactionsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class PaginatedTransactionsNotifier
    extends StateNotifier<PaginatedTransactionsState> {
  PaginatedTransactionsNotifier(
    this._repository,
    this._type,
    this._period,
    this._dateRange,
  ) : super(const PaginatedTransactionsState());

  final dynamic _repository;
  final TransactionFilter _type;
  final TransactionPeriodFilter _period;
  final DateTimeRange? _dateRange;

  static const int pageSize = 10;

  String? get dbType {
    return _type.dbType;
  }

  DateTime? get startDate {
    final now = DateTime.now();

    switch (_period) {
      case TransactionPeriodFilter.today:
        return DateTime(now.year, now.month, now.day);

      case TransactionPeriodFilter.thisWeek:
        final today = DateTime(now.year, now.month, now.day);

        return today.subtract(Duration(days: today.weekday - 1));

      case TransactionPeriodFilter.thisMonth:
        return DateTime(now.year, now.month, 1);

      case TransactionPeriodFilter.custom:
        return _dateRange?.start;
    }
  }

  DateTime? get endDate {
    final now = DateTime.now();

    switch (_period) {
      case TransactionPeriodFilter.today:
        return DateTime(now.year, now.month, now.day + 1);

      case TransactionPeriodFilter.thisWeek:
        final today = DateTime(now.year, now.month, now.day);

        final start = today.subtract(Duration(days: today.weekday - 1));

        return start.add(const Duration(days: 7));

      case TransactionPeriodFilter.thisMonth:
        return DateTime(now.year, now.month + 1, 1);

      case TransactionPeriodFilter.custom:
        if (_dateRange == null) return null;

        return DateTime(
          _dateRange.end.year,
          _dateRange.end.month,
          _dateRange.end.day + 1,
        );
    }
  }

  Future<List<TransactionWithDetails>> _fetch({required int offset}) {
    return _repository.getTransactionsWithDetails(
      type: dbType,
      limit: pageSize,
      offset: offset,
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<void> loadInitial() async {
    state = state.copyWith(
      isLoading: true,
      isLoadingMore: false,
      items: [],
      hasMore: true,
    );

    try {
      final items = await _fetch(offset: 0);

      state = PaginatedTransactionsState(
        items: items,
        isLoading: false,
        isLoadingMore: false,
        hasMore: items.length == pageSize,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) {
      return;
    }

    state = state.copyWith(isLoadingMore: true);

    try {
      final newItems = await _fetch(offset: state.items.length);

      state = state.copyWith(
        items: [...state.items, ...newItems],
        isLoadingMore: false,
        hasMore: newItems.length == pageSize,
      );
    } catch (_) {
      state = state.copyWith(isLoadingMore: false);
    }
  }
}

final paginatedTransactionsProvider =
    StateNotifierProvider<
      PaginatedTransactionsNotifier,
      PaginatedTransactionsState
    >((ref) {
      final repository = ref.watch(transactionRepositoryProviderPage);

      final type = ref.watch(transactionFilterProvider);

      final period = ref.watch(transactionPeriodFilterProvider);

      final dateRange = ref.watch(customTransactionDateRangeProvider);

      final notifier = PaginatedTransactionsNotifier(
        repository,
        type,
        period,
        dateRange,
      );

      notifier.loadInitial();

      return notifier;
    });
