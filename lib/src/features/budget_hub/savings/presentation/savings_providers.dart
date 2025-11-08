// lib/src/features/savings/presentation/savings_providers.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:budgit/src/core/data/providers/transaction_repository_provider.dart';
import 'package:budgit/src/core/data/providers/category_list_provider.dart';
import 'package:budgit/src/core/domain/models/transaction.dart';
import 'package:budgit/src/features/settings/data/settings_provider.dart';
import 'package:budgit/src/core/domain/models/savings_goal.dart';
import 'package:budgit/src/utils/clock_provider.dart';
import 'package:budgit/src/features/transaction_hub/transactions/presentation/providers/transaction_log_provider.dart';


part 'savings_providers.g.dart';

// --- DATA CLASSES ---

class MonthlySavingsDetails {
  final double income;
  final double spending;
  final double savings;
  MonthlySavingsDetails({
    this.income = 0.0,
    this.spending = 0.0,
    this.savings = 0.0,
  });
}

class MonthlySavings {
  final DateTime date;
  final double amount;
  MonthlySavings({required this.date, required this.amount});
}

class SavingsScreenData {
  final Map<String, MonthlySavingsDetails> monthlyDetailsMap;
  final List<MonthlySavings> historicalSavings;
  SavingsScreenData({
    required this.monthlyDetailsMap,
    required this.historicalSavings,
  });
}

class SavingsGaugeData {
  final double amountProgress;
  final int completedCheckIns;
  final int totalCheckIns;
  final double currentAmount;
  final double targetAmount;

  SavingsGaugeData({
    required this.amountProgress,
    required this.completedCheckIns,
    required this.totalCheckIns,
    required this.currentAmount,
    required this.targetAmount,
  });
}

// --- STATE PROVIDERS ---

final savingsScreenSelectedMonthProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

// --- DATA PROVIDERS ---

@riverpod
Future<SavingsScreenData> savingsScreenData(SavingsScreenDataRef ref) async {
  final occurrences = await ref.watch(allTransactionOccurrencesProvider.future);
  final now = ref.watch(clockNotifierProvider).now();

  final monthlyDetailsMap = <String, MonthlySavingsDetails>{};

  for (int i = 0; i < 12; i++) {
    final monthDate = DateTime(now.year, now.month - i, 1);
    final key = DateFormat('yyyy-MM').format(monthDate);
    monthlyDetailsMap[key] = MonthlySavingsDetails();
  }

  for (final transaction in occurrences) {
    DateTime? date;
    double income = 0;
    double spending = 0;

    if (transaction is OneOffIncome) {
      date = transaction.date;
      income = transaction.amount;
    } else if (transaction is OneOffPayment) {
      date = transaction.date;
      spending = transaction.amount;
    }

    if (date != null) {
      final key = DateFormat('yyyy-MM').format(date);
      if (monthlyDetailsMap.containsKey(key)) {
        final current = monthlyDetailsMap[key]!;
        monthlyDetailsMap[key] = MonthlySavingsDetails(
          income: current.income + income,
          spending: current.spending + spending,
          savings: (current.income + income) - (current.spending + spending),
        );
      }
    }
  }

  final historicalSavings = monthlyDetailsMap.entries.map((entry) {
    return MonthlySavings(
      date: DateFormat('yyyy-MM').parse(entry.key),
      amount: entry.value.savings,
    );
  }).toList();

  historicalSavings.sort((a, b) => a.date.compareTo(b.date));

  return SavingsScreenData(
    monthlyDetailsMap: monthlyDetailsMap,
    historicalSavings: historicalSavings,
  );
}

@riverpod
Future<SavingsGaugeData> savingsGaugeData(SavingsGaugeDataRef ref) async {
  final goal = await ref.watch(savingsGoalProvider.future);
  final now = ref.watch(clockNotifierProvider).now();
  final settings = await ref.watch(settingsProvider.future);
  final checkInDay = await settings.getCheckInDay();
  final occurrences = await ref.watch(allTransactionOccurrencesProvider.future);

  if (goal == null) {
    final totalSavings = await ref.watch(totalSavingsProvider.future);
    return SavingsGaugeData(
      amountProgress: 0,
      completedCheckIns: 0,
      totalCheckIns: 1,
      currentAmount: totalSavings,
      targetAmount: 0,
    );
  }

  // ... (Calculations for currentAmount, savingsRate, etc. are unchanged) ...
  final transactionsInRange = occurrences.where((t) {
    DateTime? date;
    if (t is OneOffPayment) date = t.date;
    if (t is OneOffIncome) date = t.date;
    return date != null && !date.isBefore(goal.createdAt) && !date.isAfter(now);
  }).toList();
  final incomeInRange = transactionsInRange.whereType<OneOffIncome>().fold(0.0, (sum, i) => sum + i.amount);
  final spendingInRange = transactionsInRange.whereType<OneOffPayment>().fold(0.0, (sum, p) => sum + p.amount);
  final currentAmount = incomeInRange - spendingInRange;
  final allIncome = occurrences.whereType<OneOffIncome>().toList();
  double averageWeeklyIncome = 0;
  if (allIncome.isNotEmpty) {
    allIncome.sort((a, b) => a.date.compareTo(b.date));
    final firstIncomeDate = allIncome.first.date;
    final lastIncomeDate = allIncome.last.date;
    final totalDays = lastIncomeDate.difference(firstIncomeDate).inDays;
    final totalWeeks = (totalDays / 7).clamp(1.0, double.infinity);
    final totalIncomeAmount = allIncome.fold(0.0, (sum, i) => sum + i.amount);
    averageWeeklyIncome = totalIncomeAmount / totalWeeks;
  }
  final categories = await ref.watch(categoryListProvider.future);
  final totalMonthlyBudget = categories.fold(0.0, (sum, cat) => sum + cat.budgetAmount);
  final totalWeeklyBudget = totalMonthlyBudget / 4.33;
  final savingsRate = averageWeeklyIncome - totalWeeklyBudget;
  final targetAmount = goal.targetAmount;
  final amountProgress = (targetAmount > 0) ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0.0;
  final amountRemaining = (targetAmount - currentAmount).isNegative ? 0.0 : (targetAmount - currentAmount);
  final weeksRemaining = (savingsRate > 0) ? (amountRemaining / savingsRate).ceil() : 0;

  int completedCheckIns = 0;
  if (now.isAfter(goal.createdAt)) {
    // 1. Find the date of the very first check-in day on or after the goal's start date.
    DateTime firstCheckInEvent = goal.createdAt;
    int daysUntilFirstCheckIn = (checkInDay - firstCheckInEvent.weekday + 7) % 7;
    firstCheckInEvent = firstCheckInEvent.add(Duration(days: daysUntilFirstCheckIn));

    // --- THE FIX ---
    // 2. A check-in is only "completed" after the *next* check-in day has been reached.
    // We create a "completion boundary" which is the start of the next check-in period.
    final completionBoundary = firstCheckInEvent.add(const Duration(days: 1));

    // 3. Only if the current time is on or after this boundary can we start counting completed weeks.
    if (!now.isBefore(completionBoundary)) {
      completedCheckIns = (now.difference(firstCheckInEvent).inDays / 7).floor();
    }
    // --- END OF FIX ---
  }

  final totalCheckIns = completedCheckIns + weeksRemaining;

  return SavingsGaugeData(
    amountProgress: amountProgress,
    completedCheckIns: completedCheckIns,
    totalCheckIns: totalCheckIns > 0 ? totalCheckIns : 1,
    currentAmount: currentAmount,
    targetAmount: targetAmount,
  );
}

@riverpod
Future<double> averageWeeklySavings(Ref ref) {
  return Future.value(25.50);
}

@riverpod
Future<double> totalSavings(Ref ref) {
  return ref.watch(transactionRepositoryProvider).getTotalSavings();
}

@riverpod
Future<double> potentialWeeklySavings(Ref ref) async {
  final categories = await ref.watch(categoryListProvider.future);
  final totalWalletBudget = categories.fold(0.0, (sum, cat) => sum + (cat.walletAmount ?? 0.0));
  return totalWalletBudget * 0.15;
}

@riverpod
Future<SavingsGoal?> savingsGoal(SavingsGoalRef ref) {
  return ref.watch(transactionRepositoryProvider).getSavingsGoal();
}