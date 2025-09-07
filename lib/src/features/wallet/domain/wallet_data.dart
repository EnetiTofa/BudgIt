import 'package:equatable/equatable.dart';

class WalletData extends Equatable {
  const WalletData({
    required this.totalWalletBudget,
    required this.spentCompletedDays,
    required this.spendingToday,
    required this.completedDays,
  });

  final double totalWalletBudget;
  final double spentCompletedDays;
  final double spendingToday;
  final int completedDays;

  // --- Calculated Getters ---
  int get daysRemaining => 7 - completedDays;
  double get totalSpentThisWeek => spentCompletedDays + spendingToday;
  double get amountRemaining => totalWalletBudget - spentCompletedDays;
  
  // Average spending based only on completed days
  double get averageDailySpending => completedDays > 0 ? spentCompletedDays / completedDays : 0.0;
  
  // Recommended spending for the rest of the week (including today)
  double get recommendedDailySpending => daysRemaining > 0 ? amountRemaining / daysRemaining : 0.0;

  @override
  List<Object?> get props => [totalWalletBudget, spentCompletedDays, spendingToday, completedDays];
}