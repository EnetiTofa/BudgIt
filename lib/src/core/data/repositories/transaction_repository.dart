import 'package:budgit/src/core/domain/models/transaction.dart';
import 'package:budgit/src/core/domain/models/category.dart';
import 'package:budgit/src/features/budget_hub/domain/budget_transfer.dart';
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
  Future<List<RecurringPayment>> getRecurringTransactionsForCategory(
    String categoryId,
  );

  // --- Wallet Adjustments (Boosts) ---

  /// Adds a single boost/adjustment.
  Future<void> addBudgetTransfer(BudgetTransfer adjustment);

  /// Gets all adjustments for a specific week (global).
  Future<List<BudgetTransfer>> getBudgetTransfersForWeek(DateTime dateInWeek);

  /// Gets adjustments specifically for a target category in a specific week.
  /// Used by the BoostController.
  Future<List<BudgetTransfer>> getBudgetTransfers(
    String toCategoryId,
    DateTime dateInWeek,
  );

  /// Deletes adjustments for a specific category in a specific week.
  Future<void> deleteBudgetTransfers(String toCategoryId, DateTime dateInWeek);

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

  // --- ADD THESE NEW METHODS ---
  /// Records the result of a check-in.
  /// If [isSuccess] is true, adds [date] to history and increments streak.
  /// If [isSuccess] is false, resets streak to 0.
  Future<void> recordCheckInAttempt({
    required DateTime date,
    required bool isSuccess,
  });

  Future<void> clearCheckInHistory();

  /// Returns a list of all dates where the check-in was successful.
  Future<List<DateTime>> getSuccessfulCheckInDates();
  Future<void> generateDummyData();
  Future<void> deleteAllData();

  Future<void> saveRecentIcons(List<String> iconNames);
  Future<List<String>> getRecentIcons();

  // ... Keep all existing methods ...

  // --- UNDO CHECK-IN METHODS ---
  Future<void> saveUndoCheckInState({
    required DateTime date,
    required double savedAmount,
    required int previousStreak,
    required bool wasSuccess,
  });
  Future<Map<String, dynamic>?> getUndoCheckInState();
  Future<void> clearUndoCheckInState();

  Future<void> deleteRolloverAdjustments(DateTime date);
  Future<void> setCheckInStreak(int streak);
  Future<void> setCheckInHistory(List<DateTime> history);
  Future<void> clearLastCheckInDate();
}
