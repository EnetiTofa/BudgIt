import 'dart:math';
import 'package:uuid/uuid.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:budgit/src/core/data/repositories/transaction_repository.dart';
import 'package:budgit/src/core/domain/models/category.dart';
import 'package:budgit/src/core/domain/models/transaction.dart';
import 'package:budgit/src/features/budget_hub/wallet/domain/wallet_adjustment.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/core/domain/models/savings_goal.dart';

// Helper to check if two dates are in the same wallet week
bool _isSameWalletWeek(DateTime date1, DateTime date2, int checkInDay) {
  DateTime getStart(DateTime d) {
    return DateTime(
      d.year, d.month, d.day - (d.weekday - checkInDay + 7) % 7
    );
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
  late final Box<WalletAdjustment> _walletAdjustmentBox;
  late final Box<SavingsGoal> _savingsBox;

  HiveTransactionRepository(this.ref) {
    // FIX: Use Hive.box() (Synchronous) instead of openBox (Async)
    // relying on main.dart to have already opened them.
    
    _transactionBox = Hive.box<Transaction>('transactions');
    _categoryBox = Hive.box<Category>('categories');
    _settingsBox = Hive.box('settings');
    
    // Note: Names must match exactly what is in main.dart
    _walletAdjustmentBox = Hive.box<WalletAdjustment>('adjustments'); 
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
  Future<List<RecurringPayment>> getRecurringTransactionsForCategory(String categoryId) async {
    return _transactionBox.values
        .whereType<RecurringPayment>()
        .where((t) => t.category.id == categoryId)
        .toList();
  }

  // --- Wallet Adjustments (Boosts) ---
  @override
  Future<void> addWalletAdjustment(WalletAdjustment adjustment) async {
    await _walletAdjustmentBox.put(adjustment.id, adjustment);
  }

  @override
  Future<List<WalletAdjustment>> getWalletAdjustmentsForWeek(DateTime dateInWeek) async {
    final checkInDay = _settingsBox.get('checkInDay', defaultValue: 7);
    return _walletAdjustmentBox.values
        .where((a) => _isSameWalletWeek(a.date, dateInWeek, checkInDay))
        .toList();
  }

  @override
  Future<List<WalletAdjustment>> getWalletAdjustments(String toCategoryId, DateTime dateInWeek) async {
    final checkInDay = _settingsBox.get('checkInDay', defaultValue: 7);
    return _walletAdjustmentBox.values.where((a) {
      if (a.toCategoryId != toCategoryId) return false;
      return _isSameWalletWeek(a.date, dateInWeek, checkInDay);
    }).toList();
  }

  @override
  Future<void> deleteWalletAdjustments(String toCategoryId, DateTime dateInWeek) async {
    final checkInDay = _settingsBox.get('checkInDay', defaultValue: 7);
    final keysToDelete = _walletAdjustmentBox.values
        .where((a) => a.toCategoryId == toCategoryId && _isSameWalletWeek(a.date, dateInWeek, checkInDay))
        .map((a) => a.id)
        .toList();

    await _walletAdjustmentBox.deleteAll(keysToDelete);
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
  Future<void> saveCheckInSummary({required double lastWeekWalletSpending}) async {
    await _settingsBox.put('lastWeekWalletSpending', lastWeekWalletSpending);
  }

  @override
  Future<double> getLastWeekWalletSpending() async {
    return _settingsBox.get('lastWeekWalletSpending', defaultValue: 0.0);
  }

  @override
  Future<void> debugResetCheckInData() async {
    await _settingsBox.delete('lastWeekWalletSpending');
    await _settingsBox.delete('totalSavings');
    await _walletAdjustmentBox.clear();
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
                final transactionDate = DateTime(now.year, now.month - i, random.nextInt(27) + 1);
                generatedTransactions.add(OneOffPayment(
                    id: uuid.v4(),
                    notes: 'Generated one-off spending',
                    createdAt: transactionDate,
                    amount: _generateNormalRandom(random, mean, stdDev),
                    date: transactionDate,
                    itemName: 'Monthly spend for ${category.name}',
                    store: 'Generated Online Store',
                    category: category,
                    isWalleted: false,
                ));
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
    await _walletAdjustmentBox.clear();
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
}