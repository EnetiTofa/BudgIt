import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:budgit/src/features/check_in/domain/check_in_state.dart';
import 'package:budgit/src/core/data/providers/transaction_repository_provider.dart';
import 'package:budgit/src/core/domain/models/transaction.dart';
import 'package:budgit/src/features/settings/data/settings_provider.dart';
import 'package:budgit/src/utils/clock_provider.dart';
import 'package:budgit/src/features/budget_hub/domain/budget_transfer.dart';
import 'package:budgit/src/features/check_in/presentation/providers/is_check_in_available_provider.dart';
import 'package:budgit/src/features/check_in/presentation/providers/streak_provider.dart';
import 'package:budgit/src/features/check_in/presentation/providers/app_bar_info_provider.dart';
import 'package:budgit/src/core/data/providers/category_list_provider.dart';
import 'package:budgit/src/features/transaction_hub/transactions/presentation/providers/transaction_log_provider.dart';
import 'package:budgit/src/features/transaction_hub/transactions/presentation/providers/recurring_transactions_provider.dart';
import 'package:budgit/src/features/transaction_hub/transactions/presentation/providers/next_recurring_payment_provider.dart';
import 'package:budgit/src/features/budget_hub/presentation/providers/weekly_projection_providers.dart';
import 'package:budgit/src/features/budget_hub/presentation/providers/monthly_projection_providers.dart';
import 'package:budgit/src/features/budget_hub/presentation/providers/overall_budget_summary_provider.dart';
import 'package:budgit/src/features/dashboard/presentation/providers/streak_calendar_state_provider.dart';
import 'package:budgit/src/core/data/providers/settings_repository_provider.dart';

part 'check_in_controller.g.dart';

// KEEP ALIVE TRUE: Prevents the controller from auto-disposing while navigating between Check-In pages
@Riverpod(keepAlive: true)
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

    // DST SAFE MATH
    final endOfLastWeek = DateTime(
      now.year,
      now.month,
      now.day - daysSinceCheckIn - 1,
      23,
      59,
      59,
    );
    final startOfLastWeekClean = DateTime(
      endOfLastWeek.year,
      endOfLastWeek.month,
      endOfLastWeek.day - 6,
    );

    return (start: startOfLastWeekClean, end: endOfLastWeek);
  }

  Future<void> startCheckIn({CheckInType type = CheckInType.weekly}) async {
    state = state.copyWith(status: CheckInStatus.loading, type: type);
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

    final Map<String, double> unspentByCategory = {};
    final Map<String, double> overspentByCategory = {};
    final List<Transaction> weekTransactions = [];

    // 1. Gather the week's transactions
    for (final transaction in allTransactions) {
      if (transaction is OneOffPayment &&
          transaction.parentRecurringId == null) {
        if (!transaction.date.isBefore(range.start) &&
            transaction.date.isBefore(range.end)) {
          weekTransactions.add(transaction);
        }
      }
    }

    weekTransactions.sort((a, b) {
      final dateA = a is OneOffPayment ? a.date : DateTime.now();
      final dateB = b is OneOffPayment ? b.date : DateTime.now();
      return dateB.compareTo(dateA);
    });

    // ==========================================
    // THE MATH FORK: WEEKLY vs. MONTHLY
    // ==========================================
    if (state.type == CheckInType.monthly) {
      // --- PURE MONTHLY MATH ---
      final targetMonth = range.end;
      final startOfMonth = DateTime(targetMonth.year, targetMonth.month, 1);

      final categories = ref.read(categoryListProvider).valueOrNull ?? [];

      for (final cat in categories) {
        if (cat.budgetAmount <= 0) continue;

        // Sum up EVERY transaction for the entire month
        double spentThisMonth = 0;
        for (final tx in allTransactions) {
          if (tx is OneOffPayment &&
              tx.category.id == cat.id &&
              !tx.date.isBefore(startOfMonth) &&
              tx.date.isBefore(range.end)) {
            spentThisMonth += tx.amount;
          }
        }

        final difference = cat.budgetAmount - spentThisMonth;

        if (difference > 0) {
          unspentByCategory[cat.id] = difference;
        } else if (difference < 0) {
          overspentByCategory[cat.id] = difference.abs();
        }
      }
    } else {
      // --- WEEKLY MATH ---
      final pastWeekData = await ref.read(
        weeklyCategoryDataProvider(selectedDate: range.start).future,
      );

      for (final data in pastWeekData) {
        final difference = data.amountRemainingThisWeek;

        if (difference > 0) {
          unspentByCategory[data.category.id] = difference;
        } else if (difference < 0) {
          overspentByCategory[data.category.id] = difference.abs();
        }
      }
    }

    // Load persistent debt streaks from Hive
    final box = Hive.box('settings');
    final Map<dynamic, dynamic> rawStreaks = box.get(
      'debt_streaks',
      defaultValue: {},
    );
    final Map<String, int> persistedDebtStreaks = rawStreaks.map(
      (k, v) => MapEntry(k.toString(), v as int),
    );

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
      checkInWeekTransfers: pastAdjustments,
      debtStreaks: persistedDebtStreaks,
      rolloverAmounts: validatedRollovers,
    );
  }

  void toggleDebtRollover(String categoryId) {
    // Check if debt has hit the 4-week maximum
    final currentDebtWeek = state.debtStreaks[categoryId] ?? 0;
    if (currentDebtWeek >= 4) {
      print(
        "DEBT EXPIRED: $categoryId has been in debt for 4 weeks. Must be resolved.",
      );
      // They are blocked from toggling this debt to roll over
      return;
    }

    final newSet = Set<String>.from(state.rollingOverDebtCategoryIds);
    if (newSet.contains(categoryId)) {
      newSet.remove(categoryId);
    } else {
      newSet.add(categoryId);
    }
    state = state.copyWith(rollingOverDebtCategoryIds: newSet);
  }

  void toggleProposal(String categoryId, double proposedNewBudget) {
    final newTweaks = Map<String, double>.from(state.proposedCategoryTweaks);

    if (newTweaks.containsKey(categoryId)) {
      newTweaks.remove(categoryId); // Un-accept
    } else {
      newTweaks[categoryId] = proposedNewBudget; // Accept
    }

    state = state.copyWith(proposedCategoryTweaks: newTweaks);
  }

  void setCustomProposal(String categoryId, double customBudget) {
    final newTweaks = Map<String, double>.from(state.proposedCategoryTweaks);
    newTweaks[categoryId] =
        customBudget; // Force accept with the user's custom value
    state = state.copyWith(proposedCategoryTweaks: newTweaks);
  }

  Future<void> applyCheckInTransfer({
    String? existingTransferId,
    required String fromCategoryId,
    required String toCategoryId,
    required double amount,
  }) async {
    final repository = ref.read(transactionRepositoryProvider);
    final range = await _getWeekRange();
    final date =
        state.checkInWeekDate ??
        DateTime.now().subtract(const Duration(days: 7));

    final targetTransfers = state.checkInWeekTransfers
        .where((b) => b.toCategoryId == toCategoryId)
        .toList();
    if (existingTransferId != null) {
      targetTransfers.removeWhere((b) => b.id == existingTransferId);
    }
    if (amount > 0) {
      targetTransfers.add(
        BudgetTransfer(
          id:
              existingTransferId ??
              'historical_transfer_${DateTime.now().millisecondsSinceEpoch}',
          fromCategoryId: fromCategoryId,
          toCategoryId: toCategoryId,
          amount: amount,
          date: date,
        ),
      );
    }

    await repository.deleteBudgetTransfers(toCategoryId, date);
    for (final adj in targetTransfers) {
      await repository.addBudgetTransfer(adj);
    }

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

  void updateHistoricalHandling({
    HistoricalHandling? weekHandling,
    HistoricalHandling? monthHandling,
  }) {
    state = state.copyWith(
      firstTimeWeekHandling: weekHandling,
      firstTimeMonthHandling: monthHandling,
    );
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

  Future<bool> completeCheckIn({CheckInType? explicitType}) async {
    try {
      final repository = ref.read(transactionRepositoryProvider);
      final settingsRepo = ref.read(settingsProvider.notifier);
      final clock = ref.read(clockNotifierProvider);
      final now = clock.now();
      final range = await _getWeekRange();

      final activeType = explicitType ?? state.type;

      // ==========================================
      // FIRST TIME FLOW
      // ==========================================
      if (activeType == CheckInType.firstTime) {
        if (state.firstTimeMonthHandling == HistoricalHandling.prorate) {
          final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
          int daysPassedInMonth = now.day - 1;
          int dayCountToDeduct = daysPassedInMonth;

          if (state.firstTimeWeekHandling == HistoricalHandling.logManually) {
            final int checkInDay = await settingsRepo.getCheckInDay();
            final int daysSinceCheckIn = (now.weekday - checkInDay + 7) % 7;

            dayCountToDeduct = daysPassedInMonth - daysSinceCheckIn;
            if (dayCountToDeduct < 0) dayCountToDeduct = 0;
          }

          if (dayCountToDeduct > 0) {
            final double prorateFraction = dayCountToDeduct / daysInMonth;
            final firstOfMonth = DateTime(now.year, now.month, 1, 12, 0);
            final categories = ref.read(categoryListProvider).valueOrNull ?? [];

            for (final category in categories) {
              final recurringTxs = await repository
                  .getRecurringTransactionsForCategory(category.id);
              double recurringSum = 0.0;

              for (final p in recurringTxs) {
                switch (p.recurrence) {
                  case RecurrencePeriod.daily:
                    recurringSum += p.amount * 30.44;
                    break;
                  case RecurrencePeriod.weekly:
                    recurringSum += p.amount * 4.33;
                    break;
                  case RecurrencePeriod.monthly:
                    recurringSum += p.amount;
                    break;
                  case RecurrencePeriod.yearly:
                    recurringSum += p.amount / 12;
                    break;
                }
              }

              final double variableBudget =
                  category.budgetAmount - recurringSum;

              if (variableBudget > 0) {
                final deductionAmount = variableBudget * prorateFraction;
                if (deductionAmount > 0) {
                  final adjustmentTx = OneOffPayment(
                    id: 'prorate_${category.id}_${now.millisecondsSinceEpoch}',
                    createdAt: now,
                    notes: 'Auto-prorate system adjustment',
                    amount: deductionAmount,
                    date: firstOfMonth,
                    itemName: 'Starting Prorate Adjustment',
                    store: 'System',
                    category: category,
                  );
                  await repository.addTransaction(adjustmentTx);
                }
              }
            }
          }
        }

        await settingsRepo.setHasCompletedFirstCheckIn(true);
        // Set dates silently without artificially bumping the streak
        await repository.setLastCheckInDate(now);
        await settingsRepo.setLastMonthlyCheckInDate(now);

        _invalidateAllProviders();
        return true;
      }

      // ==========================================
      // MONTHLY EVALUATION (THE BIG RESET)
      // ==========================================
      if (activeType == CheckInType.monthly) {
        await settingsRepo.setLastMonthlyCheckInDate(now);

        // 1. Apply Smart Proposals (Permanent Budget Tweaks)
        final categories = ref.read(categoryListProvider).valueOrNull ?? [];
        for (var entry in state.proposedCategoryTweaks.entries) {
          final cat = categories.firstWhere((c) => c.id == entry.key);
          final updatedCat = cat.copyWith(budgetAmount: entry.value);
          await repository.updateCategory(updatedCat);
        }

        // 2. Calculate Net Monthly Savings & Sweep
        double totalUnspent = state.unspentFundsByCategory.values.fold(
          0.0,
          (sum, val) => sum + val,
        );
        double totalOverspent = state.overspentFundsByCategory.values.fold(
          0.0,
          (sum, val) => sum + val,
        );
        double netSavings = totalUnspent - totalOverspent;

        if (netSavings > 0) {
          await repository.addToSavings(netSavings);
        }

        bool isSuccess = totalOverspent <= totalUnspent;
        await repository.recordCheckInAttempt(date: now, isSuccess: isSuccess);

        _invalidateAllProviders();
        return isSuccess;
      }

      // ==========================================
      // NORMAL WEEKLY MAINTENANCE
      // ==========================================
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

      // Roll over debt ONLY for weekly, if they toggled it
      final newDebtStreaks = Map<String, int>.from(state.debtStreaks);

      for (final categoryId in state.rollingOverDebtCategoryIds) {
        final debtAmount = state.overspentFundsByCategory[categoryId] ?? 0.0;
        if (debtAmount > 0) {
          final debtAdjustment = BudgetTransfer(
            id: 'rollover_debt_${categoryId}_${now.toIso8601String()}',
            fromCategoryId: 'rollover',
            toCategoryId: categoryId,
            amount: -debtAmount,
            date: now,
          );
          await repository.addBudgetTransfer(debtAdjustment);

          // Increment the week counter for this specific debt!
          newDebtStreaks[categoryId] = (newDebtStreaks[categoryId] ?? 0) + 1;
        }
      }

      // If a category is no longer in debt (or wasn't rolled over), reset its streak to 0
      for (final categoryId in state.overspentFundsByCategory.keys) {
        if (!state.rollingOverDebtCategoryIds.contains(categoryId)) {
          newDebtStreaks.remove(categoryId);
        }
      }

      // Persist the updated debt streaks to Hive
      await Hive.box('settings').put('debt_streaks', newDebtStreaks);

      final pastWeekData = await ref.read(
        weeklyCategoryDataProvider(selectedDate: range.start).future,
      );
      double totalVariableBudget = pastWeekData.fold(
        0.0,
        (sum, data) => sum + data.effectiveWeeklyBudget,
      );
      double totalVariableSpent = pastWeekData.fold(
        0.0,
        (sum, data) => sum + data.totalSpentThisWeek,
      );

      bool isSuccess = totalVariableSpent <= totalVariableBudget;
      if (!isSuccess && state.overspentFundsByCategory.isNotEmpty) {
        final allDebtAccountedFor =
            state.rollingOverDebtCategoryIds.length ==
            state.overspentFundsByCategory.length;
        if (allDebtAccountedFor) isSuccess = true;
      }

      await repository.recordCheckInAttempt(date: now, isSuccess: isSuccess);
      _invalidateAllProviders();
      return isSuccess;
    } catch (e, stacktrace) {
      print("CRITICAL ERROR IN COMPLETE CHECK IN: $e");
      print("$stacktrace");
      return false;
    }
  }

  void _invalidateAllProviders() {
    ref.invalidate(settingsProvider);
    ref.invalidate(settingsRepositoryProvider);
    ref.invalidate(rawTransactionsProvider);
    ref.invalidate(transactionLogProvider);
    ref.invalidate(allTransactionOccurrencesProvider);
    ref.invalidate(recurringTransactionsProvider);
    ref.invalidate(nextRecurringPaymentProvider);
    ref.invalidate(categoryListProvider);
    ref.invalidate(weeklyCategoryDataProvider);
    ref.invalidate(weeklyAggregateProvider);
    ref.invalidate(weeklyChartDataProvider);
    ref.invalidate(monthlyCategoryProgressProvider);
    ref.invalidate(globalMonthlyHistoryProvider);
    ref.invalidate(monthlySummaryDetailsProvider);
    ref.invalidate(historicalCategorySpendingProvider);
    ref.invalidate(categoryGaugeDataProvider);
    ref.invalidate(monthlyScreenDataProvider);
    ref.invalidate(overallBudgetSummaryProvider);
    ref.invalidate(isCheckInAvailableProvider);
    ref.invalidate(appBarInfoProvider);
    ref.invalidate(checkInStreakProvider);
    ref.invalidate(streakCalendarStateProvider);
  }

  Future<bool> undoLastCheckIn() async {
    final repository = ref.read(transactionRepositoryProvider);
    final settingsRepo = ref.read(settingsProvider.notifier);

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

    final lastMonthly = await settingsRepo.getLastMonthlyCheckInDate();
    if (lastMonthly != null &&
        lastMonthly.year == date.year &&
        lastMonthly.month == date.month &&
        lastMonthly.day == date.day) {
      await settingsRepo.setLastMonthlyCheckInDate(
        DateTime.fromMillisecondsSinceEpoch(0),
      );
    }

    final history = await repository.getSuccessfulCheckInDates();
    if (history.isNotEmpty) {
      history.sort((a, b) => b.compareTo(a));
      await repository.setLastCheckInDate(history.first);
    }

    await repository.clearUndoCheckInState();
    _invalidateAllProviders();

    return true;
  }
}
