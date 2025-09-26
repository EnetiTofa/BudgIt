import 'package:hive_flutter/hive_flutter.dart';
import 'package:budgit/src/features/transactions/data/transaction_repository.dart';
import 'package:budgit/src/features/categories/domain/category.dart';
import 'package:budgit/src/features/transactions/domain/transaction.dart';
import 'package:budgit/src/features/wallet/domain/wallet_adjustment.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/features/settings/presentation/settings_provider.dart';
import 'package:budgit/src/features/savings/domain/savings_goal.dart';
import 'package:budgit/src/utils/clock_provider.dart';

// You'll need to make the repository accept the Riverpod reader
class HiveTransactionRepository implements TransactionRepository {
  final Ref ref;
  HiveTransactionRepository(this.ref);
  final Box<Category> _categoryBox = Hive.box<Category>('categories');
  final Box<Transaction> _transactionBox = Hive.box<Transaction>('transactions');
  final Box<WalletAdjustment> _adjustmentBox = Hive.box<WalletAdjustment>('adjustments');

  @override
  Future<void> addWalletAdjustment(WalletAdjustment adjustment) async {
    await _adjustmentBox.put(adjustment.id, adjustment);
  }

  @override
  Future<List<WalletAdjustment>> getWalletAdjustmentsForWeek(DateTime dateInWeek) async {
    // Get the user's check-in day from settings
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final checkInDay = await settingsNotifier.getCheckInDay();

    
    // Calculate the start of the current wallet week
    final startOfWeek = DateTime(
      dateInWeek.year,
      dateInWeek.month,
      dateInWeek.day - (dateInWeek.weekday - checkInDay + 7) % 7
    );

    // Return only the adjustments for this week
    return _adjustmentBox.values
        .where((adj) => !adj.date.isBefore(startOfWeek))
        .toList();
  }

  @override
  Future<void> deleteWalletAdjustments(String toCategoryId, DateTime dateInWeek) async {
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final checkInDay = await settingsNotifier.getCheckInDay();
    final startOfWeek = DateTime(
      dateInWeek.year,
      dateInWeek.month,
      dateInWeek.day - (dateInWeek.weekday - checkInDay + 7) % 7
    );

    final List<dynamic> keysToDelete = [];
    for (var key in _adjustmentBox.keys) {
      final adj = _adjustmentBox.get(key) as WalletAdjustment;
      if (adj.toCategoryId == toCategoryId && !adj.date.isBefore(startOfWeek)) {
        keysToDelete.add(key);
      }
    }
    
    if (keysToDelete.isNotEmpty) {
      await _adjustmentBox.deleteAll(keysToDelete);
    }
  }

  @override
  Future<void> addCategory(Category category) async {
    // Hive boxes use a key-value system. We'll use the category's ID as the key.
    await _categoryBox.put(category.id, category);
  }

  @override
  Future<List<Category>> getAllCategories() async {
    return _categoryBox.values.toList();
  }

  @override
  Future<void> updateCategory(Category category) async {
    // Hive's "put" method handles both creating and updating.
    await _categoryBox.put(category.id, category);
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    // 1. Find all transactions associated with this category
    final allTransactions = _transactionBox.values.toList();
    final transactionsToDelete = allTransactions.where((t) {
      if (t is OneOffPayment) return t.category.id == categoryId;
      if (t is RecurringPayment) return t.category.id == categoryId;
      return false;
    }).toList();

    // 2. Delete the associated transactions
    for (final transaction in transactionsToDelete) {
      await _transactionBox.delete(transaction.id);
    }

    // 3. Delete the category itself
    await _categoryBox.delete(categoryId);
  }

  @override
  Future<void> addTransaction(Transaction transaction) async {
    // For transactions, we can also use their ID as the key.
    await _transactionBox.put(transaction.id, transaction);
  }

  @override
  Future<List<Transaction>> getAllTransactions() async {
    return _transactionBox.values.toList();
  }
    
  @override
  Future<void> updateTransaction(Transaction transaction) async {
    // Hive's "put" with an existing key will update the entry.
    await _transactionBox.put(transaction.id, transaction);
  }
  
  @override
  Future<void> deleteTransaction(String transactionId) async {
    await _transactionBox.delete(transactionId);
  }

  final Box<SavingsGoal> _savingsGoalBox = Hive.box<SavingsGoal>('savings_goals');

  @override
  Future<Transaction?> getTransactionById(String id) async {
    return _transactionBox.get(id);
  }

  @override
  Future<void> setSavingsGoal(SavingsGoal goal) async {
    await _savingsGoalBox.put('activeGoal', goal);
  }

  @override
  Future<SavingsGoal?> getSavingsGoal() async {
    return _savingsGoalBox.get('activeGoal');
  }

  final Box _settingsBox = Hive.box('settings');

  @override
  Future<double> getTotalSavings() async {
    return _settingsBox.get('totalSavings', defaultValue: 0.0) as double;
  }

  @override
  Future<void> addToSavings(double amount) async {
    final currentSavings = await getTotalSavings();
    await _settingsBox.put('totalSavings', currentSavings + amount);
  }

  
  @override
  Future<double> getLastWeekWalletSpending() async {
    // Get the necessary data
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final checkInDay = await settingsNotifier.getCheckInDay();
    final now = ref.read(clockProvider).now();
    
    // Calculate the start and end dates of the most recently completed wallet week
    final daysSinceCheckIn = (now.weekday - checkInDay + 7) % 7;
    final endOfLastWeek = DateTime(now.year, now.month, now.day - daysSinceCheckIn - 1);
    final startOfLastWeek = endOfLastWeek.subtract(const Duration(days: 6));

    // Filter transactions and sum the amounts
    final lastWeekWalletSpending = _transactionBox.values
        .whereType<OneOffPayment>()
        .where((p) => 
            p.isWalleted && 
            !p.date.isBefore(startOfLastWeek) && 
            p.date.isBefore(endOfLastWeek.add(const Duration(days: 1))))
        .fold(0.0, (sum, p) => sum + p.amount);
        
    return lastWeekWalletSpending;
  }

  @override
  Future<void> saveCheckInSummary({required double lastWeekWalletSpending}) async {
    // We'll save this to our simple settings box
    await _settingsBox.put('lastWeekWalletSpending', lastWeekWalletSpending);
  }

  @override
  Future<void> debugResetCheckInData() async {
    // Reset our snapshot values in the settings box
    await _settingsBox.put('totalSavings', 0.0);
    await _settingsBox.put('lastWeekWalletSpending', 0.0);
    // Clear all wallet adjustments
    await _adjustmentBox.clear();
    await _settingsBox.delete('lastCheckInDate');
  }

  @override
  Future<int> getCheckInStreak() async {
    return _settingsBox.get('checkInStreak', defaultValue: 0) as int;
  }

  @override
  Future<void> incrementCheckInStreak() async {
    final currentStreak = await getCheckInStreak();
    await _settingsBox.put('checkInStreak', currentStreak + 1);
  }

  @override
  Future<void> resetCheckInStreak() async {
    await _settingsBox.put('checkInStreak', 0);
  }

  @override
  Future<void> setLastCheckInDate(DateTime date) async {
    await _settingsBox.put('lastCheckInDate', date);
  }

  @override
  Future<DateTime?> getLastCheckInDate() async {
    return _settingsBox.get('lastCheckInDate') as DateTime?;
  }
}