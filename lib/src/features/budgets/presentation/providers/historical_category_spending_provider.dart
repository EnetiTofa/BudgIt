// lib/src/features/budgets/presentation/providers/historical_category_spending_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:collection/collection.dart';
import 'package:budgit/src/features/transactions/domain/transaction.dart';
import 'package:budgit/src/features/transactions/presentation/providers/transaction_log_provider.dart';
import 'package:budgit/src/features/budgets/presentation/widgets/historical_category_chart.dart';
import 'package:budgit/src/utils/clock_provider.dart';

part 'historical_category_spending_provider.g.dart';

@riverpod
Future<List<MonthlySpendingBreakdown>> historicalCategorySpending(
  HistoricalCategorySpendingRef ref, {
  required String categoryId,
}) async {
  final allOccurrences =
      await ref.watch(allTransactionOccurrencesProvider.future);
  final now = ref.watch(clockProvider).now();

  // Filter for payments of the specified category
  final categoryPayments = allOccurrences
      .whereType<OneOffPayment>()
      .where((p) => p.category.id == categoryId)
      .toList();

  if (categoryPayments.isEmpty) {
    return [];
  }

  // Group payments by month
  final groupedByMonth = groupBy<OneOffPayment, DateTime>(
    categoryPayments,
    (p) => DateTime(p.date.year, p.date.month, 1),
  );

  // Determine the full date range to show, ensuring no gaps
  final firstDate = categoryPayments
      .map((p) => p.date)
      .reduce((a, b) => a.isBefore(b) ? a : b);
  final startMonth = DateTime(firstDate.year, firstDate.month, 1);
  final endMonth = DateTime(now.year, now.month, 1);

  final List<DateTime> allMonthsInRange = [];
  DateTime currentMonth = startMonth;
  while (currentMonth.isBefore(endMonth) ||
      currentMonth.isAtSameMomentAs(endMonth)) {
    allMonthsInRange.add(currentMonth);
    currentMonth = DateTime(currentMonth.year, currentMonth.month + 1, 1);
  }

  // Calculate totals for each month in the range
  final List<MonthlySpendingBreakdown> result = [];
  for (final month in allMonthsInRange) {
    final paymentsForMonth = groupedByMonth[month] ?? [];

    // --- UPDATED LOGIC ---
    final recurring = paymentsForMonth
        .where((p) => p.parentRecurringId != null)
        .fold(0.0, (sum, p) => sum + p.amount);

    final wallet = paymentsForMonth
        .where((p) => p.parentRecurringId == null && p.isWalleted)
        .fold(0.0, (sum, p) => sum + p.amount);

    final oneOff = paymentsForMonth
        .where((p) => p.parentRecurringId == null && !p.isWalleted)
        .fold(0.0, (sum, p) => sum + p.amount);
    // ---------------------

    result.add(MonthlySpendingBreakdown(month, recurring, wallet, oneOff));
  }

  return result;
}