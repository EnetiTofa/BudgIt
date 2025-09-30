import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/features/transactions/data/transaction_repository_provider.dart';
import 'package:budgit/src/features/categories/presentation/providers/category_list_provider.dart';
import 'package:budgit/src/features/categories/domain/category.dart';
import 'package:budgit/src/features/transactions/domain/transaction.dart';
import 'package:budgit/src/features/settings/presentation/settings_provider.dart';
import 'package:budgit/src/features/savings/domain/savings_goal.dart';
import 'package:budgit/src/utils/clock_provider.dart';

part 'savings_providers.g.dart';

/// The "Financial Analyst" provider.
/// Calculates the user's average weekly unspent wallet funds based on historical data.
@riverpod
Future<double> averageWeeklySavings(Ref ref) async {
  final categories = await ref.watch(categoryListProvider.future);
  final allTransactions = await ref.watch(transactionRepositoryProvider).getAllTransactions();
  final checkInDay = await ref.watch(settingsProvider.future);
  
  // This logic is complex, for now we can return a realistic placeholder.
  // TODO: Implement historical analysis logic.
  return 25.50; // Placeholder for average unspent funds per week.
}
/// Fetches total savings from the repository (snapshot data).
@riverpod
Future<double> totalSavings(Ref ref) { // <-- Change TotalSavingsRef to Ref
  return ref.watch(transactionRepositoryProvider).getTotalSavings();
}
/// The "Motivator" provider.
/// Calculates the potential weekly savings if the user sticks to a simple rule.
@riverpod
Future<double> potentialWeeklySavings(Ref ref) async {
  final categories = await ref.watch(categoryListProvider.future);
  
  // Simple rule: Potential savings is 15% of the total weekly wallet budget.
  final totalWalletBudget = categories.fold(0.0, (sum, cat) => sum + (cat.walletAmount ?? 0.0));
  return totalWalletBudget * 0.15;
}

// A provider for the main SavingsGoal object
@riverpod
Future<SavingsGoal?> savingsGoal(SavingsGoalRef ref) {
  return ref.watch(transactionRepositoryProvider).getSavingsGoal();
}