import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/features/budgets/domain/budget_progress.dart';
import 'package:budgit/src/features/budgets/presentation/budgets_screen.dart'; // Import for BudgetView
import 'package:budgit/src/features/categories/domain/category.dart';
import 'package:budgit/src/features/transactions/domain/transaction.dart';
import 'package:budgit/src/features/categories/presentation/category_list_provider.dart';
import 'package:budgit/src/features/transactions/presentation/providers/transaction_log_provider.dart';
import 'package:budgit/src/utils/clock_provider.dart';

part 'budget_progress_provider.g.dart';


@riverpod
Future<List<BudgetProgress>> budgetProgress(Ref ref, BudgetView budgetView) async {
  final categories = await ref.watch(categoryListProvider.future);
  final transactionLog = await ref.watch(transactionLogProvider.future);
  final clock = ref.watch(clockProvider);
  final now = clock.now();

  final timeFrameDays = _getDaysInTimeframe(budgetView);
  final timeFrameStartDate = now.subtract(Duration(days: timeFrameDays));

  final List<BudgetProgress> progressList = [];

  for (final category in categories) {
    // Step 1: Normalize the category's budget to a daily rate.
    double dailyRate = 0;
    switch (category.budgetPeriod) {
      case BudgetPeriod.weekly:
        dailyRate = category.budgetAmount / 7;
        break;
      case BudgetPeriod.monthly:
        dailyRate = (category.budgetAmount * 12) / 365.25;
        break;
      case BudgetPeriod.yearly:
        dailyRate = category.budgetAmount / 365.25;
        break;
    }

    // Step 2: Calculate the projected budget for the selected timeframe.
    final projectedBudget = dailyRate * timeFrameDays;

    // Step 3: Calculate actual spending within the timeframe.
    final actualSpending = transactionLog
        .whereType<OneOffPayment>()
        .where((p) => p.category.id == category.id && !p.date.isBefore(timeFrameStartDate))
        .fold(0.0, (sum, p) => sum + p.amount);

    // Step 4: Create the final progress object.
    progressList.add(
      BudgetProgress(
        category: category,
        amountSpent: actualSpending,
        projectedBudget: projectedBudget,
      ),
    );
  }

  return progressList;
}

int _getDaysInTimeframe(BudgetView view) {
  switch (view) {
    case BudgetView.monthly:
      return 30;
    case BudgetView.threeMonthly:
      return 90;
    case BudgetView.sixMonthly:
      return 180;
    case BudgetView.yearly:
      return 365;
  }
}