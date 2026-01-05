import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/features/budget_hub/wallet/domain/wallet_data.dart';
import 'package:budgit/src/features/budget_hub/wallet/presentation/providers/wallet_category_data_provider.dart';
import 'package:budgit/src/utils/clock_provider.dart';
import 'package:budgit/src/features/settings/data/settings_provider.dart';

part 'wallet_provider.g.dart';

@riverpod
Future<WalletData> walletData(Ref ref) async {
  final now = ref.watch(clockNotifierProvider).now();
  
  // 1. Dependency: Watch the "Source of Truth"
  // We pass 'now' because this provider represents the Current Wallet Status.
  // This automatically handles Boosts, Check-In Day logic, and Filtering.
  final categoryDataList = await ref.watch(walletCategoryDataProvider(selectedDate: now).future);
  
  // 2. Aggregate the Data
  double totalWalletBudget = 0.0;
  double spentCompletedDays = 0.0;
  double spendingToday = 0.0;

  for (final data in categoryDataList) {
    // "effectiveWeeklyBudget" includes the base amount + any incoming boosts
    totalWalletBudget += data.effectiveWeeklyBudget;
    
    // "spentInCompletedDays" includes transactions + outgoing boosts (prior to today)
    spentCompletedDays += data.spentInCompletedDays;
    
    // "spendingToday" includes today's transactions + today's outgoing boosts
    spendingToday += data.spendingToday;
  }

  // 3. Calculate Completed Days (Context)
  // We need to fetch the Check-In Day to accurately calculate how far into the week we are.
  final settingsRepo = await ref.watch(settingsProvider.future);
  final checkInDay = await settingsRepo.getCheckInDay();

  final startOfCurrentWeek = DateTime(
    now.year,
    now.month,
    now.day - (now.weekday - checkInDay + 7) % 7,
  );
  
  final startOfToday = DateTime(now.year, now.month, now.day);
  
  // Difference between "Today" and "Start of Week" gives full days passed
  final completedDays = startOfToday.difference(startOfCurrentWeek).inDays.clamp(0, 7);

  return WalletData(
    totalWalletBudget: totalWalletBudget,
    spentCompletedDays: spentCompletedDays,
    spendingToday: spendingToday,
    completedDays: completedDays,
  );
}