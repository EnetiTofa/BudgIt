// lib/src/features/budgets/presentation/providers/budget_screen_data_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/features/budget_hub/budgets/domain/budget_progress.dart';
import 'package:budgit/src/features/budget_hub/budgets/domain/monthly_spending.dart';
// Import the summary details class
import 'package:budgit/src/features/budget_hub/budgets/presentation/providers/monthly_summary_provider.dart';
import 'package:budgit/src/features/budget_hub/budgets/presentation/providers/budget_progress_provider.dart';
import 'package:budgit/src/features/budget_hub/budgets/presentation/providers/historical_spending_provider.dart';
import 'package:budgit/src/features/budget_hub/budgets/presentation/screens/budgets_screen.dart';

part 'budget_screen_data_provider.g.dart';

/// A class to hold all the data needed by the BudgetsScreen.
class BudgetScreenData {
  const BudgetScreenData({
    required this.historicalSpending,
    required this.budgetProgress,
    required this.summaryDetails,
  });
  final List<MonthlySpending> historicalSpending;
  final List<BudgetProgress> budgetProgress;
  final BudgetSummaryDetails summaryDetails;
}

/// This provider fetches all necessary data for the budget screen.
/// It ensures that all data is loaded before the UI builds,
/// preventing flickering on month changes.
@riverpod
Future<BudgetScreenData> budgetScreenData(Ref ref) async {
  // First, get all historical spending data.
  final historicalSpending = await ref.watch(historicalSpendingProvider.future);

  // Determine which month is currently selected.
  final selectedMonth = ref.watch(selectedMonthProvider) ??
      (historicalSpending.isNotEmpty
          ? historicalSpending.last.date
          : DateTime.now());

  // Use Future.wait to fetch month-specific data concurrently.
  final (budgetProgress, summaryDetails) = await (
    ref.watch(budgetProgressProvider(selectedMonth).future),
    ref.watch(budgetSummaryDetailsProvider(selectedMonth).future),
  ).wait;

  // Return all data together in a single object.
  return BudgetScreenData(
    historicalSpending: historicalSpending,
    budgetProgress: budgetProgress,
    summaryDetails: summaryDetails,
  );
}