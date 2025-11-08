import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:budgit/src/features/budget_hub/budgets/presentation/providers/budget_progress_provider.dart';
import 'package:budgit/src/core/data/providers/transaction_repository_provider.dart';
import 'package:budgit/src/core/domain/models/category.dart';
import 'package:budgit/src/core/domain/models/transaction.dart';
import 'package:budgit/src/core/data/providers/category_list_provider.dart';
import 'package:budgit/src/features/transaction_hub/transactions/presentation/providers/recurring_transactions_provider.dart';
import 'package:budgit/src/features/transaction_hub/transactions/presentation/providers/transaction_log_provider.dart';
import 'package:budgit/src/utils/clock_provider.dart';
import 'package:budgit/src/core/domain/models/savings_goal.dart';
import 'package:budgit/src/features/budget_hub/savings/presentation/savings_providers.dart';
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
    ref.invalidate(allTransactionOccurrencesProvider);
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
    // Note: OneOffPayment from the main form doesn't have a custom icon.
    // If you add one later, you'll need to add icon fields here.
  }) async {
    final payment = OneOffPayment(
      id: DateTime.now().toIso8601String(),
      notes: '',
      createdAt: ref.read(clockNotifierProvider).now(),
      amount: amount,
      date: date,
      itemName: itemName,
      store: store,
      category: category,
      isWalleted: isWalleted,
    );

    final repository = ref.read(transactionRepositoryProvider);
    await repository.addTransaction(payment);
    _invalidateProviders();
  }

  Future<void> addRecurringPayment({
    required double amount,
    required String paymentName,
    required String payee,
    required DateTime startDate,
    DateTime? endDate,
    required Category category,
    required RecurrencePeriod recurrence,
    required int recurrenceFrequency,
    int? iconCodePoint,
    String? iconFontFamily,
    String? iconFontPackage,
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
      recurrenceFrequency: recurrenceFrequency,
      iconCodePoint: iconCodePoint,
      iconFontFamily: iconFontFamily,
      iconFontPackage: iconFontPackage, // ADD THIS
    );

    final repository = ref.read(transactionRepositoryProvider);
    await repository.addTransaction(payment);
    _invalidateProviders();
  }

  Future<void> updateTransaction(Transaction transaction) async {
    // This method is fine, as the transaction object is built
    // in the form with the fontPackage already included.
    await ref.read(transactionRepositoryProvider).updateTransaction(transaction);
    _invalidateProviders();
  }

  Future<void> deleteTransaction(String transactionId) async {
    final repository = ref.read(transactionRepositoryProvider);
    await repository.deleteTransaction(transactionId);
    _invalidateProviders();
  }
  
  Future<void> addOneOffIncome({
    required double amount,
    required String source,
    required DateTime date,
    String? reference,
    required int iconCodePoint,
    String? iconFontFamily,
    String? iconFontPackage, // ADD THIS
  }) async {
    final income = OneOffIncome(
      id: DateTime.now().toIso8601String(), // Temporary unique ID
      notes: '',
      createdAt: DateTime.now(),
      amount: amount,
      date: date,
      source: source,
      reference: reference,
      iconCodePoint: iconCodePoint,
      iconFontFamily: iconFontFamily,
      iconFontPackage: iconFontPackage, // ADD THIS
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
    required int recurrenceFrequency,
    String? reference,
    required int iconCodePoint,
    String? iconFontFamily,
    String? iconFontPackage, // ADD THIS
  }) async {
    final income = RecurringIncome(
      id: DateTime.now().toIso8601String(),
      notes: '',
      createdAt: ref.read(clockNotifierProvider).now(),
      amount: amount,
      source: source,
      startDate: startDate,
      endDate: endDate,
      recurrence: recurrence,
      recurrenceFrequency: recurrenceFrequency,
      reference: reference, 
      iconCodePoint: iconCodePoint,
      iconFontFamily: iconFontFamily,
      iconFontPackage: iconFontPackage, // ADD THIS
    );

    final repository = ref.read(transactionRepositoryProvider);
    await repository.addTransaction(income);
    _invalidateProviders();
  }

  Future<void> addCategory({
    required String name,
    required double budgetAmount,
    required IconData icon,
    required Color color,
    double? walletAmount, 
    }) async {
    final newCategory = Category(
      id: DateTime.now().toIso8601String(), // Temporary unique ID
      name: name,
      iconCodePoint: icon.codePoint,
      iconFontFamily: icon.fontFamily,
      iconFontPackage: icon.fontPackage, // ADD THIS
      colorValue: color.value,
      budgetAmount: budgetAmount,
      walletAmount: walletAmount,
    );

    final repository = ref.read(transactionRepositoryProvider);
    await repository.addCategory(newCategory);
    _invalidateProviders();
  }

  Future<void> updateCategory({
    required String id,
    required String name,
    required double budgetAmount,
    double? walletAmount,
    required IconData icon,
    required Color color,
  }) async {
    final updatedCategory = Category(
      id: id,
      name: name,
      iconCodePoint: icon.codePoint,
      iconFontFamily: icon.fontFamily,
      iconFontPackage: icon.fontPackage, // ADD THIS
      colorValue: color.value,
      budgetAmount: budgetAmount,
      walletAmount: walletAmount,
    );

    final repository = ref.read(transactionRepositoryProvider);
    await repository.updateCategory(updatedCategory);
    _invalidateProviders();
  }

  // ... (deleteCategory and all other methods are unchanged) ...
  Future<void> deleteCategory(String categoryId) async {
    final repository = ref.read(transactionRepositoryProvider);
    await repository.deleteCategory(categoryId);
    _invalidateProviders();
  }

   Future<void> setSavingsGoal(
    double targetAmount, {
    DateTime? startDate,
  }) async {
    final repository = ref.read(transactionRepositoryProvider);
    final clock = ref.read(clockNotifierProvider);
    
    final newGoal = SavingsGoal(
      id: 'activeGoal',
      targetAmount: targetAmount,
      createdAt: startDate ?? clock.now(),
    );
    
    await repository.setSavingsGoal(newGoal);
    
    ref.invalidate(savingsGoalProvider);
    ref.invalidate(potentialWeeklySavingsProvider);
  }

  Future<void> addToSavings(double amount) async {
    final repository = ref.read(transactionRepositoryProvider);
    await repository.addToSavings(amount);
    ref.invalidate(totalSavingsProvider);
  }

  Future<void> deleteSavingsGoal() async {
    final repository = ref.read(transactionRepositoryProvider);
    await repository.deleteSavingsGoal();
    ref.invalidate(savingsGoalProvider);
    ref.invalidate(savingsGaugeDataProvider);
  }

  Future<void> generateDummyData() async {
    final repository = ref.read(transactionRepositoryProvider);
    await repository.generateDummyData();
    _invalidateProviders();
  }

  Future<void> deleteAllData() async {
    final repository = ref.read(transactionRepositoryProvider);
    await repository.deleteAllData();
    _invalidateProviders();
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