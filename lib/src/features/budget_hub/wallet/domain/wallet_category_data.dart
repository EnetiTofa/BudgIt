import 'package:equatable/equatable.dart';
import 'package:budgit/src/core/domain/models/category.dart';

class WalletCategoryData extends Equatable {
  const WalletCategoryData({
    required this.category,
    required this.spentInCompletedDays,
    required this.spendingToday,
    required this.effectiveWeeklyBudget,
    required this.recommendedDailySpending,
    required this.daysRemaining,
    required this.currentWeekPattern,
    required this.averageWeekPattern,
  });

  final Category category;
  final double spentInCompletedDays;
  final double spendingToday;
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
  double get amountRemainingThisWeek => effectiveWeeklyBudget - totalSpentThisWeek;

  // --- Speedometer Aliases ---
  
  /// The "Needle" (Past Performance)
  double get currentSpeed => averageDailySpending;

  /// The "Target" (Future Recommendation)
  double get recommendedSpeed => recommendedDailySpending;

  // --- RESTORED: Compatibility Getters ---

  /// Used by: WalletCategoryCard (Main Screen)
  /// Progress bar value from 0.0 to 1.0
  double get weeklyProgress => (effectiveWeeklyBudget > 0) 
      ? (totalSpentThisWeek / effectiveWeeklyBudget).clamp(0.0, 1.0) 
      : 0.0;

  /// Used by: WalletCategoryCard (Main Screen)
  /// Static average based on the fixed wallet amount (e.g. $70 / 7 = $10)
  double get targetDailyAverage => (category.walletAmount ?? 0.0) / 7;
  
  @override
  List<Object?> get props => [
    category, 
    spentInCompletedDays, 
    spendingToday, 
    effectiveWeeklyBudget, 
    recommendedDailySpending,
    daysRemaining,
    currentWeekPattern,
    averageWeekPattern
  ];
}