import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/features/budget_hub/domain/category_gauge_data.dart';
import 'package:budgit/src/core/domain/models/transaction.dart';
import 'package:budgit/src/core/domain/models/category.dart';
import 'package:budgit/src/core/data/providers/category_list_provider.dart';
import 'package:budgit/src/features/transaction_hub/transactions/presentation/providers/transaction_log_provider.dart';
import 'package:budgit/src/features/budget_hub/domain/budget_progress.dart';
import 'package:budgit/src/features/budget_hub/domain/monthly_spending.dart';
import 'package:budgit/src/utils/clock_provider.dart';
import 'package:budgit/src/utils/palette_generator.dart';

part 'monthly_projection_providers.g.dart';

// --- DATA CLASSES ---

class MonthlySummaryDetails {
  final double totalSpending;
  final double dailyAverage;
  final int monthsCounted;
  final String highestMonth;

  MonthlySummaryDetails({
    required this.totalSpending,
    required this.dailyAverage,
    required this.monthsCounted,
    required this.highestMonth,
  });
}

class MonthlySpendingBreakdown {
  final DateTime date;
  final double recurring; // Fixed
  final double variable; // Variable
  final int transactionCount;

  double get total => recurring + variable;
  double get dailyAverage {
    final daysInMonth = DateTime(date.year, date.month + 1, 0).day;
    return total / daysInMonth;
  }

  MonthlySpendingBreakdown(
    this.date,
    this.recurring,
    this.variable,
    this.transactionCount,
  );
}

class MonthlyScreenData {
  const MonthlyScreenData({
    required this.historicalSpending,
    required this.budgetProgress,
    required this.summaryDetails,
  });
  final List<MonthlySpending> historicalSpending;
  final List<BudgetProgress> budgetProgress;
  final MonthlySummaryDetails summaryDetails;
}

// --- 1. MONTHLY CATEGORY PROGRESS ---
@riverpod
Future<List<BudgetProgress>> monthlyCategoryProgress(
  Ref ref,
  DateTime month,
) async {
  final categories = await ref.watch(categoryListProvider.future);
  final allOccurrences = await ref.watch(
    allTransactionOccurrencesProvider.future,
  );

  final timeFrameStartDate = DateTime(month.year, month.month, 1);
  final timeFrameEndDate = DateTime(month.year, month.month + 1, 0);
  final timeFrameDays = timeFrameEndDate.day;

  final List<BudgetProgress> progressList = [];

  for (final category in categories) {
    double dailyRate = (category.budgetAmount * 12) / 365.25;
    final projectedBudget = dailyRate * timeFrameDays;

    final actualSpending = allOccurrences
        .whereType<OneOffPayment>()
        .where(
          (p) =>
              p.category.id == category.id &&
              !p.date.isBefore(timeFrameStartDate) &&
              !p.date.isAfter(timeFrameEndDate),
        )
        .fold(0.0, (sum, p) => sum + p.amount);

    progressList.add(
      BudgetProgress(
        category: category,
        amountSpent: actualSpending,
        projectedBudget: projectedBudget,
      ),
    );
  }
  return progressList;
}

// --- 2. GLOBAL MONTHLY HISTORY ---
@Riverpod(keepAlive: true)
Future<List<MonthlySpending>> globalMonthlyHistory(Ref ref) async {
  final allOccurrences = await ref.watch(
    allTransactionOccurrencesProvider.future,
  );
  final now = ref.watch(clockNotifierProvider).now();
  final endMonth = DateTime(now.year, now.month, 1);

  if (allOccurrences.isEmpty)
    return [MonthlySpending(date: endMonth, amount: 0.0)];

  final firstDate = allOccurrences
      .map((t) => (t is OneOffPayment) ? t.date : (t as OneOffIncome).date)
      .reduce((a, b) => a.isBefore(b) ? a : b);
  final startMonth = DateTime(firstDate.year, firstDate.month, 1);
  final List<MonthlySpending> monthlyTotals = [];
  DateTime currentMonth = startMonth;

  while (currentMonth.isBefore(endMonth) ||
      currentMonth.isAtSameMomentAs(endMonth)) {
    final monthStartDate = currentMonth;
    final monthEndDate = DateTime(currentMonth.year, currentMonth.month + 1, 0);

    // Filter the payments for the month
    final paymentsForMonth = allOccurrences.whereType<OneOffPayment>().where(
      (p) => !p.date.isBefore(monthStartDate) && !p.date.isAfter(monthEndDate),
    );

    // Calculate the total
    final double totalForMonth = paymentsForMonth.fold(
      0.0,
      (sum, p) => sum + p.amount,
    );

    // Calculate the category breakdown
    final Map<String, double> catTotals = {};
    for (final p in paymentsForMonth) {
      catTotals[p.category.id] = (catTotals[p.category.id] ?? 0.0) + p.amount;
    }

    // Add to our list
    monthlyTotals.add(
      MonthlySpending(
        date: monthStartDate,
        amount: totalForMonth,
        categoryTotals: catTotals, // Feed the category map in here
      ),
    );
    currentMonth = DateTime(currentMonth.year, currentMonth.month + 1, 1);
  }
  return monthlyTotals;
}

// --- 3. MONTHLY SUMMARY DETAILS ---
@riverpod
Future<MonthlySummaryDetails> monthlySummaryDetails(
  Ref ref,
  DateTime month,
) async {
  final allOccurrences = await ref.watch(
    allTransactionOccurrencesProvider.future,
  );

  final timeFrameStartDate = DateTime(month.year, month.month, 1);
  final timeFrameEndDate = DateTime(month.year, month.month + 1, 0);

  final totalSpending = allOccurrences
      .whereType<OneOffPayment>()
      .where(
        (p) =>
            !p.date.isBefore(timeFrameStartDate) &&
            !p.date.isAfter(timeFrameEndDate),
      )
      .fold(0.0, (sum, p) => sum + p.amount);

  final dailyAverage = timeFrameEndDate.day > 0
      ? totalSpending / timeFrameEndDate.day
      : 0.0;

  final monthlySpending = <String, double>{};
  for (final payment in allOccurrences.whereType<OneOffPayment>()) {
    final key = DateFormat('yyyy-MM').format(payment.date);
    monthlySpending.update(
      key,
      (value) => value + payment.amount,
      ifAbsent: () => payment.amount,
    );
  }

  int monthsCounted = monthlySpending.keys.length;
  String highestMonth = 'N/A';
  if (monthlySpending.isNotEmpty) {
    final sortedMonths = monthlySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    highestMonth = DateFormat.yMMM().format(
      DateFormat('yyyy-MM').parse(sortedMonths.first.key),
    );
  }

  return MonthlySummaryDetails(
    totalSpending: totalSpending,
    dailyAverage: dailyAverage,
    monthsCounted: monthsCounted,
    highestMonth: highestMonth,
  );
}

// --- 4. CATEGORY HISTORICAL BREAKDOWN ---
@riverpod
List<MonthlySpendingBreakdown> historicalCategorySpending(
  Ref ref, {
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
  if (categoryPayments.isEmpty) return [];

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
    final variable = paymentsForMonth
        .where((p) => p.parentRecurringId == null)
        .fold(0.0, (sum, p) => sum + p.amount);
    final count = paymentsForMonth.length;

    result.add(MonthlySpendingBreakdown(month, recurring, variable, count));
  }
  return result;
}

@riverpod
MonthlySpendingBreakdown categoryMonthlyBreakdown(
  Ref ref, {
  required String categoryId,
  required DateTime month,
}) {
  final history = ref.watch(
    historicalCategorySpendingProvider(categoryId: categoryId),
  );
  return history.firstWhere(
    (item) => item.date.year == month.year && item.date.month == month.month,
    orElse: () => MonthlySpendingBreakdown(month, 0, 0, 0),
  );
}

// --- 5. CATEGORY GAUGE (DONUT CHART) DATA ---
@riverpod
CategoryGaugeData categoryGaugeData(
  Ref ref, {
  required Category category,
  required DateTime month,
}) {
  final allOccurrences =
      ref.watch(allTransactionOccurrencesProvider).value ?? [];

  final timeFrameStartDate = DateTime(month.year, month.month, 1);
  final timeFrameEndDate = DateTime(month.year, month.month + 1, 0);

  final monthlyPayments = allOccurrences
      .whereType<OneOffPayment>()
      .where(
        (p) =>
            p.category.id == category.id &&
            !p.date.isBefore(timeFrameStartDate) &&
            !p.date.isAfter(timeFrameEndDate),
      )
      .toList();

  final timeFrameDays = timeFrameEndDate.day;
  final double dailyRate = (category.budgetAmount * 12) / 365.25;
  final projectedBudget = dailyRate * timeFrameDays;

  // New Binary Split
  final recurringSpending = monthlyPayments
      .where((p) => p.parentRecurringId != null)
      .fold(0.0, (sum, p) => sum + p.amount);
  final variableSpending = monthlyPayments
      .where((p) => p.parentRecurringId == null)
      .fold(0.0, (sum, p) => sum + p.amount);
  final totalSpent = recurringSpending + variableSpending;

  final palette = generateSpendingPalette(category.color);

  final segments = [
    GaugeSegment(
      label: "Fixed",
      amount: recurringSpending,
      color: palette.recurring,
    ),
    GaugeSegment(
      label: "Variable",
      amount: variableSpending,
      color: palette.wallet,
    ),
  ];

  return CategoryGaugeData(
    segments: segments,
    totalBudget: projectedBudget,
    totalSpent: totalSpent,
  );
}

// --- 6. MONTHLY SCREEN AGGREGATOR ---
// Used by the main Budget Hub UI to ensure all data is loaded before building the screen
final selectedMonthProvider = StateProvider<DateTime?>((ref) => null);

@riverpod
Future<MonthlyScreenData> monthlyScreenData(Ref ref) async {
  final historicalSpending = await ref.watch(
    globalMonthlyHistoryProvider.future,
  );

  final selectedMonth =
      ref.watch(selectedMonthProvider) ??
      (historicalSpending.isNotEmpty
          ? historicalSpending.last.date
          : DateTime.now());

  final (budgetProgress, summaryDetails) = await (
    ref.watch(monthlyCategoryProgressProvider(selectedMonth).future),
    ref.watch(monthlySummaryDetailsProvider(selectedMonth).future),
  ).wait;

  return MonthlyScreenData(
    historicalSpending: historicalSpending,
    budgetProgress: budgetProgress,
    summaryDetails: summaryDetails,
  );
}
