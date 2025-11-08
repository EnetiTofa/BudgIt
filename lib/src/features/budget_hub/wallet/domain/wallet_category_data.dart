import 'package:equatable/equatable.dart';
import 'package:budgit/src/core/domain/models/category.dart';

class WalletCategoryData extends Equatable {
  const WalletCategoryData({
    required this.category,
    required this.spentInCompletedDays,
    required this.spendingToday,
    required this.effectiveWeeklyBudget,
    required this.recommendedDailySpending,
    required this.daysRemaining, // <-- New required property
  });

  final Category category;
  final double spentInCompletedDays;
  final double spendingToday;
  final double effectiveWeeklyBudget;
  final double recommendedDailySpending;
  final int daysRemaining; // <-- New property

  // --- Getters ---
  double get targetDailyAverage => (category.walletAmount ?? 0.0) / 7;
  
  double get averageDailySpending {
    final completedDays = DateTime.now().weekday - 1; // This is a simplified average
    return completedDays > 0 ? spentInCompletedDays / completedDays : 0.0;
  }
  
  double get totalSpentThisWeek => spentInCompletedDays + spendingToday;
  double get amountRemainingThisWeek => effectiveWeeklyBudget - totalSpentThisWeek;

  // The faulty getter is now removed.
  
  double get weeklyProgress => (effectiveWeeklyBudget > 0) ? (totalSpentThisWeek / effectiveWeeklyBudget).clamp(0.0, 1.0) : 0.0;
  
  @override
  List<Object?> get props => [category, spentInCompletedDays, spendingToday, effectiveWeeklyBudget, recommendedDailySpending];
}