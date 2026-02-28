import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:budgit/src/core/data/providers/transaction_repository_provider.dart';
import 'package:budgit/src/core/domain/models/category.dart';
import 'package:budgit/src/core/domain/models/transaction.dart';
import 'package:budgit/src/core/data/providers/category_list_provider.dart';
import 'package:budgit/src/features/transaction_hub/transactions/presentation/providers/recurring_transactions_provider.dart';
import 'package:budgit/src/features/transaction_hub/transactions/presentation/providers/transaction_log_provider.dart';
import 'package:budgit/src/utils/clock_provider.dart';
import 'package:budgit/src/features/check_in/presentation/providers/streak_provider.dart';
import 'package:budgit/src/features/check_in/presentation/providers/is_check_in_available_provider.dart';

// --- NEW CONSOLIDATED IMPORTS ---
import 'package:budgit/src/features/budget_hub/presentation/providers/weekly_projection_providers.dart';
import 'package:budgit/src/features/budget_hub/presentation/providers/monthly_projection_providers.dart';
import 'package:budgit/src/features/budget_hub/presentation/providers/overall_budget_summary_provider.dart';

part 'add_transaction_controller.g.dart';

@riverpod
class AddTransactionController extends _$AddTransactionController {
  @override
  bool build() => true;

  // REFACTORED: Pings the new centralized temporal providers
  void _invalidateProviders() {
    ref.invalidate(rawTransactionsProvider);
    ref.invalidate(transactionLogProvider);
    ref.invalidate(categoryListProvider);
    ref.invalidate(recurringTransactionsProvider);
    ref.invalidate(isCheckInAvailableProvider);
    ref.invalidate(allTransactionOccurrencesProvider);

    // Invalidate the new Unified Budget providers
    ref.invalidate(weeklyCategoryDataProvider);
    ref.invalidate(weeklyAggregateProvider);
    ref.invalidate(weeklyChartDataProvider);

    ref.invalidate(monthlyCategoryProgressProvider);
    ref.invalidate(globalMonthlyHistoryProvider);
    ref.invalidate(monthlySummaryDetailsProvider);
    ref.invalidate(historicalCategorySpendingProvider);
    ref.invalidate(categoryGaugeDataProvider);
    ref.invalidate(monthlyScreenDataProvider);

    // FIX: Lowercase 'o' to call the generated provider instance
    ref.invalidate(overallBudgetSummaryProvider);
  }

  Future<void> addOneOffPayment({
    required double amount,
    required String itemName,
    required DateTime date,
    required Category category,
    required String store,
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
      iconFontPackage: iconFontPackage,
    );

    final repository = ref.read(transactionRepositoryProvider);
    await repository.addTransaction(payment);
    _invalidateProviders();
  }

  Future<void> updateTransaction(Transaction transaction) async {
    await ref
        .read(transactionRepositoryProvider)
        .updateTransaction(transaction);
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
    String? iconFontPackage,
  }) async {
    final income = OneOffIncome(
      id: DateTime.now().toIso8601String(),
      notes: '',
      createdAt: DateTime.now(),
      amount: amount,
      date: date,
      source: source,
      reference: reference,
      iconCodePoint: iconCodePoint,
      iconFontFamily: iconFontFamily,
      iconFontPackage: iconFontPackage,
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
    String? iconFontPackage,
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
      iconFontPackage: iconFontPackage,
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
  }) async {
    final newCategory = Category(
      id: DateTime.now().toIso8601String(),
      name: name,
      iconCodePoint: icon.codePoint,
      iconFontFamily: icon.fontFamily,
      iconFontPackage: icon.fontPackage,
      colorValue: color.value,
      budgetAmount: budgetAmount,
    );

    final repository = ref.read(transactionRepositoryProvider);
    await repository.addCategory(newCategory);
    _invalidateProviders();
  }

  Future<void> updateCategory({
    required String id,
    required String name,
    required double budgetAmount,
    required IconData icon,
    required Color color,
  }) async {
    final updatedCategory = Category(
      id: id,
      name: name,
      iconCodePoint: icon.codePoint,
      iconFontFamily: icon.fontFamily,
      iconFontPackage: icon.fontPackage,
      colorValue: color.value,
      budgetAmount: budgetAmount,
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

  // --- DELETED SAVINGS METHODS ---

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

  Future<void> debugClearCheckInHistory() async {
    await ref.read(transactionRepositoryProvider).clearCheckInHistory();
    ref.invalidate(isCheckInAvailableProvider);
    ref.invalidate(checkInStreakProvider);
    _invalidateProviders();
  }
}
