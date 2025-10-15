import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/features/savings/domain/savings_goal.dart';
import 'package:budgit/src/features/transactions/data/transaction_repository.dart';
import 'package:budgit/src/features/categories/domain/category.dart';
import 'package:budgit/src/features/transactions/domain/transaction.dart';
import 'package:budgit/src/features/wallet/domain/wallet_adjustment.dart';

class FakeTransactionRepository implements TransactionRepository {
  final Ref ref;
  FakeTransactionRepository(this.ref);

  final List<Transaction> _transactions = [];
  final List<Category> _categories = [];
  final List<WalletAdjustment> _adjustments = [];
  List<String>? _categoryOrder;
  SavingsGoal? _savingsGoal;
  double _totalSavings = 0.0;
  double _lastWeekWalletSpending = 0.0;
  int _checkInStreak = 0;

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
  Future<Transaction?> getTransactionById(String id) async {
    try {
      return _transactions.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> updateTransaction(Transaction transaction) async {
    final index = _transactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) _transactions[index] = transaction;
  }

  @override
  Future<void> deleteTransaction(String transactionId) async {
    _transactions.removeWhere((t) => t.id == transactionId);
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

  // --- NEW METHOD ---
  @override
  Future<Category?> getCategory(String categoryId) async {
    try {
      return _categories.firstWhere((c) => c.id == categoryId);
    } catch (e) {
      return null;
    }
  }

  // --- NEW METHOD ---
  @override
  Future<List<RecurringPayment>> getRecurringTransactionsForCategory(
      String categoryId) async {
    return _transactions
        .whereType<RecurringPayment>()
        .where((p) => p.category.id == categoryId)
        .toList();
  }


  @override
  Future<void> updateCategory(Category category) async {
    final index = _categories.indexWhere((c) => c.id == category.id);
    if (index != -1) _categories[index] = category;
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    _transactions.removeWhere((t) {
      if (t is OneOffPayment) return t.category.id == categoryId;
      if (t is RecurringPayment) return t.category.id == categoryId;
      return false;
    });
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

  // --- Wallet Methods ---
  @override
  Future<void> addWalletAdjustment(WalletAdjustment adjustment) async {
    _adjustments.add(adjustment);
  }

  @override
  Future<void> deleteWalletAdjustments(String toCategoryId, DateTime dateInWeek) async {
    _adjustments.removeWhere((adj) => adj.toCategoryId == toCategoryId);
  }

  @override
  Future<List<WalletAdjustment>> getWalletAdjustmentsForWeek(DateTime dateInWeek) async {
    return _adjustments;
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

  // --- Check-in & Snapshot Methods ---
  @override
  Future<double> getLastWeekWalletSpending() async {
    return _lastWeekWalletSpending;
  }

  @override
  Future<void> saveCheckInSummary({required double lastWeekWalletSpending}) async {
    _lastWeekWalletSpending = lastWeekWalletSpending;
  }

  @override
  Future<DateTime?> getLastCheckInDate() async {
    return null; // Can be enhanced for testing if needed
  }

  @override
  Future<void> setLastCheckInDate(DateTime date) async {}

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

  // --- Debug Methods ---
  @override
  Future<void> debugResetCheckInData() async {
    _totalSavings = 0.0;
    _lastWeekWalletSpending = 0.0;
    _adjustments.clear();
  }

  @override
  Future<void> deleteAllData() async {
  }

  @override
  Future<void> generateDummyData() async {
  }

}