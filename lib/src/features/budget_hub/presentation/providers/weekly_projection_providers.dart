import 'package:equatable/equatable.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:budgit/src/core/domain/models/transaction.dart';
import 'package:budgit/src/core/data/providers/category_list_provider.dart';
import 'package:budgit/src/features/transaction_hub/transactions/presentation/providers/transaction_log_provider.dart';
import 'package:budgit/src/features/budget_hub/domain/weekly_category_data.dart';
import 'package:budgit/src/features/budget_hub/domain/weekly_aggregate_data.dart';
import 'package:budgit/src/utils/clock_provider.dart';
import 'package:budgit/src/features/settings/data/settings_provider.dart';
import 'package:budgit/src/core/data/providers/transaction_repository_provider.dart';

part 'weekly_projection_providers.g.dart';

// --- 1. GLOBAL WEEKLY DATE CONTEXT ---
final weeklyDateProvider = StateProvider<DateTime>((ref) {
  return ref.read(clockNotifierProvider).now();
});

// --- 2. WEEKLY CATEGORY PROJECTIONS ---
@Riverpod(keepAlive: true)
Future<List<WeeklyCategoryData>> weeklyCategoryData(
  Ref ref, {
  required DateTime selectedDate,
}) async {
  final categories = await ref.watch(categoryListProvider.future);
  final transactionLog = await ref.watch(
    allTransactionOccurrencesProvider.future,
  );
  final settingsRepo = await ref.watch(settingsProvider.future);
  final repository = ref.watch(transactionRepositoryProvider);

  final now = ref.watch(clockNotifierProvider).now();
  final checkInDay = await settingsRepo.getCheckInDay();

  final startOfSelectedWeek = DateTime(
    selectedDate.year,
    selectedDate.month,
    selectedDate.day - (selectedDate.weekday - checkInDay + 7) % 7,
  );
  final endOfSelectedWeek = startOfSelectedWeek.add(const Duration(days: 7));
  final startOfCurrentWeek = DateTime(
    now.year,
    now.month,
    now.day - (now.weekday - checkInDay + 7) % 7,
  );

  final isCurrentWeek = startOfSelectedWeek.isAtSameMomentAs(
    startOfCurrentWeek,
  );
  final startOfToday = DateTime(now.year, now.month, now.day);

  final startOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
  final endOfMonth = DateTime(
    selectedDate.year,
    selectedDate.month + 1,
    0,
    23,
    59,
    59,
  );

  // Fetch BudgetTransfers (formerly WalletAdjustments)
  final allTransfers = await repository.getBudgetTransfersForWeek(
    startOfSelectedWeek,
  );

  final List<WeeklyCategoryData> result = [];

  for (final category in categories) {
    // A. Fixed Monthly Overhead
    final monthlyFixedSum = transactionLog
        .whereType<OneOffPayment>()
        .where(
          (p) =>
              p.category.id == category.id &&
              p.parentRecurringId != null &&
              !p.date.isBefore(startOfMonth) &&
              !p.date.isAfter(endOfMonth),
        )
        .fold(0.0, (sum, p) => sum + p.amount);

    // B. Base Weekly Variable Budget
    final monthlyVariableBudget = (category.budgetAmount - monthlyFixedSum)
        .clamp(0.0, double.infinity);
    final baseWeeklyBudget = monthlyVariableBudget / 4.333;

    // C. Weekly Variable Transactions
    final categoryVariableTxs = transactionLog.whereType<OneOffPayment>().where(
      (p) =>
          p.parentRecurringId == null &&
          p.category.id == category.id &&
          !p.date.isBefore(startOfSelectedWeek) &&
          p.date.isBefore(endOfSelectedWeek),
    );

    double spentInCompletedDays = 0.0;
    double spendingToday = 0.0;
    final List<double> currentWeekPattern = List.filled(7, 0.0);

    for (final tx in categoryVariableTxs) {
      final dayIndex = tx.date.difference(startOfSelectedWeek).inDays;
      if (dayIndex >= 0 && dayIndex < 7)
        currentWeekPattern[dayIndex] += tx.amount;

      if (isCurrentWeek) {
        if (tx.date.isBefore(startOfToday))
          spentInCompletedDays += tx.amount;
        else
          spendingToday += tx.amount;
      } else {
        spentInCompletedDays += tx.amount;
      }
    }

    // D. Transfers (formerly Boosts/Rollovers)
    final incoming = allTransfers
        .where((b) => b.toCategoryId == category.id)
        .fold(0.0, (sum, b) => sum + b.amount);

    for (final b in allTransfers.where(
      (b) => b.fromCategoryId == category.id,
    )) {
      final dayIndex = b.date.difference(startOfSelectedWeek).inDays;
      if (dayIndex >= 0 && dayIndex < 7)
        currentWeekPattern[dayIndex] += b.amount;

      if (isCurrentWeek) {
        if (b.date.isBefore(startOfToday))
          spentInCompletedDays += b.amount;
        else
          spendingToday += b.amount;
      } else {
        spentInCompletedDays += b.amount;
      }
    }

    // E. Math & Physics
    final double effectiveWeeklyBudget = baseWeeklyBudget + incoming;
    final int daysRemaining = isCurrentWeek
        ? (7 - now.difference(startOfCurrentWeek).inDays).clamp(1, 7)
        : 0;
    final double budgetAvailableAtStartOfDay =
        effectiveWeeklyBudget - spentInCompletedDays;
    final double recommendedDailySpending = daysRemaining > 0
        ? (budgetAvailableAtStartOfDay / daysRemaining).clamp(
            0.0,
            double.infinity,
          )
        : 0.0;

    // F. Historical Average Pattern
    final List<double> averageWeekPattern = List.filled(7, 0.0);
    final historyTxs = transactionLog.whereType<OneOffPayment>().where(
      (p) =>
          p.parentRecurringId == null &&
          p.category.id == category.id &&
          p.date.isBefore(startOfSelectedWeek),
    );

    if (historyTxs.isNotEmpty) {
      DateTime minDate = historyTxs.first.date;
      for (final tx in historyTxs)
        if (tx.date.isBefore(minDate)) minDate = tx.date;

      final startOfMinWeek = DateTime(
        minDate.year,
        minDate.month,
        minDate.day - (minDate.weekday - checkInDay + 7) % 7,
      );
      final diffDays = startOfSelectedWeek.difference(startOfMinWeek).inDays;
      final numberOfWeeks = (diffDays / 7).ceil();

      if (numberOfWeeks > 0) {
        final List<double> totals = List.filled(7, 0.0);
        for (final tx in historyTxs)
          totals[(tx.date.weekday - checkInDay + 7) % 7] += tx.amount;
        for (int i = 0; i < 7; i++)
          averageWeekPattern[i] = totals[i] / numberOfWeeks;
      }
    }

    result.add(
      WeeklyCategoryData(
        category: category,
        spentInCompletedDays: spentInCompletedDays,
        spendingToday: spendingToday,
        baseWeeklyBudget: baseWeeklyBudget,
        effectiveWeeklyBudget: effectiveWeeklyBudget,
        recommendedDailySpending: recommendedDailySpending,
        daysRemaining: daysRemaining,
        currentWeekPattern: currentWeekPattern,
        averageWeekPattern: averageWeekPattern,
      ),
    );
  }

  return result;
}

// --- 3. WEEKLY AGGREGATE SUMMARY ---
@riverpod
Future<WeeklyAggregateData> weeklyAggregate(Ref ref) async {
  final now = ref.watch(clockNotifierProvider).now();
  final categoryDataList = await ref.watch(
    weeklyCategoryDataProvider(selectedDate: now).future,
  );

  double totalVariableBudget = 0.0;
  double spentCompletedDays = 0.0;
  double spendingToday = 0.0;

  for (final data in categoryDataList) {
    totalVariableBudget += data.effectiveWeeklyBudget;
    spentCompletedDays += data.spentInCompletedDays;
    spendingToday += data.spendingToday;
  }

  final checkInDay = await ref
      .watch(settingsProvider.future)
      .then((s) => s.getCheckInDay());
  final startOfCurrentWeek = DateTime(
    now.year,
    now.month,
    now.day - (now.weekday - checkInDay + 7) % 7,
  );
  final completedDays = DateTime(
    now.year,
    now.month,
    now.day,
  ).difference(startOfCurrentWeek).inDays.clamp(0, 7);

  return WeeklyAggregateData(
    totalVariableBudget: totalVariableBudget,
    spentCompletedDays: spentCompletedDays,
    spendingToday: spendingToday,
    completedDays: completedDays,
  );
}

// --- 4. WEEKLY CHART DATA ---
class WeeklyChartData extends Equatable {
  final Map<int, Map<String, double>> dailyTotals;
  final double dailyTarget;
  final double averageDailySpend;
  final double maxY;

  const WeeklyChartData({
    required this.dailyTotals,
    required this.dailyTarget,
    required this.averageDailySpend,
    required this.maxY,
  });

  @override
  List<Object?> get props => [
    dailyTotals,
    dailyTarget,
    averageDailySpend,
    maxY,
  ];
}

@riverpod
Future<WeeklyChartData> weeklyChartData(
  Ref ref, {
  required DateTime selectedDate,
}) async {
  final categoryDataList = await ref.watch(
    weeklyCategoryDataProvider(selectedDate: selectedDate).future,
  );
  final checkInDay = await ref
      .watch(settingsProvider.future)
      .then((s) => s.getCheckInDay());
  final now = ref.watch(clockNotifierProvider).now();

  final startOfSelectedWeek = DateTime(
    selectedDate.year,
    selectedDate.month,
    selectedDate.day - (selectedDate.weekday - checkInDay + 7) % 7,
  );
  final startOfCurrentWeek = DateTime(
    now.year,
    now.month,
    now.day - (now.weekday - checkInDay + 7) % 7,
  );

  int completedDays = startOfSelectedWeek.isAtSameMomentAs(startOfCurrentWeek)
      ? DateTime(
          now.year,
          now.month,
          now.day,
        ).difference(startOfSelectedWeek).inDays.clamp(0, 7)
      : 7;

  final dailyTotals = <int, Map<String, double>>{};
  double totalEffectiveWeeklyBudget = 0.0;
  double totalSpentInCompletedDays = 0.0;

  for (final data in categoryDataList) {
    totalEffectiveWeeklyBudget += data.effectiveWeeklyBudget;
    totalSpentInCompletedDays += data.spentInCompletedDays;

    for (int i = 0; i < 7; i++) {
      final amount = data.currentWeekPattern[i];
      if (amount != 0) {
        dailyTotals.putIfAbsent(i, () => {});
        dailyTotals[i]![data.category.id] =
            (dailyTotals[i]![data.category.id] ?? 0.0) + amount;
      }
    }
  }

  final dailyTarget = totalEffectiveWeeklyBudget > 0
      ? totalEffectiveWeeklyBudget / 7.0
      : 0.0;
  final averageDailySpend = (completedDays > 0 && totalSpentInCompletedDays > 0)
      ? totalSpentInCompletedDays / completedDays
      : 0.0;

  double maxY = dailyTarget > 0 ? dailyTarget : 50.0;
  if (averageDailySpend > maxY) maxY = averageDailySpend;
  dailyTotals.values.forEach((dayMap) {
    final dayTotal = dayMap.values.fold(0.0, (sum, val) => sum + val);
    if (dayTotal > maxY) maxY = dayTotal;
  });

  return WeeklyChartData(
    dailyTotals: dailyTotals,
    dailyTarget: dailyTarget,
    averageDailySpend: averageDailySpend,
    maxY: maxY * 1.2,
  );
}
