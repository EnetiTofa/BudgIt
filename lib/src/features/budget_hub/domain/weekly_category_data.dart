import 'package:equatable/equatable.dart';
import 'package:budgit/src/core/domain/models/category.dart';

class WeeklyCategoryData extends Equatable {
  const WeeklyCategoryData({
    required this.category,
    required this.spentInCompletedDays,
    required this.spendingToday,
    required this.baseWeeklyBudget,
    required this.effectiveWeeklyBudget,
    required this.recommendedDailySpending,
    required this.daysRemaining,
    required this.currentWeekPattern,
    required this.averageWeekPattern,
  });

  final Category category;
  final double spentInCompletedDays;
  final double spendingToday;
  final double baseWeeklyBudget;
  final double effectiveWeeklyBudget;
  final double recommendedDailySpending;

  final int daysRemaining;
  final List<double> currentWeekPattern;
  final List<double> averageWeekPattern;

  // --- Core Getters ---

  /// Average spending per day for the completed days of this week (excluding today).
  double get averageDailySpending {
    final int daysPassed = 7 - daysRemaining;
    return daysPassed > 0 ? spentInCompletedDays / daysPassed : 0.0;
  }

  double get totalSpentThisWeek => spentInCompletedDays + spendingToday;

  double get amountRemainingThisWeek =>
      effectiveWeeklyBudget - totalSpentThisWeek;

  // --- Speedometer Aliases ---

  /// The "Needle" (Past Performance)
  double get currentSpeed => averageDailySpending;

  /// The "Target" (Future Recommendation)
  double get recommendedSpeed => recommendedDailySpending;

  // --- UI Compatibility Getters ---

  /// Progress bar value from 0.0 to 1.0
  double get weeklyProgress => (effectiveWeeklyBudget > 0)
      ? (totalSpentThisWeek / effectiveWeeklyBudget).clamp(0.0, 1.0)
      : 0.0;

  /// Static average based on the derived weekly variable budget.
  double get targetDailyAverage => baseWeeklyBudget / 7.0;

  @override
  List<Object?> get props => [
    category,
    spentInCompletedDays,
    spendingToday,
    baseWeeklyBudget,
    effectiveWeeklyBudget,
    recommendedDailySpending,
    daysRemaining,
    currentWeekPattern,
    averageWeekPattern,
  ];
}
