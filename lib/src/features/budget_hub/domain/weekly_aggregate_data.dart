import 'package:equatable/equatable.dart';

class WeeklyAggregateData extends Equatable {
  const WeeklyAggregateData({
    required this.totalVariableBudget,
    required this.spentCompletedDays,
    required this.spendingToday,
    required this.completedDays,
  });

  final double totalVariableBudget;
  final double spentCompletedDays;
  final double spendingToday;
  final int completedDays;

  // --- Calculated Getters ---
  int get daysRemaining => 7 - completedDays;

  double get totalSpentThisWeek => spentCompletedDays + spendingToday;

  double get amountRemaining => totalVariableBudget - spentCompletedDays;

  // Average spending based only on completed days
  double get averageDailySpending =>
      completedDays > 0 ? spentCompletedDays / completedDays : 0.0;

  // Recommended spending for the rest of the week (including today)
  double get recommendedDailySpending =>
      daysRemaining > 0 ? amountRemaining / daysRemaining : 0.0;

  @override
  List<Object?> get props => [
    totalVariableBudget,
    spentCompletedDays,
    spendingToday,
    completedDays,
  ];
}
