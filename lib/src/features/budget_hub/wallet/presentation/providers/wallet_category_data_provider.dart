import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/core/domain/models/transaction.dart';
import 'package:budgit/src/core/data/providers/category_list_provider.dart';
import 'package:budgit/src/features/transaction_hub/transactions/presentation/providers/transaction_log_provider.dart';
import 'package:budgit/src/features/budget_hub/wallet/domain/wallet_category_data.dart';
import 'package:budgit/src/utils/clock_provider.dart';
import 'package:budgit/src/features/settings/data/settings_provider.dart';
import 'package:budgit/src/core/data/providers/transaction_repository_provider.dart';

part 'wallet_category_data_provider.g.dart';

final walletDateProvider = StateProvider<DateTime>((ref) {
  return ref.read(clockNotifierProvider).now();
});

@Riverpod(keepAlive: true)
Future<List<WalletCategoryData>> walletCategoryData(
  Ref ref, {
  required DateTime selectedDate,
}) async {
  final categories = await ref.watch(categoryListProvider.future);
  final transactionLog = await ref.watch(allTransactionOccurrencesProvider.future);
  final settingsRepo = await ref.watch(settingsProvider.future);
  final repository = ref.watch(transactionRepositoryProvider); 

  final now = ref.watch(clockNotifierProvider).now();
  final checkInDay = await settingsRepo.getCheckInDay();

  // 1. Calculate Dates
  final startOfSelectedWeek = DateTime(
    selectedDate.year,
    selectedDate.month,
    selectedDate.day - (selectedDate.weekday - checkInDay + 7) % 7,
  );
  final endOfSelectedWeek = startOfSelectedWeek.add(const Duration(days: 7));
  
  final startOfCurrentWeek = DateTime(
    now.year,
    now.month,
    now.day - (now.weekday - checkInDay + 7) % 7,
  );
  
  final isCurrentWeek = startOfSelectedWeek.isAtSameMomentAs(startOfCurrentWeek);
  final startOfToday = DateTime(now.year, now.month, now.day);

  // 2. Fetch Adjustments
  final allBoosts = await repository.getWalletAdjustmentsForWeek(startOfSelectedWeek);

  final List<WalletCategoryData> result = [];

  for (final category in categories) {
    // A. Transactions
    final categoryWalletTxs = transactionLog
        .whereType<OneOffPayment>()
        .where((p) => p.isWalleted && 
                      p.category.id == category.id && 
                      !p.date.isBefore(startOfSelectedWeek) &&
                      p.date.isBefore(endOfSelectedWeek));
    
    double spentInCompletedDays = 0.0;
    double spendingToday = 0.0;
    final List<double> currentWeekPattern = List.filled(7, 0.0);

    for (final tx in categoryWalletTxs) {
      final dayIndex = tx.date.difference(startOfSelectedWeek).inDays;
      if (dayIndex >= 0 && dayIndex < 7) currentWeekPattern[dayIndex] += tx.amount;

      if (isCurrentWeek) {
        if (tx.date.isBefore(startOfToday)) {
          spentInCompletedDays += tx.amount;
        } else {
          spendingToday += tx.amount;
        }
      } else {
        spentInCompletedDays += tx.amount;
      }
    }

    // B. Boosts
    // Incoming: Increases Budget
    final incoming = allBoosts
        .where((b) => b.toCategoryId == category.id)
        .fold(0.0, (sum, b) => sum + b.amount);
        
    // Outgoing: Treated as SPENDING
    for (final b in allBoosts.where((b) => b.fromCategoryId == category.id)) {
      // Add to Pattern
      final dayIndex = b.date.difference(startOfSelectedWeek).inDays;
      if (dayIndex >= 0 && dayIndex < 7) currentWeekPattern[dayIndex] += b.amount;
      
      // Add to Spend Totals (Always today/recent for current week logic, or past)
      if (isCurrentWeek) {
        if (b.date.isBefore(startOfToday)) {
          spentInCompletedDays += b.amount;
        } else {
          spendingToday += b.amount;
        }
      } else {
        spentInCompletedDays += b.amount;
      }
    }

    // C. Budget Math
    final double baseBudget = category.walletAmount ?? category.budgetAmount;
    final double effectiveWeeklyBudget = baseBudget + incoming; 

    // D. Physics
    int daysRemaining;
    if (isCurrentWeek) {
      final daysPassedInWeek = now.difference(startOfCurrentWeek).inDays;
      daysRemaining = (7 - daysPassedInWeek).clamp(1, 7);
    } else {
      daysRemaining = 0;
    }

    final double budgetRemaining = effectiveWeeklyBudget - (spentInCompletedDays + spendingToday);
    
    final double recommendedDailySpending = daysRemaining > 0 
        ? (budgetRemaining / daysRemaining).clamp(0.0, double.infinity) 
        : 0.0;

    final List<double> averageWeekPattern = [10, 10, 10, 10, 20, 50, 50]; 

    result.add(
      WalletCategoryData(
        category: category,
        spentInCompletedDays: spentInCompletedDays,
        spendingToday: spendingToday,
        effectiveWeeklyBudget: effectiveWeeklyBudget,
        recommendedDailySpending: recommendedDailySpending,
        daysRemaining: daysRemaining,
        currentWeekPattern: currentWeekPattern,
        averageWeekPattern: averageWeekPattern,
      ),
    );
  }

  return result;
}