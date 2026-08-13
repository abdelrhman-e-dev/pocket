import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/transaction_with_details.dart';
import '../repositories/transaction_repository.dart';
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
  PaginatedTransactionsNotifier(this._repository)
      : super(const PaginatedTransactionsState()) {
    loadInitial();
  }

  final TransactionRepository _repository;

  static const int pageSize = 10;

  Future<void> loadInitial({
    String? type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    state = state.copyWith(
      isLoading: true,
      isLoadingMore: false,
      items: [],
      hasMore: true,
    );

    try {
      final items = await _repository.getTransactionsWithDetails(
        type: type,
        limit: pageSize,
        offset: 0,
        startDate: startDate,
        endDate: endDate,
      );

      state = PaginatedTransactionsState(
        items: items,
        isLoading: false,
        isLoadingMore: false,
        hasMore: items.length == pageSize,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
      );
      rethrow;
    }
  }

  Future<void> loadMore({
    String? type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (state.isLoadingMore || !state.hasMore) {
      return;
    }

    state = state.copyWith(
      isLoadingMore: true,
    );

    try {
      final newItems = await _repository.getTransactionsWithDetails(
        type: type,
        limit: pageSize,
        offset: state.items.length,
        startDate: startDate,
        endDate: endDate,
      );

      final allItems = [
        ...state.items,
        ...newItems,
      ];

      state = state.copyWith(
        items: allItems,
        isLoadingMore: false,
        hasMore: newItems.length == pageSize,
      );
    } catch (_) {
      state = state.copyWith(
        isLoadingMore: false,
      );
      rethrow;
    }
  }
}

final paginatedTransactionsProvider = StateNotifierProvider<
    PaginatedTransactionsNotifier,
    PaginatedTransactionsState>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);

  return PaginatedTransactionsNotifier(repository);
});