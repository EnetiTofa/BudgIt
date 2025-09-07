import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:budgit/src/features/categories/domain/category.dart';
import 'package:budgit/src/features/transactions/domain/transaction.dart';
import 'package:budgit/src/features/categories/presentation/category_list_provider.dart';
import 'package:budgit/src/features/transactions/presentation/transaction_log_provider.dart';
import 'package:budgit/src/utils/clock_provider.dart';

part 'dashboard_providers.g.dart';

// A simple data class to hold our summary calculations.
class MonthlySummary {
  const MonthlySummary({required this.totalBudget, required this.totalSpending});
  final double totalBudget;
  final double totalSpending;
  double get progress => (totalBudget > 0) ? (totalSpending / totalBudget).clamp(0.0, 1.0) : 0.0;
  double get amountRemaining => totalBudget - totalSpending;
}

@riverpod
Future<MonthlySummary> monthlySummary(MonthlySummaryRef ref) async {
  final categories = await ref.watch(categoryListProvider.future);
  final transactionLog = await ref.watch(transactionLogProvider.future);
  final now = ref.watch(clockProvider).now();
  
  final startOfMonth = DateTime(now.year, now.month, 1);
  double totalMonthlyBudget = 0;

  // Normalize all category budgets to a monthly amount
  for (final category in categories) {
    switch (category.budgetPeriod) {
      case BudgetPeriod.weekly:
        totalMonthlyBudget += category.budgetAmount * 4.345; // Avg weeks in a month
        break;
      case BudgetPeriod.monthly:
        totalMonthlyBudget += category.budgetAmount;
        break;
      case BudgetPeriod.yearly:
        totalMonthlyBudget += category.budgetAmount / 12;
        break;
    }
  }

  // Calculate total spending for the current month
  final totalMonthlySpending = transactionLog
      .whereType<OneOffPayment>()
      .where((p) => !p.date.isBefore(startOfMonth))
      .fold(0.0, (sum, p) => sum + p.amount);

  return MonthlySummary(
    totalBudget: totalMonthlyBudget,
    totalSpending: totalMonthlySpending,
  );
}