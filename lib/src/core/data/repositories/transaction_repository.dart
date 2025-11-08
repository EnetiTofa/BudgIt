import 'package:budgit/src/core/domain/models/transaction.dart';
import 'package:budgit/src/core/domain/models/category.dart';
import 'package:budgit/src/features/budget_hub/wallet/domain/wallet_adjustment.dart';
import 'package:budgit/src/core/domain/models/savings_goal.dart';



/// An abstract class defining the interface for transaction data operations.
/// This decouples the application logic from the specific data source implementation.
abstract class TransactionRepository {
  /// Adds a new transaction.
  Future<void> addTransaction(Transaction transaction);
  /// Retrieves all transactions.
  Future<List<Transaction>> getAllTransactions();
  /// Updates a transaction
  Future<void> updateTransaction(Transaction transaction);
  /// Deletes a transaction
  Future<void> deleteTransaction(String transactionId);
  
  Future<Transaction?> getTransactionById(String id);

  /// Adds a new category.
  Future<void> addCategory(Category category);
  /// Gets all categories.
  Future<List<Category>> getAllCategories();
  /// Updates a category.
  Future<void> updateCategory(Category category);
  /// Deletes a category.
  Future<void> deleteCategory(String categoryId);
  /// Retrieves the saved order of category IDs.
  Future<List<String>?> getCategoryOrder();
  /// Saves the order of category IDs.
  Future<void> saveCategoryOrder(List<String> categoryIds);

  Future<Category?> getCategory(String categoryId);

  Future<List<RecurringPayment>> getRecurringTransactionsForCategory(String categoryId);

  /// Adds Boost Adjustment to Wallet.
  Future<void> addWalletAdjustment(WalletAdjustment adjustment);
  /// Gets all Boost Adjustments.
  Future<List<WalletAdjustment>> getWalletAdjustmentsForWeek(DateTime dateInWeek);
  /// Deletes Boost Adjustment to Wallet.
  Future<void> deleteWalletAdjustments(String toCategoryId, DateTime dateInWeek);

  Future<void> setSavingsGoal(SavingsGoal goal);

  Future<SavingsGoal?> getSavingsGoal();

  Future<void> addToSavings(double amount);

  Future<double> getTotalSavings();

  Future<void> deleteSavingsGoal();

  Future<void> saveCheckInSummary({required double lastWeekWalletSpending});

  /// Gets Last Weeks Wallet Spending for Check In.
  Future<double> getLastWeekWalletSpending();
  
  Future<void> debugResetCheckInData();
  
  Future<int> getCheckInStreak();
  Future<void> incrementCheckInStreak();
  Future<void> resetCheckInStreak();

  Future<void> setLastCheckInDate(DateTime date);
  Future<DateTime?> getLastCheckInDate();

  /// Generates a year's worth of dummy transactions for debugging.
  Future<void> generateDummyData();
  
  /// Deletes all transactions and adjustments.
  Future<void> deleteAllData();

  Future<void> saveRecentIcons(List<String> iconNames);

  /// Retrieves the list of most recently used icon names.
  Future<List<String>> getRecentIcons();

}