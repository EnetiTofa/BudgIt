import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:budgit/src/features/check_in/domain/check_in_state.dart';
import 'package:budgit/src/features/transactions/data/transaction_repository_provider.dart';
import 'package:budgit/src/features/transactions/domain/transaction.dart';
import 'package:budgit/src/features/categories/presentation/providers/category_list_provider.dart';
import 'package:budgit/src/features/wallet/presentation/providers/wallet_category_data_provider.dart';
import 'package:budgit/src/features/settings/presentation/settings_provider.dart';
import 'package:budgit/src/utils/clock_provider.dart';
import 'package:budgit/src/features/savings/presentation/savings_providers.dart';
import 'package:budgit/src/features/wallet/domain/wallet_adjustment.dart';
import 'package:budgit/src/features/check_in/presentation/is_check_in_available_provider.dart';

part 'check_in_controller.g.dart';

@riverpod
class CheckInController extends _$CheckInController {
  @override
  CheckInState build() {
    return const CheckInState();
  }

  Future<void> startCheckIn() async {
    state = state.copyWith(status: CheckInStatus.loading);
    
    final clock = ref.read(clockProvider);
    final categories = await ref.read(categoryListProvider.future);
    final allTransactions = await ref.read(transactionRepositoryProvider).getAllTransactions();
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final checkInDay = await settingsNotifier.getCheckInDay();
    final now = clock.now();
    
    final daysSinceCheckIn = (now.weekday - checkInDay + 7) % 7;
    final endOfLastWeek = DateTime(now.year, now.month, now.day - daysSinceCheckIn - 1, 23, 59, 59);
    final startOfLastWeek = endOfLastWeek.subtract(const Duration(days: 6));

    final Map<String, double> unspentByCategory = {};

    for (final category in categories.where((c) => (c.walletAmount ?? 0) > 0)) {
      final weeklyWallet = category.walletAmount!;
      
      final spending = allTransactions
          .whereType<OneOffPayment>()
          .where((p) => p.isWalleted && p.category.id == category.id && !p.date.isBefore(startOfLastWeek) && p.date.isBefore(endOfLastWeek))
          .fold(0.0, (sum, p) => sum + p.amount);
          
      final unspent = (weeklyWallet - spending).clamp(0, double.infinity).toDouble();
      if (unspent > 0) {
        unspentByCategory[category.id] = unspent;
      }
    }

    state = state.copyWith(
      status: CheckInStatus.dataReady,
      unspentFundsByCategory: unspentByCategory,
    );
  }

  void makeDecision(RolloverDecision decision) {
    state = state.copyWith(decision: decision);
    if (decision == RolloverDecision.save) {
      // If user chooses "Save", clear any custom rollover amounts
      state = state.copyWith(rolloverAmounts: {});
    }
  }

  void updateRolloverAmount(String categoryId, double amount) {
    final newAmounts = Map<String, double>.from(state.rolloverAmounts);
    final unspent = state.unspentFundsByCategory[categoryId] ?? 0;
    
    // Ensure the rollover amount doesn't exceed the unspent amount
    final clampedAmount = amount.clamp(0.0, unspent);
    
    if (clampedAmount > 0) {
      newAmounts[categoryId] = clampedAmount;
    } else {
      newAmounts.remove(categoryId);
    }
    state = state.copyWith(rolloverAmounts: newAmounts);
  }

  Future<void> completeCheckIn() async {
    final repository = ref.read(transactionRepositoryProvider);
    final clock = ref.read(clockProvider);
    
    double totalToSave = 0;
    
    if (state.decision == RolloverDecision.save) {
      totalToSave = state.unspentFundsByCategory.values.fold(0.0, (sum, val) => sum + val);
    } else if (state.decision == RolloverDecision.rollover) {
      for (var entry in state.unspentFundsByCategory.entries) {
        final categoryId = entry.key;
        final unspent = entry.value;
        final rolloverAmount = state.rolloverAmounts[categoryId] ?? 0;
        final amountToSave = unspent - rolloverAmount;

        if (amountToSave > 0) {
          totalToSave += amountToSave;
        }

        if (rolloverAmount > 0) {
          final rollover = WalletAdjustment(
            id: 'rollover_${categoryId}_${clock.now().toIso8601String()}',
            fromCategoryId: 'rollover',
            toCategoryId: categoryId,
            amount: rolloverAmount,
            date: clock.now(),
          );
          await repository.addWalletAdjustment(rollover);
        }
      }
    }

    if (totalToSave > 0) {
      await repository.addToSavings(totalToSave);
    }
    // await repository.saveCheckInSummary(lastWeekWalletSpending: totalSpent);
    await repository.incrementCheckInStreak();
    // Save the date of this completed check-in
    await repository.setLastCheckInDate(clock.now());
    // Invalidate the provider so the menu button will update
    ref.invalidate(isCheckInAvailableProvider);

    // Invalidate other providers
    ref.invalidate(totalSavingsProvider);
    ref.invalidate(walletCategoryDataProvider);
  }
}