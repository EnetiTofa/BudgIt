import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/features/transactions/domain/transaction.dart';
import 'package:budgit/src/features/categories/presentation/category_list_provider.dart';
import 'package:budgit/src/features/transactions/presentation/providers/transaction_log_provider.dart';
import 'package:budgit/src/features/wallet/domain/wallet_category_data.dart';
import 'package:budgit/src/utils/clock_provider.dart';
import 'package:budgit/src/features/transactions/data/transaction_repository_provider.dart';
import 'package:budgit/src/features/settings/presentation/settings_provider.dart';

part 'wallet_category_data_provider.g.dart';

@riverpod
Future<List<WalletCategoryData>> walletCategoryData(Ref ref) async {
  // Fetch all necessary data
  final categories = await ref.watch(categoryListProvider.future);
  final transactionLog = await ref.watch(transactionLogProvider.future);
  final settingsRepo = await ref.watch(settingsProvider.future); // Wait for settings
  
  final repository = ref.watch(transactionRepositoryProvider);
  final now = ref.watch(clockProvider).now();
  
  // Now we can safely get the check-in day
  final checkInDay = settingsRepo.getCheckInDay();
  
  final adjustments = await repository.getWalletAdjustmentsForWeek(now);
  
  // --- Use the correct start of week calculation ---
  final startOfWeek = DateTime(now.year, now.month, now.day - (now.weekday - checkInDay + 7) % 7);
  final startOfToday = DateTime(now.year, now.month, now.day);

  final categoriesWithWallets = categories.where((c) => (c.walletAmount ?? 0) > 0).toList();
  final List<WalletCategoryData> result = [];

  for (final category in categoriesWithWallets) {
    // --- NEW: Calculate the effective weekly budget including boosts ---
    final baseAmount = category.walletAmount ?? 0;
    final incomingBoosts = adjustments.where((a) => a.toCategoryId == category.id).fold(0.0, (sum, a) => sum + a.amount);
    final outgoingBoosts = adjustments.where((a) => a.fromCategoryId == category.id).fold(0.0, (sum, a) => sum + a.amount);
    final effectiveWeeklyBudget = baseAmount + incomingBoosts - outgoingBoosts;
    
    
    final categoryWalletTxs = transactionLog
        .whereType<OneOffPayment>()
        .where((p) => p.isWalleted && p.category.id == category.id && !p.date.isBefore(startOfWeek));
        
    // Calculate spending on completed days vs. today
    final spentInCompletedDays = categoryWalletTxs
        .where((p) => p.date.isBefore(startOfToday))
        .fold(0.0, (sum, p) => sum + p.amount);
        
    final spendingToday = categoryWalletTxs
        .where((p) => !p.date.isBefore(startOfToday))
        .fold(0.0, (sum, p) => sum + p.amount);

    // --- This is the new, correct calculation logic ---
    final daysPassedInWeek = now.difference(startOfWeek).inDays;
    final daysRemaining = 7 - daysPassedInWeek;
    final budgetRemaining = effectiveWeeklyBudget - spentInCompletedDays;
    final recommendedDailySpending = daysRemaining > 0 ? budgetRemaining / daysRemaining : 0.0;

    result.add(
      WalletCategoryData(
        category: category,
        spentInCompletedDays: spentInCompletedDays,
        spendingToday: spendingToday,
        effectiveWeeklyBudget: effectiveWeeklyBudget, // Pass the new value
        recommendedDailySpending: recommendedDailySpending,
      ),
    );
  }
  
  return result;
}