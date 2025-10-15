// lib/src/features/budgets/presentation/providers/historical_spending_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/features/budgets/domain/monthly_spending.dart';
import 'package:budgit/src/features/transactions/domain/transaction.dart';
import 'package:budgit/src/features/transactions/presentation/providers/transaction_log_provider.dart';
import 'package:budgit/src/utils/clock_provider.dart';

part 'historical_spending_provider.g.dart';

@Riverpod(keepAlive: true)
Future<List<MonthlySpending>> historicalSpending(
    Ref ref) async {
  final allOccurrences =
      await ref.watch(allTransactionOccurrencesProvider.future);
  final now = ref.watch(clockNotifierProvider).now();
  final endMonth = DateTime(now.year, now.month, 1);

  // If there are no transactions, just return the current month.
  if (allOccurrences.isEmpty) {
    return [MonthlySpending(date: endMonth, amount: 0.0)];
  }

  // **THE FIX: Find the date of the very first transaction.**
  final firstDate = allOccurrences
      .map((t) => (t is OneOffPayment) ? t.date : (t as OneOffIncome).date)
      .reduce((a, b) => a.isBefore(b) ? a : b);

  final startMonth = DateTime(firstDate.year, firstDate.month, 1);

  final List<MonthlySpending> monthlyTotals = [];
  DateTime currentMonth = startMonth;

  // **Loop forward from the first month to the current month.**
  while (currentMonth.isBefore(endMonth) ||
      currentMonth.isAtSameMomentAs(endMonth)) {
    final monthStartDate = currentMonth;
    final monthEndDate = DateTime(currentMonth.year, currentMonth.month + 1, 0);

    // Calculate the total spending for the current month in the loop.
    final double totalForMonth = allOccurrences
        .whereType<OneOffPayment>() // Consider only payments for spending
        .where((p) =>
            !p.date.isBefore(monthStartDate) && !p.date.isAfter(monthEndDate))
        .fold(0.0, (sum, p) => sum + p.amount);

    monthlyTotals.add(
      MonthlySpending(date: monthStartDate, amount: totalForMonth),
    );

    // Increment to the next month.
    currentMonth = DateTime(currentMonth.year, currentMonth.month + 1, 1);
  }

  // The list is already in chronological order, so no reversal is needed.
  return monthlyTotals;
}