// lib/src/features/budget_hub/wallet/presentation/providers/wallet_bar_chart_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/core/domain/models/transaction.dart';
import 'package:budgit/src/core/data/providers/category_list_provider.dart';
import 'package:budgit/src/features/transaction_hub/transactions/presentation/providers/transaction_log_provider.dart';
import 'package:budgit/src/features/settings/data/settings_provider.dart';
import 'package:budgit/src/utils/clock_provider.dart';
import 'package:equatable/equatable.dart';

part 'wallet_bar_chart_provider.g.dart';

// A data class to hold all the calculated chart data
class WalletBarChartData extends Equatable {
  const WalletBarChartData({
    required this.dailyTotals,
    required this.dailyWalletTarget,
    required this.averageDailySpend,
    required this.maxY,
  });

  // Map of {dayIndex: {categoryId: amountSpent}}
  final Map<int, Map<String, double>> dailyTotals;
  final double dailyWalletTarget;
  final double averageDailySpend;
  final double maxY; // The max Y-axis value for the chart

  @override
  List<Object?> get props => [dailyTotals, dailyWalletTarget, averageDailySpend, maxY];
}

@riverpod
Future<WalletBarChartData> walletBarChartData(
  Ref ref, {
  required DateTime selectedDate,
}) async {
  final log = await ref.watch(allTransactionOccurrencesProvider.future);
  final categories = await ref.watch(categoryListProvider.future);
  final settingsNotifier = ref.read(settingsProvider.notifier);

  final checkInDay = await settingsNotifier.getCheckInDay();
  final now = ref.watch(clockNotifierProvider).now();
  
  // Calculate start of the week for the selected date
  final startOfSelectedWeek = DateTime(
    selectedDate.year, 
    selectedDate.month, 
    selectedDate.day - (selectedDate.weekday - checkInDay + 7) % 7
  );
  
  // End of the selected week (exclusive for logic usually, but here just +7 days)
  final endOfSelectedWeek = startOfSelectedWeek.add(const Duration(days: 7));

  // Determine if we are looking at the current active week
  final startOfCurrentWeek = DateTime(
    now.year, 
    now.month, 
    now.day - (now.weekday - checkInDay + 7) % 7
  );
  
  final isCurrentWeek = startOfSelectedWeek.year == startOfCurrentWeek.year &&
                        startOfSelectedWeek.month == startOfCurrentWeek.month &&
                        startOfSelectedWeek.day == startOfCurrentWeek.day;

  // Filter transactions for the selected week
  final walletTxsThisWeek = log
      .whereType<OneOffPayment>()
      .where((p) => p.isWalleted && 
                    !p.date.isBefore(startOfSelectedWeek) &&
                    p.date.isBefore(endOfSelectedWeek))
      .toList();

  final dailyTotals = <int, Map<String, double>>{};
  for (var tx in walletTxsThisWeek) {
    final txLocalDate = tx.date.toLocal();
    final dayIndex = txLocalDate.difference(startOfSelectedWeek).inDays;
    if (dayIndex >= 0 && dayIndex < 7) {
      dailyTotals.putIfAbsent(dayIndex, () => {});
      dailyTotals[dayIndex]![tx.category.id] = (dailyTotals[dayIndex]![tx.category.id] ?? 0) + tx.amount;
    }
  }

  // Calculate completed days
  int completedDays;
  double totalSpentOnCompletedDays;

  if (isCurrentWeek) {
    // If it's the current week, calculate up to "today"
    final startOfToday = DateTime(now.year, now.month, now.day);
    completedDays = startOfToday.difference(startOfSelectedWeek).inDays;
    // Ensure we don't divide by zero or go out of bounds if it's day 0
    if (completedDays < 0) completedDays = 0;
    
    totalSpentOnCompletedDays = walletTxsThisWeek
        .where((tx) => tx.date.isBefore(startOfToday))
        .fold(0.0, (sum, tx) => sum + tx.amount);
  } else {
    // If it's a past week, all 7 days are "completed"
    completedDays = 7;
    totalSpentOnCompletedDays = walletTxsThisWeek
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }
  
  final averageDailySpend = (completedDays > 0 && totalSpentOnCompletedDays > 0) 
      ? totalSpentOnCompletedDays / completedDays 
      : 0.0;
  
  final totalWalletBudget = categories.fold(0.0, (sum, cat) => sum + (cat.walletAmount ?? 0.0));
  final dailyWalletTarget = totalWalletBudget > 0 ? totalWalletBudget / 7 : 0.0;
  
  double maxY = dailyWalletTarget > 0 ? dailyWalletTarget : 50.0;
  if (averageDailySpend > maxY) maxY = averageDailySpend;
  dailyTotals.values.forEach((dayMap) {
    final total = dayMap.values.fold(0.0, (sum, item) => sum + item);
    if (total > maxY) maxY = total;
  });

  return WalletBarChartData(
    dailyTotals: dailyTotals,
    dailyWalletTarget: dailyWalletTarget,
    averageDailySpend: averageDailySpend,
    maxY: maxY * 1.2,
  );
}