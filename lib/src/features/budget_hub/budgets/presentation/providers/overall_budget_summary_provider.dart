import 'package:equatable/equatable.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:budgit/src/core/data/providers/category_list_provider.dart';
import 'package:budgit/src/core/data/providers/transaction_repository_provider.dart';
import 'package:budgit/src/core/domain/models/transaction.dart';

part 'overall_budget_summary_provider.g.dart';

// A simple class to hold our summary data
class OverallBudgetSummary extends Equatable {
  final double totalIncome;
  final double totalExpenses;

  const OverallBudgetSummary({
    required this.totalIncome,
    required this.totalExpenses,
  });
  
  @override
  List<Object?> get props => [totalIncome, totalExpenses];
}

@riverpod
Future<OverallBudgetSummary> overallBudgetSummary(OverallBudgetSummaryRef ref) async {
  // Get all categories to sum up their budgets
  final categories = await ref.watch(categoryListProvider.future);
  final totalExpenses = categories.fold<double>(0.0, (sum, cat) => sum + cat.budgetAmount);

  // Get all recurring incomes to calculate total income
  final allTransactions = await ref.watch(transactionRepositoryProvider).getAllTransactions();
  final recurringIncomes = allTransactions.whereType<RecurringIncome>();

  final totalIncome = recurringIncomes.fold<double>(0.0, (sum, income) {
    switch (income.recurrence) {
      case RecurrencePeriod.daily:
        return sum + (income.amount * 30.44);
      case RecurrencePeriod.weekly:
        return sum + (income.amount * 4.33);
      case RecurrencePeriod.monthly:
        return sum + income.amount;
      case RecurrencePeriod.yearly:
        return sum + (income.amount / 12);
    }
  });

  return OverallBudgetSummary(
    totalIncome: totalIncome, 
    totalExpenses: totalExpenses,
  );
}