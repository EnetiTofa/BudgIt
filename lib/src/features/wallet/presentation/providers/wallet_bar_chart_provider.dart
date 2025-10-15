import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/features/transactions/domain/transaction.dart';
import 'package:budgit/src/features/categories/presentation/providers/category_list_provider.dart';
import 'package:budgit/src/features/transactions/presentation/providers/transaction_log_provider.dart';
import 'package:budgit/src/features/settings/presentation/settings_provider.dart';
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
Future<WalletBarChartData> walletBarChartData(Ref ref) async {
  // --- The entire structure is simplified here ---

  // 1. Await all futures at the top. Riverpod handles loading/error states.
  final log = await ref.watch(allTransactionOccurrencesProvider.future);
  final categories = await ref.watch(categoryListProvider.future);
  final settingsNotifier = ref.read(settingsProvider.notifier);

  // 2. Perform the rest of the logic directly. No .when() is needed.
  final checkInDay = await settingsNotifier.getCheckInDay();
  final now = ref.watch(clockNotifierProvider).now();
  
  final startOfWeek = DateTime(now.year, now.month, now.day - (now.weekday - checkInDay + 7) % 7);
  final startOfToday = DateTime(now.year, now.month, now.day);
  
  final walletTxsThisWeek = log
      .whereType<OneOffPayment>()
      .where((p) => p.isWalleted && !p.date.isBefore(startOfWeek))
      .toList();

  final dailyTotals = <int, Map<String, double>>{};
  for (var tx in walletTxsThisWeek) {
    final txLocalDate = tx.date.toLocal();
    final dayIndex = txLocalDate.difference(startOfWeek).inDays;
    if (dayIndex >= 0 && dayIndex < 7) {
      dailyTotals.putIfAbsent(dayIndex, () => {});
      dailyTotals[dayIndex]![tx.category.id] = (dailyTotals[dayIndex]![tx.category.id] ?? 0) + tx.amount;
    }
  }

  final completedDays = startOfToday.difference(startOfWeek).inDays;
  final totalSpentOnCompletedDays = walletTxsThisWeek
      .where((tx) => tx.date.isBefore(startOfToday))
      .fold(0.0, (sum, tx) => sum + tx.amount);
  
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