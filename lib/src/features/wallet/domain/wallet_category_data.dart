import 'package:equatable/equatable.dart';
import 'package:budgit/src/features/categories/domain/category.dart';

class WalletCategoryData extends Equatable {
  const WalletCategoryData({
    required this.category,
    required this.spentInCompletedDays,
    required this.spendingToday,
    required this.effectiveWeeklyBudget,
  });

  final Category category;
  final double spentInCompletedDays;
  final double spendingToday;
  final double effectiveWeeklyBudget;

  // --- Getters ---
  double get targetDailyAverage => (category.walletAmount ?? 0.0) / 7;
  
  double get averageDailySpending {
    final completedDays = DateTime.now().weekday - 1;
    return completedDays > 0 ? spentInCompletedDays / completedDays : 0.0;
  }
  
  double get totalSpentThisWeek => spentInCompletedDays + spendingToday;
  double get amountRemainingThisWeek => effectiveWeeklyBudget - totalSpentThisWeek;

  // V-- This is the missing getter
  double get recommendedDailySpending {
    final daysRemaining = 8 - DateTime.now().weekday;
    final budgetRemaining = effectiveWeeklyBudget - spentInCompletedDays;
    return daysRemaining > 0 ? budgetRemaining / daysRemaining : 0.0;
  }
  
  double get weeklyProgress => (effectiveWeeklyBudget > 0) ? (totalSpentThisWeek / effectiveWeeklyBudget).clamp(0.0, 1.0) : 0.0;
  
  @override
  List<Object?> get props => [category, spentInCompletedDays, spendingToday, effectiveWeeklyBudget];
}