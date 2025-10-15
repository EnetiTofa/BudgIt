// lib/src/features/categories/presentation/controllers/manage_category_controller.dart

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:budgit/src/features/categories/domain/budget_enum.dart';
import 'package:budgit/src/features/categories/domain/category.dart';
import 'package:budgit/src/features/transactions/data/transaction_repository_provider.dart';
import 'package:budgit/src/features/transactions/domain/transaction.dart';
import 'package:budgit/src/features/transactions/presentation/providers/transaction_log_provider.dart';
import 'package:budgit/src/features/categories/presentation/providers/category_list_provider.dart';

part 'manage_category_controller.g.dart';

class ManageCategoryState extends Equatable {
  const ManageCategoryState({
    required this.initialCategory,
    this.recurringTransactions = const [],
    this.isBudgetLocked = true,
    this.budgetPeriod = BudgetPeriod.monthly,
  });
  
  final Category initialCategory;
  final List<RecurringPayment> recurringTransactions;
  final bool isBudgetLocked;
  final BudgetPeriod budgetPeriod;

  double get totalBudget => initialCategory.budgetAmount;
  double get walletAmount => initialCategory.walletAmount ?? 0.0;
  double get monthlyWalletAmount => walletAmount * 4.33;

  double get displayTotalBudget {
    switch (budgetPeriod) {
      case BudgetPeriod.weekly:
        return totalBudget / 4.33;
      case BudgetPeriod.monthly:
        return totalBudget;
      case BudgetPeriod.yearly:
        return totalBudget * 12;
    }
  }

  double get recurringSum => recurringTransactions.fold(0.0, (sum, p) {
    switch (p.recurrence) {
      case RecurrencePeriod.daily:
        return sum + (p.amount * 30.44);
      case RecurrencePeriod.weekly:
        return sum + (p.amount * 4.33);
      case RecurrencePeriod.monthly:
        return sum + p.amount;
      case RecurrencePeriod.yearly:
        return sum + (p.amount / 12);
    }
  });
  
  // Provides the minimum budget allowed based on current allocations.
  double get minimumBudget => recurringSum + monthlyWalletAmount;

  double get availableForAllocation => totalBudget - recurringSum;
  double get oneOffsAmount => availableForAllocation - monthlyWalletAmount;

  @override
  List<Object> get props => [initialCategory, recurringTransactions, isBudgetLocked, budgetPeriod];

  ManageCategoryState copyWith({
    Category? initialCategory,
    List<RecurringPayment>? recurringTransactions,
    bool? isBudgetLocked,
    BudgetPeriod? budgetPeriod,
  }) {
    return ManageCategoryState(
      initialCategory: initialCategory ?? this.initialCategory,
      recurringTransactions: recurringTransactions ?? this.recurringTransactions,
      isBudgetLocked: isBudgetLocked ?? this.isBudgetLocked,
      budgetPeriod: budgetPeriod ?? this.budgetPeriod,
    );
  }
}


@riverpod
class ManageCategoryController extends _$ManageCategoryController {
  double _initialWalletAmount = 0.0;
  List<RecurringPayment> _initialRecurringTransactions = [];
  double _initialBudget = 0.0;

  /// A private helper to get the standardized monthly value of any payment.
  double _getMonthlyValue(RecurringPayment payment) {
    switch (payment.recurrence) {
      case RecurrencePeriod.daily:
        return payment.amount * 30.44;
      case RecurrencePeriod.weekly:
        return payment.amount * 4.33;
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
    final transactions = await repository.getRecurringTransactionsForCategory(categoryId);

    if (category == null) {
      throw Exception('Category with ID $categoryId not found');
    }
    _initialWalletAmount = category.walletAmount ?? 0.0;
    _initialRecurringTransactions = transactions;
    _initialBudget = category.budgetAmount;

    return ManageCategoryState(
      initialCategory: category,
      recurringTransactions: transactions,
    );
  }

  double getInitialBudget() => _initialBudget;

  /// This method now automatically increases the budget.
  void addRecurringPayment(RecurringPayment payment) {
    if (state.value == null) return;
    final currentState = state.value!;

    // Calculate the monthly increase and update the budget
    final budgetIncrease = _getMonthlyValue(payment);
    final newTotalBudget = currentState.totalBudget + budgetIncrease;

    final updatedList = [...currentState.recurringTransactions, payment];
    
    state = AsyncData(currentState.copyWith(
      recurringTransactions: updatedList,
      initialCategory: currentState.initialCategory.copyWith(budgetAmount: newTotalBudget),
    ));
  }

  /// This method now adjusts the budget based on the change in the payment.
  void updateRecurringPayment(RecurringPayment updatedPayment) {
    if (state.value == null) return;
    final currentState = state.value!;
    
    // Find the original payment to calculate the budget difference
    final originalPayment = currentState.recurringTransactions.firstWhereOrNull((p) => p.id == updatedPayment.id);
    if (originalPayment == null) return; // Should not happen

    final originalMonthlyValue = _getMonthlyValue(originalPayment);
    final updatedMonthlyValue = _getMonthlyValue(updatedPayment);
    final budgetDifference = updatedMonthlyValue - originalMonthlyValue;

    final newTotalBudget = currentState.totalBudget + budgetDifference;

    final updatedList = currentState.recurringTransactions
        .map((p) => p.id == updatedPayment.id ? updatedPayment : p)
        .toList();

    state = AsyncData(currentState.copyWith(
      recurringTransactions: updatedList,
      initialCategory: currentState.initialCategory.copyWith(budgetAmount: newTotalBudget),
    ));
  }

  /// This method now automatically decreases the budget.
  void removeRecurringPayment(String paymentId) {
    if (state.value == null) return;
    final currentState = state.value!;
    
    // Find the payment to be removed to calculate the budget decrease
    final paymentToRemove = currentState.recurringTransactions.firstWhereOrNull((p) => p.id == paymentId);
    if (paymentToRemove == null) return; // Should not happen

    final budgetDecrease = _getMonthlyValue(paymentToRemove);
    // Ensure budget doesn't fall below zero
    final newTotalBudget = (currentState.totalBudget - budgetDecrease).clamp(0.0, double.infinity);

    final updatedList = currentState.recurringTransactions
        .where((p) => p.id != paymentId)
        .toList();
        
    state = AsyncData(currentState.copyWith(
      recurringTransactions: updatedList,
      initialCategory: currentState.initialCategory.copyWith(budgetAmount: newTotalBudget),
    ));
  }

  void resetTotalBudget() {
    if (state.value == null) return;
    // Directly update the state's budget amount to the stored initial value.
    state = AsyncData(state.value!.copyWith(
      initialCategory: state.value!.initialCategory.copyWith(budgetAmount: _initialBudget),
    ));
  }

  void resetWalletAmount() { 
    setWalletAmount(_initialWalletAmount); 
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
      final payment = finalState.recurringTransactions.firstWhere((p) => p.id == id);
      await repository.addTransaction(payment);
    }

    final deletedIds = initialIds.difference(finalIds);
    for (final id in deletedIds) {
      await repository.deleteTransaction(id);
    }
    
    final potentiallyUpdatedIds = initialIds.intersection(finalIds);
    for (final id in potentiallyUpdatedIds) {
      final initialPayment = _initialRecurringTransactions.firstWhere((p) => p.id == id);
      final finalPayment = finalState.recurringTransactions.firstWhere((p) => p.id == id);
      if (initialPayment != finalPayment) {
        await repository.updateTransaction(finalPayment);
      }
    }

    ref.invalidate(categoryListProvider);
    ref.invalidate(allTransactionOccurrencesProvider);
  }

  void setTotalBudget(double rawAmount) {
    if (state.value == null) return;
    final currentState = state.value!;
    
    double monthlyBudget;
    switch (currentState.budgetPeriod) {
      case BudgetPeriod.weekly:
        monthlyBudget = rawAmount * 4.33;
        break;
      case BudgetPeriod.monthly:
        monthlyBudget = rawAmount;
        break;
      case BudgetPeriod.yearly:
        monthlyBudget = rawAmount / 12;
        break;
    }
    
    // Use the new getter here
    final minBudget = currentState.minimumBudget;
    final finalTotal = monthlyBudget < minBudget ? minBudget : monthlyBudget;

    state = AsyncData(currentState.copyWith(
      initialCategory: currentState.initialCategory.copyWith(budgetAmount: finalTotal),
    ));
  }
  
  void setBudgetPeriod(BudgetPeriod newPeriod) {
    if (state.value == null) return;
    state = AsyncData(state.value!.copyWith(budgetPeriod: newPeriod));
  }
  
  void setWalletAmount(double newWeeklyWallet) {
    if (state.value == null) return;
    final currentState = state.value!;

    if (currentState.isBudgetLocked) {
      final maxWeeklyWallet = currentState.availableForAllocation / 4.33;
      final finalWallet = newWeeklyWallet > maxWeeklyWallet
          ? maxWeeklyWallet
          : (newWeeklyWallet < 0 ? 0.0 : newWeeklyWallet);
      state = AsyncData(currentState.copyWith(
        initialCategory:
            currentState.initialCategory.copyWith(walletAmount: finalWallet),
      ));
    } else {
      final newMonthlyWallet = newWeeklyWallet * 4.33;
      final newTotalBudget = currentState.recurringSum + newMonthlyWallet;
      if (newTotalBudget > currentState.totalBudget) {
        state = AsyncData(currentState.copyWith(
          initialCategory: currentState.initialCategory.copyWith(
            budgetAmount: newTotalBudget,
            walletAmount: newWeeklyWallet,
          ),
        ));
      } else {
        state = AsyncData(currentState.copyWith(
          initialCategory:
              currentState.initialCategory.copyWith(walletAmount: newWeeklyWallet),
        ));
      }
    }
  }

  void toggleBudgetLock() {
    if (state.value == null) return;
    state = AsyncData(state.value!
        .copyWith(isBudgetLocked: !state.value!.isBudgetLocked));
  }

  void minimizeBudget() {
    if (state.value == null) return;
    final currentState = state.value!;
    final minMonthlyBudget = currentState.minimumBudget;
    state = AsyncData(currentState.copyWith(
      initialCategory: currentState.initialCategory.copyWith(budgetAmount: minMonthlyBudget),
    ));
  }
}