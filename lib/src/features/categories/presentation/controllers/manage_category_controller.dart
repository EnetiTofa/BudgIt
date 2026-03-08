// lib/src/features/categories/presentation/controllers/manage_category_controller.dart

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:budgit/src/core/domain/enums/budget_enum.dart';
import 'package:budgit/src/core/domain/models/category.dart';
import 'package:budgit/src/core/data/providers/transaction_repository_provider.dart';
import 'package:budgit/src/core/domain/models/transaction.dart';
import 'package:budgit/src/features/transaction_hub/transactions/presentation/providers/transaction_log_provider.dart';
import 'package:budgit/src/features/transaction_hub/transactions/presentation/providers/recurring_transactions_provider.dart';
import 'package:budgit/src/core/data/providers/category_list_provider.dart';
import 'package:budgit/src/features/budget_hub/presentation/providers/weekly_projection_providers.dart';
import 'package:budgit/src/features/budget_hub/presentation/providers/monthly_projection_providers.dart';
import 'package:budgit/src/features/budget_hub/presentation/providers/overall_budget_summary_provider.dart';

// --- NEW IMPORT ---
import 'package:budgit/src/utils/date_utils.dart';

part 'manage_category_controller.g.dart';

class ManageCategoryState extends Equatable {
  const ManageCategoryState({
    required this.initialCategory,
    this.recurringTransactions = const [],
    this.budgetPeriod = BudgetPeriod.monthly,
  });

  final Category initialCategory;
  final List<RecurringPayment> recurringTransactions;
  final BudgetPeriod budgetPeriod;

  double get totalBudget => initialCategory.budgetAmount;

  double get displayTotalBudget {
    switch (budgetPeriod) {
      case BudgetPeriod.weekly:
        // --- UPDATED ---
        return totalBudget / AppDateUtils.weeksPerMonth;
      case BudgetPeriod.monthly:
        return totalBudget;
      case BudgetPeriod.yearly:
        return totalBudget * 12;
    }
  }

  double get recurringSum => recurringTransactions.fold(0.0, (sum, p) {
    switch (p.recurrence) {
      case RecurrencePeriod.daily:
        // --- UPDATED ---
        return sum + (p.amount * AppDateUtils.daysPerMonth);
      case RecurrencePeriod.weekly:
        // --- UPDATED ---
        return sum + (p.amount * AppDateUtils.weeksPerMonth);
      case RecurrencePeriod.monthly:
        return sum + p.amount;
      case RecurrencePeriod.yearly:
        return sum + (p.amount / 12);
    }
  });

  // The absolute minimum budget is just the sum of their fixed recurring bills.
  double get minimumBudget => recurringSum;

  // This is what becomes their Weekly Dashboard allowance
  double get variableBudget => totalBudget - recurringSum;

  @override
  List<Object> get props => [
    initialCategory,
    recurringTransactions,
    budgetPeriod,
  ];

  ManageCategoryState copyWith({
    Category? initialCategory,
    List<RecurringPayment>? recurringTransactions,
    BudgetPeriod? budgetPeriod,
  }) {
    return ManageCategoryState(
      initialCategory: initialCategory ?? this.initialCategory,
      recurringTransactions:
          recurringTransactions ?? this.recurringTransactions,
      budgetPeriod: budgetPeriod ?? this.budgetPeriod,
    );
  }
}

@riverpod
class ManageCategoryController extends _$ManageCategoryController {
  List<RecurringPayment> _initialRecurringTransactions = [];
  double _initialBudget = 0.0;

  double _getMonthlyValue(RecurringPayment payment) {
    switch (payment.recurrence) {
      case RecurrencePeriod.daily:
        // --- UPDATED ---
        return payment.amount * AppDateUtils.daysPerMonth;
      case RecurrencePeriod.weekly:
        // --- UPDATED ---
        return payment.amount * AppDateUtils.weeksPerMonth;
      case RecurrencePeriod.monthly:
        return payment.amount;
      case RecurrencePeriod.yearly:
        return payment.amount / 12;
    }
  }

  @override
  Future<ManageCategoryState> build(String categoryId) async {
    final repository = ref.read(transactionRepositoryProvider);
    final category = await repository.getCategory(categoryId);
    final transactions = await repository.getRecurringTransactionsForCategory(
      categoryId,
    );

    if (category == null) {
      throw Exception('Category with ID $categoryId not found');
    }

    _initialRecurringTransactions = transactions;
    _initialBudget = category.budgetAmount;

    return ManageCategoryState(
      initialCategory: category,
      recurringTransactions: transactions,
    );
  }

  double getInitialBudget() => _initialBudget;

  void addRecurringPayment(RecurringPayment payment) {
    if (state.value == null) return;
    final currentState = state.value!;

    // Automatically expand the total budget to accommodate the new bill
    // This perfectly preserves their existing Variable budget allowance.
    final budgetIncrease = _getMonthlyValue(payment);
    final newTotalBudget = currentState.totalBudget + budgetIncrease;

    final updatedList = [...currentState.recurringTransactions, payment];

    state = AsyncData(
      currentState.copyWith(
        recurringTransactions: updatedList,
        initialCategory: currentState.initialCategory.copyWith(
          budgetAmount: newTotalBudget,
        ),
      ),
    );
  }

  void updateRecurringPayment(RecurringPayment updatedPayment) {
    if (state.value == null) return;
    final currentState = state.value!;

    final originalPayment = currentState.recurringTransactions.firstWhereOrNull(
      (p) => p.id == updatedPayment.id,
    );
    if (originalPayment == null) return;

    final originalMonthlyValue = _getMonthlyValue(originalPayment);
    final updatedMonthlyValue = _getMonthlyValue(updatedPayment);
    final budgetDifference = updatedMonthlyValue - originalMonthlyValue;

    final newTotalBudget = currentState.totalBudget + budgetDifference;

    final updatedList = currentState.recurringTransactions
        .map((p) => p.id == updatedPayment.id ? updatedPayment : p)
        .toList();

    state = AsyncData(
      currentState.copyWith(
        recurringTransactions: updatedList,
        initialCategory: currentState.initialCategory.copyWith(
          budgetAmount: newTotalBudget,
        ),
      ),
    );
  }

  void removeRecurringPayment(String paymentId) {
    if (state.value == null) return;
    final currentState = state.value!;

    final paymentToRemove = currentState.recurringTransactions.firstWhereOrNull(
      (p) => p.id == paymentId,
    );
    if (paymentToRemove == null) return;

    // Automatically shrink the budget, preserving Variable allowance
    final budgetDecrease = _getMonthlyValue(paymentToRemove);
    final newTotalBudget = (currentState.totalBudget - budgetDecrease).clamp(
      0.0,
      double.infinity,
    );

    final updatedList = currentState.recurringTransactions
        .where((p) => p.id != paymentId)
        .toList();

    state = AsyncData(
      currentState.copyWith(
        recurringTransactions: updatedList,
        initialCategory: currentState.initialCategory.copyWith(
          budgetAmount: newTotalBudget,
        ),
      ),
    );
  }

  void resetTotalBudget() {
    if (state.value == null) return;
    state = AsyncData(
      state.value!.copyWith(
        initialCategory: state.value!.initialCategory.copyWith(
          budgetAmount: _initialBudget,
        ),
      ),
    );
  }

  Future<void> saveChanges() async {
    if (state.value == null) return;
    final repository = ref.read(transactionRepositoryProvider);
    final finalState = state.value!;

    await repository.updateCategory(finalState.initialCategory);

    final initialIds = _initialRecurringTransactions.map((p) => p.id).toSet();
    final finalIds = finalState.recurringTransactions.map((p) => p.id).toSet();

    final addedIds = finalIds.difference(initialIds);
    for (final id in addedIds) {
      final payment = finalState.recurringTransactions.firstWhere(
        (p) => p.id == id,
      );
      await repository.addTransaction(payment);
    }

    final deletedIds = initialIds.difference(finalIds);
    for (final id in deletedIds) {
      await repository.deleteTransaction(id);
    }

    final potentiallyUpdatedIds = initialIds.intersection(finalIds);
    for (final id in potentiallyUpdatedIds) {
      final initialPayment = _initialRecurringTransactions.firstWhere(
        (p) => p.id == id,
      );
      final finalPayment = finalState.recurringTransactions.firstWhere(
        (p) => p.id == id,
      );
      if (initialPayment != finalPayment) {
        await repository.updateTransaction(finalPayment);
      }
    }

    ref.invalidate(categoryListProvider);
    ref.invalidate(allTransactionOccurrencesProvider);
    ref.invalidate(transactionLogProvider);
    ref.invalidate(rawTransactionsProvider);
    ref.invalidate(recurringTransactionsProvider);

    // Invalidate the Unified Budget providers
    ref.invalidate(weeklyCategoryDataProvider);
    ref.invalidate(weeklyAggregateProvider);
    ref.invalidate(weeklyChartDataProvider);

    ref.invalidate(monthlyCategoryProgressProvider);
    ref.invalidate(globalMonthlyHistoryProvider);
    ref.invalidate(monthlySummaryDetailsProvider);
    ref.invalidate(historicalCategorySpendingProvider);
    ref.invalidate(categoryGaugeDataProvider);
    ref.invalidate(monthlyScreenDataProvider);

    ref.invalidate(overallBudgetSummaryProvider);
  }

  void setTotalBudget(double rawAmount) {
    if (state.value == null) return;
    final currentState = state.value!;

    double monthlyBudget;
    switch (currentState.budgetPeriod) {
      case BudgetPeriod.weekly:
        // --- UPDATED ---
        monthlyBudget = rawAmount * AppDateUtils.weeksPerMonth;
        break;
      case BudgetPeriod.monthly:
        monthlyBudget = rawAmount;
        break;
      case BudgetPeriod.yearly:
        monthlyBudget = rawAmount / 12;
        break;
    }

    // Safety check: Cannot set budget lower than fixed bills
    final minBudget = currentState.minimumBudget;
    final finalTotal = monthlyBudget < minBudget ? minBudget : monthlyBudget;

    state = AsyncData(
      currentState.copyWith(
        initialCategory: currentState.initialCategory.copyWith(
          budgetAmount: finalTotal,
        ),
      ),
    );
  }

  void setBudgetPeriod(BudgetPeriod newPeriod) {
    if (state.value == null) return;
    state = AsyncData(state.value!.copyWith(budgetPeriod: newPeriod));
  }

  void minimizeBudget() {
    if (state.value == null) return;
    final currentState = state.value!;

    // Sets the budget to exactly their fixed expenses (0 Variable allowance)
    final minMonthlyBudget = currentState.minimumBudget;
    state = AsyncData(
      currentState.copyWith(
        initialCategory: currentState.initialCategory.copyWith(
          budgetAmount: minMonthlyBudget,
        ),
      ),
    );
  }
}
