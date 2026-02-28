import 'dart:math';
import 'package:uuid/uuid.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:budgit/src/core/data/repositories/transaction_repository.dart';
import 'package:budgit/src/core/domain/models/category.dart';
import 'package:budgit/src/core/domain/models/transaction.dart';
import 'package:budgit/src/features/budget_hub/domain/budget_transfer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/core/domain/models/savings_goal.dart';

// Helper to check if two dates are in the same wallet week
bool _isSameWalletWeek(DateTime date1, DateTime date2, int checkInDay) {
  DateTime getStart(DateTime d) {
    return DateTime(d.year, d.month, d.day - (d.weekday - checkInDay + 7) % 7);
  }

  return getStart(date1).isAtSameMomentAs(getStart(date2));
}

double _generateNormalRandom(Random random, double mean, double stdDev) {
  double u1, u2, w;
  do {
    u1 = random.nextDouble() * 2.0 - 1.0;
    u2 = random.nextDouble() * 2.0 - 1.0;
    w = u1 * u1 + u2 * u2;
  } while (w >= 1.0);

  w = sqrt((-2.0 * log(w)) / w);
  double z = u1 * w;

  final result = mean + z * stdDev;
  return result < 0 ? 0 : result;
}

class HiveTransactionRepository implements TransactionRepository {
  final Ref ref;

  // These fields are initialized immediately in the constructor
  late final Box<Transaction> _transactionBox;
  late final Box<Category> _categoryBox;
  late final Box _settingsBox;
  late final Box<BudgetTransfer> _BudgetTransferBox;
  late final Box<SavingsGoal> _savingsBox;

  HiveTransactionRepository(this.ref) {
    // FIX: Use Hive.box() (Synchronous) instead of openBox (Async)
    // relying on main.dart to have already opened them.

    _transactionBox = Hive.box<Transaction>('transactions');
    _categoryBox = Hive.box<Category>('categories');
    _settingsBox = Hive.box('settings');

    // Note: Names must match exactly what is in main.dart
    _BudgetTransferBox = Hive.box<BudgetTransfer>('adjustments');
    _savingsBox = Hive.box<SavingsGoal>('savings_goals');
  }

  // --- Transactions ---
  @override
  Future<void> addTransaction(Transaction transaction) async {
    await _transactionBox.put(transaction.id, transaction);
  }

  @override
  Future<List<Transaction>> getAllTransactions() async {
    return _transactionBox.values.toList();
  }

  @override
  Future<void> updateTransaction(Transaction transaction) async {
    await _transactionBox.put(transaction.id, transaction);
  }

  @override
  Future<void> deleteTransaction(String transactionId) async {
    await _transactionBox.delete(transactionId);
  }

  @override
  Future<Transaction?> getTransactionById(String id) async {
    return _transactionBox.get(id);
  }

  // --- Categories ---
  @override
  Future<void> addCategory(Category category) async {
    await _categoryBox.put(category.id, category);
  }

  @override
  Future<List<Category>> getAllCategories() async {
    return _categoryBox.values.toList();
  }

  @override
  Future<void> updateCategory(Category category) async {
    await _categoryBox.put(category.id, category);
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    await _categoryBox.delete(categoryId);
  }

  @override
  Future<List<String>?> getCategoryOrder() async {
    final dynamic order = _settingsBox.get('categoryOrder');
    if (order is List) {
      return order.cast<String>().toList();
    }
    return null;
  }

  @override
  Future<void> saveCategoryOrder(List<String> categoryIds) async {
    await _settingsBox.put('categoryOrder', categoryIds);
  }

  @override
  Future<Category?> getCategory(String categoryId) async {
    return _categoryBox.get(categoryId);
  }

  // --- Recurring ---
  @override
  Future<List<RecurringPayment>> getRecurringTransactionsForCategory(
    String categoryId,
  ) async {
    return _transactionBox.values
        .whereType<RecurringPayment>()
        .where((t) => t.category.id == categoryId)
        .toList();
  }

  // --- Wallet Adjustments (Boosts) ---
  @override
  Future<void> addBudgetTransfer(BudgetTransfer adjustment) async {
    await _BudgetTransferBox.put(adjustment.id, adjustment);
  }

  @override
  Future<List<BudgetTransfer>> getBudgetTransfersForWeek(
    DateTime dateInWeek,
  ) async {
    final checkInDay = _settingsBox.get('checkInDay', defaultValue: 7);
    return _BudgetTransferBox.values
        .where((a) => _isSameWalletWeek(a.date, dateInWeek, checkInDay))
        .toList();
  }

  @override
  Future<List<BudgetTransfer>> getBudgetTransfers(
    String toCategoryId,
    DateTime dateInWeek,
  ) async {
    final checkInDay = _settingsBox.get('checkInDay', defaultValue: 7);
    return _BudgetTransferBox.values.where((a) {
      if (a.toCategoryId != toCategoryId) return false;
      return _isSameWalletWeek(a.date, dateInWeek, checkInDay);
    }).toList();
  }

  @override
  Future<void> deleteBudgetTransfers(
    String toCategoryId,
    DateTime dateInWeek,
  ) async {
    final checkInDay = _settingsBox.get('checkInDay', defaultValue: 7);
    final keysToDelete = _BudgetTransferBox.values
        .where(
          (a) =>
              a.toCategoryId == toCategoryId &&
              _isSameWalletWeek(a.date, dateInWeek, checkInDay),
        )
        .map((a) => a.id)
        .toList();

    await _BudgetTransferBox.deleteAll(keysToDelete);
  }

  // --- Savings ---
  @override
  Future<void> setSavingsGoal(SavingsGoal goal) async {
    await _savingsBox.put('goal', goal);
  }

  @override
  Future<SavingsGoal?> getSavingsGoal() async {
    return _savingsBox.get('goal');
  }

  @override
  Future<void> addToSavings(double amount) async {
    final current = _settingsBox.get('totalSavings', defaultValue: 0.0);
    await _settingsBox.put('totalSavings', current + amount);
  }

  @override
  Future<double> getTotalSavings() async {
    return _settingsBox.get('totalSavings', defaultValue: 0.0);
  }

  @override
  Future<void> deleteSavingsGoal() async {
    await _savingsBox.clear();
  }

  // --- Check In / System ---
  @override
  Future<void> saveCheckInSummary({
    required double lastWeekWalletSpending,
  }) async {
    await _settingsBox.put('lastWeekWalletSpending', lastWeekWalletSpending);
  }

  @override
  Future<double> getLastWeekWalletSpending() async {
    return _settingsBox.get('lastWeekWalletSpending', defaultValue: 0.0);
  }

  @override
  Future<void> debugResetCheckInData() async {
    await _settingsBox.delete('lastCheckIn');
    await _settingsBox.delete('lastWeekWalletSpending');
    await _settingsBox.delete('totalSavings');
    await _BudgetTransferBox.clear();
  }

  @override
  Future<void> recordCheckInAttempt({
    required DateTime date,
    required bool isSuccess,
  }) async {
    // 1. Update Last Check-in Date
    await setLastCheckInDate(date);

    if (isSuccess) {
      // 2a. Increment Streak
      await incrementCheckInStreak();

      // 2b. Add to History
      // We explicitly fetch, modify, and save to ensure list integrity.
      final currentHistory = await getSuccessfulCheckInDates();

      // Prevent duplicate entries for the exact same timestamp (just in case)
      if (!currentHistory.any((d) => d.isAtSameMomentAs(date))) {
        currentHistory.add(date);
        await _settingsBox.put('checkInHistory', currentHistory);
      }
    } else {
      // 3. Reset Streak on Failure
      await resetCheckInStreak();
      // Note: We do NOT clear the history. Past successes are still valid historical data.
    }
  }

  @override
  Future<List<DateTime>> getSuccessfulCheckInDates() async {
    final dynamic data = _settingsBox.get('checkInHistory');

    if (data == null) return [];

    if (data is List) {
      // Safely cast the dynamic list from Hive to List<DateTime>
      return data.cast<DateTime>().toList();
    }

    return [];
  }

  @override
  Future<void> clearCheckInHistory() async {
    await _settingsBox.delete('checkInHistory');
  }

  @override
  Future<int> getCheckInStreak() async {
    return _settingsBox.get('streak', defaultValue: 0);
  }

  @override
  Future<void> incrementCheckInStreak() async {
    final current = _settingsBox.get('streak', defaultValue: 0) as int;
    await _settingsBox.put('streak', current + 1);
  }

  @override
  Future<void> resetCheckInStreak() async {
    await _settingsBox.put('streak', 0);
  }

  @override
  Future<void> setLastCheckInDate(DateTime date) async {
    await _settingsBox.put('lastCheckIn', date);
  }

  @override
  Future<DateTime?> getLastCheckInDate() async {
    return _settingsBox.get('lastCheckIn');
  }

  @override
  Future<void> generateDummyData() async {
    final random = Random();
    final uuid = const Uuid();
    final now = DateTime.now();

    final categories = _categoryBox.values.toList();
    if (categories.isEmpty) return;

    final generatedTransactions = <OneOffPayment>[];

    for (int i = 0; i < 12; i++) {
      for (var category in categories) {
        final numTransactions = random.nextInt(5) + 1;
        final monthlyBudget = category.budgetAmount;
        final mean = monthlyBudget / (numTransactions * 1.5);
        final stdDev = mean * 0.4;

        for (int j = 0; j < numTransactions; j++) {
          final transactionDate = DateTime(
            now.year,
            now.month - i,
            random.nextInt(27) + 1,
          );
          generatedTransactions.add(
            OneOffPayment(
              id: uuid.v4(),
              notes: 'Generated one-off spending',
              createdAt: transactionDate,
              amount: _generateNormalRandom(random, mean, stdDev),
              date: transactionDate,
              itemName: 'Monthly spend for ${category.name}',
              store: 'Generated Online Store',
              category: category,
              // isWalleted: false, <-- REMOVED: All OneOffPayments are now inherently 'Variable'
            ),
          );
        }
      }
    }

    final transactionMap = {for (var t in generatedTransactions) t.id: t};
    await _transactionBox.putAll(transactionMap);
  }

  @override
  Future<void> deleteAllData() async {
    await _transactionBox.clear();
    await _categoryBox.clear();
    await _BudgetTransferBox.clear();
  }

  @override
  Future<void> saveRecentIcons(List<String> iconNames) async {
    await _settingsBox.put('recentIcons', iconNames);
  }

  @override
  Future<List<String>> getRecentIcons() async {
    final dynamic recents = _settingsBox.get('recentIcons');
    if (recents is List) {
      return recents.cast<String>().toList();
    }
    return [];
  }

  // --- UNDO CHECK-IN METHODS ---
  @override
  Future<void> saveUndoCheckInState({
    required DateTime date,
    required double savedAmount,
    required int previousStreak,
    required bool wasSuccess,
  }) async {
    await _settingsBox.put('undo_date', date);
    await _settingsBox.put('undo_savedAmount', savedAmount);
    await _settingsBox.put('undo_previousStreak', previousStreak);
    await _settingsBox.put('undo_wasSuccess', wasSuccess);
  }

  @override
  Future<Map<String, dynamic>?> getUndoCheckInState() async {
    final date = _settingsBox.get('undo_date');
    if (date == null) return null;
    return {
      'date': date,
      'savedAmount': _settingsBox.get('undo_savedAmount', defaultValue: 0.0),
      'previousStreak': _settingsBox.get(
        'undo_previousStreak',
        defaultValue: 0,
      ),
      'wasSuccess': _settingsBox.get('undo_wasSuccess', defaultValue: false),
    };
  }

  @override
  Future<void> clearUndoCheckInState() async {
    await _settingsBox.delete('undo_date');
    await _settingsBox.delete('undo_savedAmount');
    await _settingsBox.delete('undo_previousStreak');
    await _settingsBox.delete('undo_wasSuccess');
  }

  @override
  Future<void> deleteRolloverAdjustments(DateTime date) async {
    // Only delete the automatic system rollovers from that exact check-in second
    final keysToDelete = _BudgetTransferBox.values
        .where(
          (a) =>
              a.fromCategoryId == 'rollover' && a.date.isAtSameMomentAs(date),
        )
        .map((a) => a.id)
        .toList();
    await _BudgetTransferBox.deleteAll(keysToDelete);
  }

  @override
  Future<void> setCheckInStreak(int streak) async {
    await _settingsBox.put('streak', streak);
  }

  @override
  Future<void> setCheckInHistory(List<DateTime> history) async {
    await _settingsBox.put('checkInHistory', history);
  }

  @override
  Future<void> clearLastCheckInDate() async {
    await _settingsBox.delete('lastCheckIn');
  }
}
