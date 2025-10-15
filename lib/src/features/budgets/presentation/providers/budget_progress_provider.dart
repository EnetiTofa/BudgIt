// lib/src/features/budgets/presentation/providers/budget_progress_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/features/budgets/domain/budget_progress.dart';
import 'package:budgit/src/features/transactions/domain/transaction.dart';
import 'package:budgit/src/features/categories/presentation/providers/category_list_provider.dart';
import 'package:budgit/src/features/transactions/presentation/providers/transaction_log_provider.dart';

part 'budget_progress_provider.g.dart';

// MODIFIED: The provider now accepts a 'month' parameter instead of 'budgetView'.
@riverpod
Future<List<BudgetProgress>> budgetProgress(
    Ref ref, DateTime month) async {
  final categories = await ref.watch(categoryListProvider.future);
  final allOccurrences = await ref.watch(allTransactionOccurrencesProvider.future);

  // Define the start and end of the selected month.
  final timeFrameStartDate = DateTime(month.year, month.month, 1);
  final timeFrameEndDate = DateTime(month.year, month.month + 1, 0);
  final timeFrameDays = timeFrameEndDate.day;

  final List<BudgetProgress> progressList = [];

  for (final category in categories) {
    // Normalize the category's budget to a daily rate.
    double dailyRate = (category.budgetAmount * 12) / 365.25;

    // Calculate the projected budget for the selected month's length.
    final projectedBudget = dailyRate * timeFrameDays;

    // Calculate actual spending within the selected month.
    final actualSpending = allOccurrences
        .whereType<OneOffPayment>()
        .where((p) =>
            p.category.id == category.id &&
            !p.date.isBefore(timeFrameStartDate) &&
            !p.date.isAfter(timeFrameEndDate))
        .fold(0.0, (sum, p) => sum + p.amount);

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