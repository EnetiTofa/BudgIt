import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';

import 'package:budgit/src/features/budget_hub/wallet/presentation/providers/wallet_category_data_provider.dart';
import 'package:budgit/src/features/settings/data/settings_provider.dart';
import 'package:budgit/src/utils/clock_provider.dart';

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
  
  // The static daily budget (Total Weekly Budget / 7)
  final double dailyWalletTarget;
  
  // The actual average spent per day in the past
  final double averageDailySpend;
  
  // The max Y-axis value for the chart
  final double maxY; 

  @override
  List<Object?> get props => [dailyTotals, dailyWalletTarget, averageDailySpend, maxY];
}

@riverpod
Future<WalletBarChartData> walletBarChartData(
  Ref ref, {
  required DateTime selectedDate,
}) async {
  // 1. Dependency: Watch the Category Data
  // This ensures we use the EXACT same numbers, boosts, and filtering logic as the list.
  final categoryDataList = await ref.watch(walletCategoryDataProvider(selectedDate: selectedDate).future);
  
  // We still need settings/clock for global date context (calculating "completed days")
  final settingsRepo = await ref.watch(settingsProvider.future);
  final checkInDay = await settingsRepo.getCheckInDay();
  final now = ref.watch(clockNotifierProvider).now();

  // ---------------------------------------------------------
  // 2. Calculate Date Context (Reuse logic for consistency)
  // ---------------------------------------------------------
  final startOfSelectedWeek = DateTime(
    selectedDate.year,
    selectedDate.month,
    selectedDate.day - (selectedDate.weekday - checkInDay + 7) % 7,
  );
  
  final startOfCurrentWeek = DateTime(
    now.year,
    now.month,
    now.day - (now.weekday - checkInDay + 7) % 7,
  );

  final isCurrentWeek = startOfSelectedWeek.isAtSameMomentAs(startOfCurrentWeek);
  final startOfToday = DateTime(now.year, now.month, now.day);

  // Calculate how many days have fully passed (for Average Daily Spend calc)
  int completedDays;
  if (isCurrentWeek) {
    // Difference gives full days passed. E.g., if today is Wed (start Mon), diff is 2.
    completedDays = startOfToday.difference(startOfSelectedWeek).inDays; 
    if (completedDays < 0) completedDays = 0;
  } else {
    completedDays = 7;
  }

  // ---------------------------------------------------------
  // 3. Aggregate Data from Categories
  // ---------------------------------------------------------
  final dailyTotals = <int, Map<String, double>>{};
  double totalEffectiveWeeklyBudget = 0.0;
  double totalSpentInCompletedDays = 0.0;

  for (final data in categoryDataList) {
    // A. Sum up the Totals
    // Note: data.effectiveWeeklyBudget already includes Category Amount + Incoming Boosts
    totalEffectiveWeeklyBudget += data.effectiveWeeklyBudget;
    
    // Note: data.spentInCompletedDays already includes Txs + Outgoing Boosts (before today)
    totalSpentInCompletedDays += data.spentInCompletedDays;

    // B. Merge the Patterns for the Bar Chart
    // data.currentWeekPattern is a List<double> of length 7
    for (int i = 0; i < 7; i++) {
      final amount = data.currentWeekPattern[i];
      if (amount != 0) {
        dailyTotals.putIfAbsent(i, () => {});
        // Map: DayIndex -> CategoryID -> Amount
        dailyTotals[i]![data.category.id] = (dailyTotals[i]![data.category.id] ?? 0.0) + amount;
      }
    }
  }

  // ---------------------------------------------------------
  // 4. Calculate Final Chart Metrics
  // ---------------------------------------------------------

  // Target: We use the Static Average (Total Budget / 7). 
  // This provides a consistent baseline for the chart.
  // (Unlike the "Recommended" value in the list, which changes daily based on remaining funds)
  final dailyWalletTarget = totalEffectiveWeeklyBudget > 0 
      ? totalEffectiveWeeklyBudget / 7.0 
      : 0.0;

  // Average Spend: Total spent in the past / number of days passed
  final averageDailySpend = (completedDays > 0 && totalSpentInCompletedDays > 0)
      ? totalSpentInCompletedDays / completedDays
      : 0.0;

  // Max Y: Scale the chart
  double maxY = dailyWalletTarget > 0 ? dailyWalletTarget : 50.0;
  
  // Check against average
  if (averageDailySpend > maxY) maxY = averageDailySpend;
  
  // Check against daily spikes
  dailyTotals.values.forEach((dayMap) {
    final dayTotal = dayMap.values.fold(0.0, (sum, val) => sum + val);
    if (dayTotal > maxY) maxY = dayTotal;
  });

  return WalletBarChartData(
    dailyTotals: dailyTotals,
    dailyWalletTarget: dailyWalletTarget,
    averageDailySpend: averageDailySpend,
    maxY: maxY * 1.2, // Add 20% headroom
  );
}