import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:budgit/src/features/check_in/domain/check_in_state.dart';
import 'package:budgit/src/core/data/providers/transaction_repository_provider.dart';
import 'package:budgit/src/core/domain/models/transaction.dart';
import 'package:budgit/src/features/settings/data/settings_provider.dart';
import 'package:budgit/src/utils/clock_provider.dart';
import 'package:budgit/src/features/budget_hub/domain/budget_transfer.dart';
import 'package:budgit/src/features/check_in/presentation/providers/is_check_in_available_provider.dart';
import 'package:budgit/src/features/check_in/presentation/providers/streak_provider.dart';
import 'package:budgit/src/features/check_in/presentation/providers/app_bar_info_provider.dart';

import 'package:budgit/src/features/budget_hub/presentation/providers/weekly_projection_providers.dart';

part 'check_in_controller.g.dart';

@riverpod
class CheckInController extends _$CheckInController {
  @override
  CheckInState build() {
    return const CheckInState();
  }

  Future<({DateTime start, DateTime end})> _getWeekRange() async {
    final clock = ref.read(clockNotifierProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final checkInDay = await settingsNotifier.getCheckInDay();
    final now = clock.now();

    final daysSinceCheckIn = (now.weekday - checkInDay + 7) % 7;
    final endOfLastWeek = DateTime(
      now.year,
      now.month,
      now.day - daysSinceCheckIn - 1,
      23,
      59,
      59,
    );
    final startOfLastWeek = endOfLastWeek.subtract(const Duration(days: 6));
    final startOfLastWeekClean = DateTime(
      startOfLastWeek.year,
      startOfLastWeek.month,
      startOfLastWeek.day,
    );

    return (start: startOfLastWeekClean, end: endOfLastWeek);
  }

  Future<void> startCheckIn() async {
    state = state.copyWith(status: CheckInStatus.loading);
    await _calculateCheckInData();
  }

  Future<void> refreshData() async {
    await _calculateCheckInData();
  }

  Future<void> _calculateCheckInData() async {
    final repository = ref.read(transactionRepositoryProvider);
    final allTransactions = await repository.getAllTransactions();

    final range = await _getWeekRange();
    final pastAdjustments = await repository.getBudgetTransfersForWeek(
      range.start,
    );

    // Fetch the recalculated engine data
    final pastWeekData = await ref.read(
      weeklyCategoryDataProvider(selectedDate: range.start).future,
    );

    final Map<String, double> unspentByCategory = {};
    final Map<String, double> overspentByCategory = {};
    final Map<String, int> debtStreaks = {};
    final List<Transaction> weekTransactions = [];

    // Filter Variable Transactions for UI display
    for (final transaction in allTransactions) {
      if (transaction is OneOffPayment &&
          transaction.parentRecurringId == null) {
        if (!transaction.date.isBefore(range.start) &&
            transaction.date.isBefore(range.end)) {
          weekTransactions.add(transaction);
        }
      }
    }

    // Assign Unspent/Overspent from the unified calculation
    for (final data in pastWeekData) {
      // Amount remaining automatically reflects transfers now!
      final difference = data.amountRemainingThisWeek;

      if (difference > 0) {
        unspentByCategory[data.category.id] = difference;
      } else if (difference < 0) {
        overspentByCategory[data.category.id] = difference.abs();
      }

      debtStreaks[data.category.id] = 0;
    }

    weekTransactions.sort((a, b) {
      final dateA = a is OneOffPayment ? a.date : DateTime.now();
      final dateB = b is OneOffPayment ? b.date : DateTime.now();
      return dateB.compareTo(dateA);
    });

    // SAFETY CLAMP: If user transferred funds away, ensure rollover amounts shrink to match the new lower unspent limits
    final Map<String, double> validatedRollovers = {};
    for (var entry in state.rolloverAmounts.entries) {
      final maxUnspent = unspentByCategory[entry.key] ?? 0.0;
      final clamped = entry.value.clamp(0.0, maxUnspent);
      if (clamped > 0) validatedRollovers[entry.key] = clamped;
    }

    state = state.copyWith(
      status: CheckInStatus.dataReady,
      unspentFundsByCategory: unspentByCategory,
      overspentFundsByCategory: overspentByCategory,
      weekTransactions: weekTransactions,
      checkInWeekDate: range.end.subtract(const Duration(minutes: 1)),
      checkInWeekBoosts: pastAdjustments,
      debtStreaks: debtStreaks,
      rolloverAmounts: validatedRollovers, // Apply the safe limits
    );
  }

  void toggleDebtRollover(String categoryId) {
    final newSet = Set<String>.from(state.rollingOverDebtCategoryIds);
    if (newSet.contains(categoryId)) {
      newSet.remove(categoryId);
    } else {
      newSet.add(categoryId);
    }
    state = state.copyWith(rollingOverDebtCategoryIds: newSet);
  }

  Future<void> applyCheckInBoost({
    String? existingBoostId,
    required String fromCategoryId,
    required String toCategoryId,
    required double amount,
  }) async {
    final repository = ref.read(transactionRepositoryProvider);
    final range = await _getWeekRange();
    final date =
        state.checkInWeekDate ??
        DateTime.now().subtract(const Duration(days: 7));

    final targetBoosts = state.checkInWeekBoosts
        .where((b) => b.toCategoryId == toCategoryId)
        .toList();
    if (existingBoostId != null) {
      targetBoosts.removeWhere((b) => b.id == existingBoostId);
    }
    if (amount > 0) {
      targetBoosts.add(
        BudgetTransfer(
          id:
              existingBoostId ??
              'historical_boost_${DateTime.now().millisecondsSinceEpoch}',
          fromCategoryId: fromCategoryId,
          toCategoryId: toCategoryId,
          amount: amount,
          date: date,
        ),
      );
    }

    await repository.deleteBudgetTransfers(toCategoryId, date);
    for (final adj in targetBoosts) {
      await repository.addBudgetTransfer(adj);
    }

    // --- THE MAGIC FIX ---
    // Destroy the old cached math and force the Unified Engine to recalculate!
    ref.invalidate(weeklyCategoryDataProvider(selectedDate: range.start));
    ref.invalidate(weeklyAggregateProvider);

    await refreshData();
  }

  void makeDecision(RolloverDecision decision) {
    state = state.copyWith(decision: decision);
    if (decision == RolloverDecision.save) {
      state = state.copyWith(rolloverAmounts: {});
    }
  }

  void updateRolloverAmount(String categoryId, double amount) {
    final newAmounts = Map<String, double>.from(state.rolloverAmounts);
    final unspent = state.unspentFundsByCategory[categoryId] ?? 0;

    final clampedAmount = amount.clamp(0.0, unspent);
    if (clampedAmount > 0) {
      newAmounts[categoryId] = clampedAmount;
    } else {
      newAmounts.remove(categoryId);
    }
    state = state.copyWith(rolloverAmounts: newAmounts);
  }

  Future<bool> completeCheckIn() async {
    final repository = ref.read(transactionRepositoryProvider);
    final clock = ref.read(clockNotifierProvider);
    final now = clock.now();
    final range = await _getWeekRange();

    final nextWeekStart = range.end.add(const Duration(seconds: 1));
    final isMonthBoundary = range.start.month != nextWeekStart.month;

    for (var entry in state.unspentFundsByCategory.entries) {
      final categoryId = entry.key;
      final rolloverAmount = state.rolloverAmounts[categoryId] ?? 0.0;

      if (rolloverAmount > 0) {
        final rollover = BudgetTransfer(
          id: 'rollover_${categoryId}_${now.toIso8601String()}',
          fromCategoryId: 'rollover',
          toCategoryId: categoryId,
          amount: rolloverAmount,
          date: now,
        );
        await repository.addBudgetTransfer(rollover);
      }
    }

    for (final categoryId in state.rollingOverDebtCategoryIds) {
      final debtAmount = state.overspentFundsByCategory[categoryId] ?? 0.0;

      if (debtAmount > 0 && !isMonthBoundary) {
        final debtAdjustment = BudgetTransfer(
          id: 'rollover_debt_${categoryId}_${now.toIso8601String()}',
          fromCategoryId: 'rollover',
          toCategoryId: categoryId,
          amount: -debtAmount,
          date: now,
        );
        await repository.addBudgetTransfer(debtAdjustment);
      }
    }

    final pastWeekData = await ref.read(
      weeklyCategoryDataProvider(selectedDate: range.start).future,
    );
    double totalVariableBudget = 0;
    double totalVariableSpent = 0;

    for (final data in pastWeekData) {
      totalVariableBudget += data.effectiveWeeklyBudget;
      totalVariableSpent += data.totalSpentThisWeek;
    }

    bool isSuccess = totalVariableSpent <= totalVariableBudget;

    if (!isSuccess && state.overspentFundsByCategory.isNotEmpty) {
      final allDebtAccountedFor =
          state.rollingOverDebtCategoryIds.length ==
          state.overspentFundsByCategory.length;
      if (allDebtAccountedFor) {
        isSuccess = true;
      }
    }

    await repository.recordCheckInAttempt(date: now, isSuccess: isSuccess);

    ref.invalidate(checkInStreakProvider);
    ref.invalidate(isCheckInAvailableProvider);
    ref.invalidate(appBarInfoProvider);
    ref.invalidate(weeklyCategoryDataProvider);
    ref.invalidate(weeklyAggregateProvider);

    return isSuccess;
  }

  Future<bool> undoLastCheckIn() async {
    final repository = ref.read(transactionRepositoryProvider);

    final undoState = await repository.getUndoCheckInState();
    if (undoState == null) return false;

    final date = undoState['date'] as DateTime;
    final previousStreak = undoState['previousStreak'] as int;
    final wasSuccess = undoState['wasSuccess'] as bool;

    await repository.deleteRolloverAdjustments(date);
    await repository.setCheckInStreak(previousStreak);

    if (wasSuccess) {
      final history = await repository.getSuccessfulCheckInDates();
      history.removeWhere((d) => d.isAtSameMomentAs(date));
      await repository.setCheckInHistory(history);
    }

    await repository.clearLastCheckInDate();
    final history = await repository.getSuccessfulCheckInDates();
    if (history.isNotEmpty) {
      history.sort((a, b) => b.compareTo(a));
      await repository.setLastCheckInDate(history.first);
    }

    await repository.clearUndoCheckInState();

    ref.invalidate(checkInStreakProvider);
    ref.invalidate(isCheckInAvailableProvider);
    ref.invalidate(appBarInfoProvider);
    ref.invalidate(weeklyCategoryDataProvider);
    ref.invalidate(weeklyAggregateProvider);

    return true;
  }
}
