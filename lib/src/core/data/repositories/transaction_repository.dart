import 'package:budgit/src/core/domain/models/transaction.dart';
import 'package:budgit/src/core/domain/models/category.dart';
import 'package:budgit/src/features/budget_hub/wallet/domain/wallet_adjustment.dart';
import 'package:budgit/src/core/domain/models/savings_goal.dart';

/// An abstract class defining the interface for transaction data operations.
/// This decouples the application logic from the specific data source implementation.
abstract class TransactionRepository {
  // --- Transactions ---
  Future<void> addTransaction(Transaction transaction);
  Future<List<Transaction>> getAllTransactions();
  Future<void> updateTransaction(Transaction transaction);
  Future<void> deleteTransaction(String transactionId);
  Future<Transaction?> getTransactionById(String id);

  // --- Categories ---
  Future<void> addCategory(Category category);
  Future<List<Category>> getAllCategories();
  Future<void> updateCategory(Category category);
  Future<void> deleteCategory(String categoryId);
  Future<List<String>?> getCategoryOrder();
  Future<void> saveCategoryOrder(List<String> categoryIds);
  Future<Category?> getCategory(String categoryId);

  // --- Recurring ---
  Future<List<RecurringPayment>> getRecurringTransactionsForCategory(String categoryId);

  // --- Wallet Adjustments (Boosts) ---
  
  /// Adds a single boost/adjustment.
  Future<void> addWalletAdjustment(WalletAdjustment adjustment);
  
  /// Gets all adjustments for a specific week (global).
  Future<List<WalletAdjustment>> getWalletAdjustmentsForWeek(DateTime dateInWeek);

  /// Gets adjustments specifically for a target category in a specific week.
  /// Used by the BoostController.
  Future<List<WalletAdjustment>> getWalletAdjustments(String toCategoryId, DateTime dateInWeek);

  /// Deletes adjustments for a specific category in a specific week.
  Future<void> deleteWalletAdjustments(String toCategoryId, DateTime dateInWeek);

  // --- Savings ---
  Future<void> setSavingsGoal(SavingsGoal goal);
  Future<SavingsGoal?> getSavingsGoal();
  Future<void> addToSavings(double amount);
  Future<double> getTotalSavings();
  Future<void> deleteSavingsGoal();

  // --- Check In / System ---
  Future<void> saveCheckInSummary({required double lastWeekWalletSpending});
  Future<double> getLastWeekWalletSpending();
  
  Future<void> debugResetCheckInData();
  
  Future<int> getCheckInStreak();
  Future<void> incrementCheckInStreak();
  Future<void> resetCheckInStreak();

  Future<void> setLastCheckInDate(DateTime date);
  Future<DateTime?> getLastCheckInDate();

  Future<void> generateDummyData();
  Future<void> deleteAllData();

  Future<void> saveRecentIcons(List<String> iconNames);
  Future<List<String>> getRecentIcons();
}