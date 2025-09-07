import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:budgit/src/features/budgets/presentation/budget_progress_provider.dart';
import 'package:budgit/src/features/transactions/data/transaction_repository_provider.dart';
import 'package:budgit/src/features/categories/domain/category.dart';
import 'package:budgit/src/features/transactions/domain/transaction.dart';
import 'package:budgit/src/features/categories/presentation/category_list_provider.dart';
import 'package:budgit/src/features/transactions/presentation/providers/recurring_transactions_provider.dart';
import 'package:budgit/src/features/transactions/presentation/providers/transaction_log_provider.dart';
import 'package:budgit/src/utils/clock_provider.dart';
import 'package:budgit/src/features/savings/domain/savings_goal.dart';
import 'package:budgit/src/features/savings/presentation/savings_providers.dart';
import 'package:budgit/src/features/check_in/presentation/streak_provider.dart';
import 'package:budgit/src/features/check_in/presentation/is_check_in_available_provider.dart';




part 'add_transaction_controller.g.dart';

@riverpod
class AddTransactionController extends _$AddTransactionController {
  @override
  bool build() => true;

  /// Helper method to invalidate all data providers and trigger a UI refresh.
  void _invalidateProviders() {
    ref.invalidate(transactionLogProvider);
    ref.invalidate(categoryListProvider);
    ref.invalidate(recurringTransactionsProvider);
    ref.invalidate(budgetProgressProvider);
    ref.invalidate(isCheckInAvailableProvider);
    // Add any future dashboard providers here as well
  }
  
  /// A public method to add a one-off payment.
  /// The UI will call this method when the "Save" button is pressed.
  Future<void> addOneOffPayment({
    required double amount,
    required String itemName,
    required DateTime date,
    required bool isWalleted,
    required Category category,
    required String store,
  }) async {
    final payment = OneOffPayment(
      id: DateTime.now().toIso8601String(),
      notes: '',
      createdAt: ref.read(clockProvider).now(),
      amount: amount,
      date: date,
      itemName: itemName,
      store: store, // We can make this a form field later
      category: category,
    );

    final repository = ref.read(transactionRepositoryProvider);
    await repository.addTransaction(payment);
    _invalidateProviders();
  }
  Future<void> addRecurringPayment({
    required double amount,
    required String paymentName, // Changed from payee
    required String payee,       // Added this parameter
    required DateTime startDate,
    DateTime? endDate,         // Added optional endDate
    required Category category,
    required RecurrencePeriod recurrence,
  }) async {
    final payment = RecurringPayment(
      id: DateTime.now().toIso8601String(),
      notes: '',
      createdAt: DateTime.now(),
      amount: amount,
      paymentName: paymentName,
      payee: payee,
      startDate: startDate,
      endDate: endDate,
      category: category,
      recurrence: recurrence,
    );

    final repository = ref.read(transactionRepositoryProvider);
    await repository.addTransaction(payment);
    _invalidateProviders();
  }
  Future<void> updateTransaction(Transaction transaction) async {
    await ref.read(transactionRepositoryProvider).updateTransaction(transaction);
    _invalidateProviders();
  }
  Future<void> addOneOffIncome({
    required double amount,
    required String source,
    required DateTime date,
  }) async {
    final income = OneOffIncome(
      id: DateTime.now().toIso8601String(), // Temporary unique ID
      notes: '',
      createdAt: DateTime.now(),
      amount: amount,
      date: date,
      source: source,
    );

    final repository = ref.read(transactionRepositoryProvider);
    await repository.addTransaction(income);
    _invalidateProviders();
  }
  Future<void> addRecurringIncome({
    required double amount,
    required String source,
    required DateTime startDate,
    DateTime? endDate,
    required RecurrencePeriod recurrence,
  }) async {
    final income = RecurringIncome(
      id: DateTime.now().toIso8601String(),
      notes: '',
      createdAt: ref.read(clockProvider).now(),
      amount: amount,
      source: source,
      startDate: startDate,
      endDate: endDate,
      recurrence: recurrence,
    );

    final repository = ref.read(transactionRepositoryProvider);
    await repository.addTransaction(income);
    _invalidateProviders();
  }
  Future<void> addCategory({
    required String name,
    required double budgetAmount,     // Now required
    required BudgetPeriod budgetPeriod,
    required IconData icon,   // Add this
    required Color color, // Now required
    double? walletAmount, 
    }) async {
    final newCategory = Category(
      id: DateTime.now().toIso8601String(), // Temporary unique ID
      name: name,
      // For now, we'll hardcode the icon and color
      iconCodePoint: icon.codePoint,
      iconFontFamily: icon.fontFamily,
      colorValue: color.value,
      budgetAmount: budgetAmount,
      budgetPeriod: budgetPeriod,
      walletAmount: walletAmount,
    );

    final repository = ref.read(transactionRepositoryProvider);
    await repository.addCategory(newCategory);
    _invalidateProviders();
  }

  Future<void> updateCategory({
    required String id, // We need the original ID to update the correct item
    required String name,
    required double budgetAmount,
    required BudgetPeriod budgetPeriod,
    double? walletAmount,
    required IconData icon,
    required Color color,
  }) async {
    final updatedCategory = Category(
      id: id,
      name: name,
      iconCodePoint: icon.codePoint,
      iconFontFamily: icon.fontFamily,
      colorValue: color.value,
      budgetAmount: budgetAmount,
      budgetPeriod: budgetPeriod,
      walletAmount: walletAmount,
    );

    final repository = ref.read(transactionRepositoryProvider);
    await repository.updateCategory(updatedCategory);
    _invalidateProviders();
  }

  Future<void> deleteCategory(String categoryId) async {
    final repository = ref.read(transactionRepositoryProvider);
    await repository.deleteCategory(categoryId);
    _invalidateProviders();
  }

  Future<void> setSavingsGoal(double targetAmount) async {
    final repository = ref.read(transactionRepositoryProvider);
    final clock = ref.read(clockProvider);
    
    final newGoal = SavingsGoal(
      id: 'activeGoal',
      targetAmount: targetAmount,
      createdAt: clock.now(),
    );
    
    await repository.setSavingsGoal(newGoal);
    
    ref.invalidate(savingsGoalProvider);
    ref.invalidate(potentialWeeklySavingsProvider); // This might change if logic depends on the goal
  }

  Future<void> addToSavings(double amount) async {
    final repository = ref.read(transactionRepositoryProvider);
    await repository.addToSavings(amount);
    ref.invalidate(totalSavingsProvider);
  }

  Future<void> debugResetCheckInData() async {
    await ref.read(transactionRepositoryProvider).debugResetCheckInData();
    _invalidateProviders();
  }

  Future<void> debugResetStreak() async {
    await ref.read(transactionRepositoryProvider).resetCheckInStreak();
    ref.invalidate(checkInStreakProvider);
  }
}