import 'package:budgit/src/features/categories/domain/category.dart';

class BudgetProgress {
  const BudgetProgress({
    required this.category,
    required this.amountSpent,
    required this.projectedBudget, // The total budget for the selected timeframe
  });

  final Category category;
  final double amountSpent;
  final double projectedBudget;

  // These getters now use the projected budget for accurate calculations
  double get amountRemaining => projectedBudget - amountSpent;
  double get progress => (projectedBudget > 0) ? (amountSpent / projectedBudget).clamp(0.0, 1.0) : 0.0;
}