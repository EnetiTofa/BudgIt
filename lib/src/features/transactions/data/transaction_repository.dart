import 'package:budgit/src/features/transactions/domain/transaction.dart';
import 'package:budgit/src/features/categories/domain/category.dart';
import 'package:budgit/src/features/wallet/domain/wallet_adjustment.dart';
import 'package:budgit/src/features/savings/domain/savings_goal.dart';



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

  Future<void> addWalletAdjustment(WalletAdjustment adjustment);

  Future<List<WalletAdjustment>> getWalletAdjustmentsForWeek(DateTime dateInWeek);

  Future<void> deleteWalletAdjustments(String toCategoryId, DateTime dateInWeek);

  Future<void> setSavingsGoal(SavingsGoal goal);

  Future<SavingsGoal?> getSavingsGoal();

  Future<void> addToSavings(double amount);

  Future<double> getLastWeekWalletSpending();

  Future<double> getTotalSavings();

  Future<void> saveCheckInSummary({required double lastWeekWalletSpending});
  
  Future<void> debugResetCheckInData();
  
  Future<int> getCheckInStreak();
  Future<void> incrementCheckInStreak();
  Future<void> resetCheckInStreak();

  Future<void> setLastCheckInDate(DateTime date);
  Future<DateTime?> getLastCheckInDate();
}