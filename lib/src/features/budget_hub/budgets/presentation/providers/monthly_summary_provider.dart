// lib/src/features/budgets/presentation/providers/budget_summary_details_provider.dart
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:budgit/src/core/domain/models/transaction.dart';
import 'package:budgit/src/features/transaction_hub/transactions/presentation/providers/transaction_log_provider.dart';

part 'monthly_summary_provider.g.dart';

/// A data class to hold the detailed summary values for the budget screen.
class BudgetSummaryDetails {
  final double totalSpending;
  final double dailyAverage;
  final int monthsCounted;
  final String highestMonth;

  BudgetSummaryDetails({
    required this.totalSpending,
    required this.dailyAverage,
    required this.monthsCounted,
    required this.highestMonth,
  });
}

@riverpod
Future<BudgetSummaryDetails> budgetSummaryDetails(
    BudgetSummaryDetailsRef ref, DateTime month) async {
  final allOccurrences = await ref.watch(allTransactionOccurrencesProvider.future);

  // --- Total Spending for the selected month ---
  final timeFrameStartDate = DateTime(month.year, month.month, 1);
  final timeFrameEndDate = DateTime(month.year, month.month + 1, 0);
  final totalSpending = allOccurrences
      .whereType<OneOffPayment>()
      .where((p) =>
          !p.date.isBefore(timeFrameStartDate) &&
          !p.date.isAfter(timeFrameEndDate))
      .fold(0.0, (sum, p) => sum + p.amount);

  // --- Daily Average for the selected month ---
  final daysInMonth = timeFrameEndDate.day;
  final dailyAverage = daysInMonth > 0 ? totalSpending / daysInMonth : 0.0;

  // --- Months Counted & Highest Month from all historical data ---
  final monthlySpending = <String, double>{};
  for (final payment in allOccurrences.whereType<OneOffPayment>()) {
    final key = DateFormat('yyyy-MM').format(payment.date);
    monthlySpending.update(key, (value) => value + payment.amount,
        ifAbsent: () => payment.amount);
  }

  int monthsCounted = monthlySpending.keys.length;
  String highestMonth = 'N/A';
  if (monthlySpending.isNotEmpty) {
    final sortedMonths = monthlySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final highestMonthDate = DateFormat('yyyy-MM').parse(sortedMonths.first.key);
    highestMonth = DateFormat.yMMM().format(highestMonthDate);
  }

  return BudgetSummaryDetails(
    totalSpending: totalSpending,
    dailyAverage: dailyAverage,
    monthsCounted: monthsCounted,
    highestMonth: highestMonth,
  );
}