// lib/src/features/check_in/presentation/check_in_controller.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:budgit/src/features/check_in/domain/check_in_state.dart';
import 'package:budgit/src/core/data/providers/transaction_repository_provider.dart';
import 'package:budgit/src/core/domain/models/transaction.dart';
import 'package:budgit/src/core/data/providers/category_list_provider.dart';
import 'package:budgit/src/features/budget_hub/wallet/presentation/providers/wallet_category_data_provider.dart';
import 'package:budgit/src/features/settings/data/settings_provider.dart';
import 'package:budgit/src/utils/clock_provider.dart';
import 'package:budgit/src/features/budget_hub/savings/presentation/savings_providers.dart';
import 'package:budgit/src/features/budget_hub/wallet/domain/wallet_adjustment.dart';
import 'package:budgit/src/features/check_in/presentation/providers/is_check_in_available_provider.dart';
import 'package:budgit/src/features/check_in/presentation/providers/streak_provider.dart';
import 'package:budgit/src/features/check_in/presentation/providers/app_bar_info_provider.dart';

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
    final endOfLastWeek = DateTime(now.year, now.month, now.day - daysSinceCheckIn - 1, 23, 59, 59);
    final startOfLastWeek = endOfLastWeek.subtract(const Duration(days: 6));
    final startOfLastWeekClean = DateTime(startOfLastWeek.year, startOfLastWeek.month, startOfLastWeek.day);

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
    final categories = await ref.read(categoryListProvider.future);
    final repository = ref.read(transactionRepositoryProvider);
    final allTransactions = await repository.getAllTransactions();
    
    final range = await _getWeekRange();
    final pastAdjustments = await repository.getWalletAdjustmentsForWeek(range.start);

    final Map<String, double> unspentByCategory = {};
    final Map<String, double> overspentByCategory = {};
    final Map<String, int> debtStreaks = {}; // NEW
    final List<Transaction> weekTransactions = [];

    // Filter Transactions
    for (final transaction in allTransactions) {
      if (transaction is OneOffPayment) {
        if (!transaction.date.isBefore(range.start) && transaction.date.isBefore(range.end)) {
          weekTransactions.add(transaction);
        }
      }
    }

    // Calculate Balances & Debt Streaks
    for (final category in categories.where((c) => (c.walletAmount ?? 0) > 0)) {
      
      // 1. Calculate effective wallet budget
      double netBoosts = 0;
      for (var adj in pastAdjustments) {
        if (adj.toCategoryId == category.id) netBoosts += adj.amount;
        if (adj.fromCategoryId == category.id) netBoosts -= adj.amount;
      }
      
      final effectiveWeeklyWallet = category.walletAmount! + netBoosts;
      final spending = weekTransactions
          .whereType<OneOffPayment>()
          .where((p) => p.isWalleted && p.category.id == category.id)
          .fold(0.0, (sum, p) => sum + p.amount);

      final difference = effectiveWeeklyWallet - spending;
      
      if (difference > 0) {
        unspentByCategory[category.id] = difference;
      } else if (difference < 0) {
        overspentByCategory[category.id] = difference.abs();
      }

      // 2. Calculate Debt Streak (Look back up to 4 weeks)
      int streak = 0;
      DateTime checkDate = range.start;
      while (streak < 4) {
        final adjs = await repository.getWalletAdjustmentsForWeek(checkDate);
        // A debt rollover is marked as from 'rollover' with a negative amount
        final hasDebt = adjs.any((a) => a.fromCategoryId == 'rollover' && a.toCategoryId == category.id && a.amount < 0);
        if (hasDebt) {
          streak++;
          checkDate = checkDate.subtract(const Duration(days: 7));
        } else {
          break;
        }
      }
      debtStreaks[category.id] = streak;
    }

    weekTransactions.sort((a, b) {
      final dateA = a is OneOffPayment ? a.date : DateTime.now();
      final dateB = b is OneOffPayment ? b.date : DateTime.now();
      return dateB.compareTo(dateA);
    });

    state = state.copyWith(
      status: CheckInStatus.dataReady,
      unspentFundsByCategory: unspentByCategory,
      overspentFundsByCategory: overspentByCategory,
      weekTransactions: weekTransactions,
      checkInWeekDate: range.end.subtract(const Duration(minutes: 1)),
      checkInWeekBoosts: pastAdjustments,
      debtStreaks: debtStreaks, // NEW
    );
  }

  // --- NEW: Toggle Debt Rollover ---
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
    final date = state.checkInWeekDate ?? DateTime.now().subtract(const Duration(days: 7));
    
    final targetBoosts = state.checkInWeekBoosts.where((b) => b.toCategoryId == toCategoryId).toList();
    if (existingBoostId != null) {
      targetBoosts.removeWhere((b) => b.id == existingBoostId);
    }
    if (amount > 0) {
      targetBoosts.add(WalletAdjustment(
        id: existingBoostId ?? 'historical_boost_${DateTime.now().millisecondsSinceEpoch}',
        fromCategoryId: fromCategoryId,
        toCategoryId: toCategoryId,
        amount: amount,
        date: date, 
      ));
    }

    await repository.deleteWalletAdjustments(toCategoryId, date);
    for (final adj in targetBoosts) {
      await repository.addWalletAdjustment(adj);
    }
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

    // 1. Process Positive Savings/Rollovers
// 1. Process Positive Savings/Rollovers (Default to Save)
    double totalToSave = 0;
    
    for (var entry in state.unspentFundsByCategory.entries) {
      final categoryId = entry.key;
      final unspent = entry.value;
      // Get the manually selected rollover amount (defaults to 0)
      final rolloverAmount = state.rolloverAmounts[categoryId] ?? 0.0;
      
      // The rest is automatically saved
      final amountToSave = unspent - rolloverAmount;
      if (amountToSave > 0) {
        totalToSave += amountToSave;
      }

      // If they used the slider to roll anything over, add that adjustment
      if (rolloverAmount > 0) {
        final rollover = WalletAdjustment(
          id: 'rollover_${categoryId}_${now.toIso8601String()}',
          fromCategoryId: 'rollover',
          toCategoryId: categoryId,
          amount: rolloverAmount,
          date: now,
        );
        await repository.addWalletAdjustment(rollover);
      }
    }

    if (totalToSave > 0) {
      await repository.addToSavings(totalToSave);
    }

    // 2. Process NEGATIVE Debt Rollovers (All of it for a particular category)
    for (final categoryId in state.rollingOverDebtCategoryIds) {
      final debtAmount = state.overspentFundsByCategory[categoryId] ?? 0.0;
      final currentStreak = state.debtStreaks[categoryId] ?? 0;
      
      // Safety check: only rollover if under the 4-week limit
      if (debtAmount > 0 && currentStreak < 4) {
        final debtAdjustment = WalletAdjustment(
          id: 'rollover_debt_${categoryId}_${now.toIso8601String()}',
          fromCategoryId: 'rollover',
          toCategoryId: categoryId,
          amount: -debtAmount, // Negative amount reduces next week's budget!
          date: now,
        );
        await repository.addWalletAdjustment(debtAdjustment);
      }
    }

    // 3. Calculate Success
    final categories = await ref.read(categoryListProvider.future);
    double totalWalletBudget = 0;
    double totalWalletSpent = 0;

    for (final category in categories) {
      if ((category.walletAmount ?? 0) > 0) {
        totalWalletBudget += category.walletAmount!;
        final spentInCategory = state.weekTransactions
            .whereType<OneOffPayment>()
            .where((p) => p.isWalleted && p.category.id == category.id)
            .fold(0.0, (sum, p) => sum + p.amount);
            
        totalWalletSpent += spentInCategory;
      }
    }

    // Standard Success: Stayed under overall budget
    bool isSuccess = totalWalletSpent <= totalWalletBudget;

    // --- NEW: Debt Acceptance Success Override ---
    // If they overspent, but chose to roll over ALL their overspent categories, 
    // they are taking responsibility. Keep the streak alive!
    if (!isSuccess && state.overspentFundsByCategory.isNotEmpty) {
      final allDebtAccountedFor = state.rollingOverDebtCategoryIds.length == state.overspentFundsByCategory.length;
      if (allDebtAccountedFor) {
        isSuccess = true;
      }
    }

    await repository.recordCheckInAttempt(
      date: now,
      isSuccess: isSuccess,
    );

    ref.invalidate(checkInStreakProvider);
    ref.invalidate(isCheckInAvailableProvider);
    ref.invalidate(appBarInfoProvider);
    ref.invalidate(totalSavingsProvider);
    ref.invalidate(walletCategoryDataProvider);

    return isSuccess;
  }

  // --- NEW: Surgical Undo Logic ---
  Future<bool> undoLastCheckIn() async {
    final repository = ref.read(transactionRepositoryProvider);
    
    // 1. Get the snapshot
    final undoState = await repository.getUndoCheckInState();
    if (undoState == null) return false; // Nothing to undo

    final date = undoState['date'] as DateTime;
    final savedAmount = undoState['savedAmount'] as double;
    final previousStreak = undoState['previousStreak'] as int;
    final wasSuccess = undoState['wasSuccess'] as bool;

    // 2. Reverse Savings
    if (savedAmount > 0) {
      // Add a negative amount to subtract from total savings
      await repository.addToSavings(-savedAmount); 
    }

    // 3. Reverse Rollovers & Debt
    // Deletes ONLY the rollovers created at that exact millisecond
    await repository.deleteRolloverAdjustments(date);

    // 4. Reverse Streak
    await repository.setCheckInStreak(previousStreak);

    // 5. Reverse Check-In History
    if (wasSuccess) {
      final history = await repository.getSuccessfulCheckInDates();
      history.removeWhere((d) => d.isAtSameMomentAs(date));
      await repository.setCheckInHistory(history);
    }

    // 6. Reset Last Check-In Date 
    // We need to look at the history to find the previous date, 
    // or just clear it so the app knows they haven't checked in this week.
    await repository.clearLastCheckInDate();
    final history = await repository.getSuccessfulCheckInDates();
    if (history.isNotEmpty) {
      // Sort to find the most recent past check-in
      history.sort((a, b) => b.compareTo(a)); 
      await repository.setLastCheckInDate(history.first);
    }

    // 7. Clear the snapshot so they can't spam the undo button
    await repository.clearUndoCheckInState();

    // 8. Refresh the app
    ref.invalidate(checkInStreakProvider);
    ref.invalidate(isCheckInAvailableProvider);
    ref.invalidate(appBarInfoProvider);
    ref.invalidate(totalSavingsProvider);
    ref.invalidate(walletCategoryDataProvider);

    return true;
  }
}