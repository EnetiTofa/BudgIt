import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/core/domain/models/savings_goal.dart';
import 'package:budgit/src/core/data/repositories/transaction_repository.dart';
import 'package:budgit/src/core/domain/models/category.dart';
import 'package:budgit/src/core/domain/models/transaction.dart';
import 'package:budgit/src/features/budget_hub/domain/budget_transfer.dart';

class FakeTransactionRepository implements TransactionRepository {
  final Ref ref;
  FakeTransactionRepository(this.ref);

  final List<Transaction> _transactions = [];
  final List<Category> _categories = [];
  final List<BudgetTransfer> _adjustments = [];

  List<String>? _categoryOrder;
  SavingsGoal? _savingsGoal;
  double _totalSavings = 0.0;
  double _lastWeekWalletSpending = 0.0;
  int _checkInStreak = 0;
  DateTime? _lastCheckInDate;
  List<String> _recentIcons = [];
  final List<DateTime> _checkInHistory = [];

  // --- Transaction Methods ---
  @override
  Future<void> addTransaction(Transaction transaction) async {
    _transactions.add(transaction);
  }

  @override
  Future<List<Transaction>> getAllTransactions() async {
    return List.unmodifiable(_transactions);
  }

  @override
  Future<void> updateTransaction(Transaction transaction) async {
    final index = _transactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      _transactions[index] = transaction;
    }
  }

  @override
  Future<void> deleteTransaction(String transactionId) async {
    _transactions.removeWhere((t) => t.id == transactionId);
  }

  @override
  Future<Transaction?> getTransactionById(String id) async {
    try {
      return _transactions.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  // --- Category Methods ---
  @override
  Future<void> addCategory(Category category) async {
    _categories.add(category);
  }

  @override
  Future<List<Category>> getAllCategories() async {
    return List.unmodifiable(_categories);
  }

  @override
  Future<void> updateCategory(Category category) async {
    final index = _categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      _categories[index] = category;
    }
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    _categories.removeWhere((c) => c.id == categoryId);
  }

  @override
  Future<List<String>?> getCategoryOrder() async {
    return _categoryOrder;
  }

  @override
  Future<void> saveCategoryOrder(List<String> categoryIds) async {
    _categoryOrder = categoryIds;
  }

  @override
  Future<Category?> getCategory(String categoryId) async {
    try {
      return _categories.firstWhere((c) => c.id == categoryId);
    } catch (e) {
      return null;
    }
  }

  // --- Recurring Methods ---
  @override
  Future<List<RecurringPayment>> getRecurringTransactionsForCategory(
    String categoryId,
  ) async {
    return _transactions
        .whereType<RecurringPayment>()
        .where((t) => t.category.id == categoryId)
        .toList();
  }

  // --- Wallet Adjustment Methods ---
  @override
  Future<void> addBudgetTransfer(BudgetTransfer adjustment) async {
    _adjustments.add(adjustment);
  }

  @override
  Future<List<BudgetTransfer>> getBudgetTransfersForWeek(
    DateTime dateInWeek,
  ) async {
    // For fake repo, we might just return all to simplify testing
    // or implement simple logic if needed.
    return _adjustments;
  }

  @override
  Future<List<BudgetTransfer>> getBudgetTransfers(
    String toCategoryId,
    DateTime dateInWeek,
  ) async {
    // Return adjustments for the target category.
    return _adjustments.where((a) => a.toCategoryId == toCategoryId).toList();
  }

  @override
  Future<void> deleteBudgetTransfers(
    String toCategoryId,
    DateTime dateInWeek,
  ) async {
    _adjustments.removeWhere((a) => a.toCategoryId == toCategoryId);
  }

  // --- Savings Methods ---
  @override
  Future<void> setSavingsGoal(SavingsGoal goal) async {
    _savingsGoal = goal;
  }

  @override
  Future<SavingsGoal?> getSavingsGoal() async {
    return _savingsGoal;
  }

  @override
  Future<void> addToSavings(double amount) async {
    _totalSavings += amount;
  }

  @override
  Future<double> getTotalSavings() async {
    return _totalSavings;
  }

  @override
  Future<void> deleteSavingsGoal() async {
    _savingsGoal = null;
  }

  // --- Check In Methods ---
  @override
  Future<void> saveCheckInSummary({
    required double lastWeekWalletSpending,
  }) async {
    _lastWeekWalletSpending = lastWeekWalletSpending;
  }

  @override
  Future<double> getLastWeekWalletSpending() async {
    return _lastWeekWalletSpending;
  }

  @override
  Future<void> debugResetCheckInData() async {
    _totalSavings = 0.0;
    _lastWeekWalletSpending = 0.0;
    _checkInStreak = 0;
    _adjustments.clear();
  }

  @override
  Future<void> recordCheckInAttempt({
    required DateTime date,
    required bool isSuccess,
  }) async {
    _lastCheckInDate = date;

    if (isSuccess) {
      // Add to history if it's not already there (simple check)
      if (!_checkInHistory.contains(date)) {
        _checkInHistory.add(date);
      }
    } else {}
  }

  @override
  Future<List<DateTime>> getSuccessfulCheckInDates() async {
    return Future.value(_checkInHistory);
  }

  @override
  Future<void> clearCheckInHistory() async {
    _checkInHistory.clear();
  }

  @override
  Future<int> getCheckInStreak() async {
    return _checkInStreak;
  }

  @override
  Future<void> incrementCheckInStreak() async {
    _checkInStreak++;
  }

  @override
  Future<void> resetCheckInStreak() async {
    _checkInStreak = 0;
  }

  @override
  Future<void> setLastCheckInDate(DateTime date) async {
    _lastCheckInDate = date;
  }

  @override
  Future<DateTime?> getLastCheckInDate() async {
    return _lastCheckInDate;
  }

  // --- Other Methods ---
  @override
  Future<void> generateDummyData() async {
    // No-op for fake repo
  }

  @override
  Future<void> deleteAllData() async {
    _transactions.clear();
    _categories.clear();
    _adjustments.clear();
  }

  @override
  Future<void> saveRecentIcons(List<String> iconNames) async {
    _recentIcons = iconNames;
  }

  @override
  Future<List<String>> getRecentIcons() async {
    return _recentIcons;
  }

  Map<String, dynamic>? _undoState;

  @override
  Future<void> saveUndoCheckInState({
    required DateTime date,
    required double savedAmount,
    required int previousStreak,
    required bool wasSuccess,
  }) async {
    _undoState = {
      'date': date,
      'savedAmount': savedAmount,
      'previousStreak': previousStreak,
      'wasSuccess': wasSuccess,
    };
  }

  @override
  Future<Map<String, dynamic>?> getUndoCheckInState() async {
    return _undoState;
  }

  @override
  Future<void> clearUndoCheckInState() async {
    _undoState = null;
  }

  @override
  Future<void> deleteRolloverAdjustments(DateTime date) async {
    _adjustments.removeWhere(
      (a) => a.fromCategoryId == 'rollover' && a.date.isAtSameMomentAs(date),
    );
  }

  @override
  Future<void> setCheckInStreak(int streak) async {
    _checkInStreak = streak;
  }

  @override
  Future<void> setCheckInHistory(List<DateTime> history) async {
    _checkInHistory.clear();
    _checkInHistory.addAll(history);
  }

  @override
  Future<void> clearLastCheckInDate() async {
    _lastCheckInDate = null;
  }
}
