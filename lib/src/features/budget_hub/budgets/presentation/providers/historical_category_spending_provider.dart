// lib/src/features/budget_hub/budgets/presentation/providers/historical_category_spending_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:collection/collection.dart';
import 'package:budgit/src/core/domain/models/transaction.dart';
import 'package:budgit/src/features/transaction_hub/transactions/presentation/providers/transaction_log_provider.dart';
import 'package:budgit/src/utils/clock_provider.dart';

part 'historical_category_spending_provider.g.dart';

class MonthlySpendingBreakdown {
  final DateTime date;
  final double recurring;
  final double wallet;
  final double oneOff;
  final int transactionCount; // <--- NEW FIELD

  double get total => recurring + wallet + oneOff;

  // <--- NEW GETTER: Calculate daily average based on days in this specific month
  double get dailyAverage {
    final daysInMonth = DateTime(date.year, date.month + 1, 0).day;
    return total / daysInMonth;
  }

  MonthlySpendingBreakdown(
    this.date, 
    this.recurring, 
    this.wallet, 
    this.oneOff, 
    this.transactionCount, // Add to constructor
  );
}

@riverpod
List<MonthlySpendingBreakdown> historicalCategorySpending(
  HistoricalCategorySpendingRef ref, {
  required String categoryId,
}) {
  final allOccurrencesAsync = ref.watch(allTransactionOccurrencesProvider);
  
  if (!allOccurrencesAsync.hasValue) return [];

  final allOccurrences = allOccurrencesAsync.value!;
  final now = ref.watch(clockNotifierProvider).now();

  final categoryPayments = allOccurrences
      .whereType<OneOffPayment>()
      .where((p) => p.category.id == categoryId)
      .toList();

  if (categoryPayments.isEmpty) {
    return [];
  }

  final groupedByMonth = groupBy<OneOffPayment, DateTime>(
    categoryPayments,
    (p) => DateTime(p.date.year, p.date.month, 1),
  );

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

  final List<MonthlySpendingBreakdown> result = [];
  for (final month in allMonthsInRange) {
    final paymentsForMonth = groupedByMonth[month] ?? [];

    final recurring = paymentsForMonth
        .where((p) => p.parentRecurringId != null)
        .fold(0.0, (sum, p) => sum + p.amount);

    final wallet = paymentsForMonth
        .where((p) => p.parentRecurringId == null && p.isWalleted)
        .fold(0.0, (sum, p) => sum + p.amount);

    final oneOff = paymentsForMonth
        .where((p) => p.parentRecurringId == null && !p.isWalleted)
        .fold(0.0, (sum, p) => sum + p.amount);
        
    // <--- Calculate count here
    final count = paymentsForMonth.length; 

    result.add(MonthlySpendingBreakdown(
      month, 
      recurring, 
      wallet, 
      oneOff, 
      count, // Pass to constructor
    ));
  }

  return result;
}

@riverpod
MonthlySpendingBreakdown categoryMonthlyBreakdown(
  CategoryMonthlyBreakdownRef ref, {
  required String categoryId,
  required DateTime month,
}) {
  final history = ref.watch(historicalCategorySpendingProvider(categoryId: categoryId));
  
  return history.firstWhere(
    (item) => item.date.year == month.year && item.date.month == month.month,
    // Return zeros if not found
    orElse: () => MonthlySpendingBreakdown(month, 0, 0, 0, 0),
  );
}