import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/features/budgets/domain/budget_progress.dart';
import 'package:budgit/src/features/budgets/domain/monthly_spending.dart';
import 'package:budgit/src/features/budgets/presentation/providers/budget_progress_provider.dart';
import 'package:budgit/src/features/budgets/presentation/providers/historical_spending_provider.dart';
import 'package:budgit/src/features/budgets/presentation/screens/budgets_screen.dart';

part 'budget_screen_data_provider.g.dart';

/// A class to hold all the data needed by the BudgetsScreen.
class BudgetScreenData {
  const BudgetScreenData({
    required this.historicalSpending,
    required this.budgetProgress,
  });
  final List<MonthlySpending> historicalSpending;
  final List<BudgetProgress> budgetProgress;
}

/// This provider fetches all necessary data for the budget screen.
/// It ensures that both historical and progress data are loaded before the UI builds,
/// preventing the "zero-out" flicker on the timeline.
@riverpod
Future<BudgetScreenData> budgetScreenData(Ref ref) async {
  // First, get all historical spending data.
  final historicalSpending = await ref.watch(historicalSpendingProvider.future);

  // Determine which month is currently selected.
  final selectedMonth = ref.watch(selectedMonthProvider) ??
      (historicalSpending.isNotEmpty
          ? historicalSpending.last.date
          : DateTime.now());

  // Then, get the budget progress for that specific month.
  final budgetProgress = await ref.watch(budgetProgressProvider(selectedMonth).future);

  // Return both sets of data together in a single object.
  return BudgetScreenData(
    historicalSpending: historicalSpending,
    budgetProgress: budgetProgress,
  );
}