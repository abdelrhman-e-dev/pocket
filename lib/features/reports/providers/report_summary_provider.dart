import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../repositories/reports_repository.dart';
import 'reports_repository_provider.dart';

final reportSummaryProvider =
    FutureProvider.family<ReportSummary, DateTimeRange>((ref, range) async {
      final repository = ref.watch(reportsRepositoryProvider);

      return repository.getSummary(start: range.start, end: range.end);
    });

final reportCategoriesProvider =
    FutureProvider.family<List<ExpenseByCategory>, DateTimeRange>((
      ref,
      range,
    ) async {
      final repository = ref.watch(reportsRepositoryProvider);

      return repository.getExpensesByCategory(
        start: range.start,
        end: range.end,
      );
    });

final dailyReportsProvider =
    FutureProvider.family<List<DailyReport>, DateTimeRange>((ref, range) async {
      final repository = ref.watch(reportsRepositoryProvider);

      return repository.getDailyExpenses(start: range.start, end: range.end);
    });
