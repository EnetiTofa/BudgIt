import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:budgit/src/features/transactions/data/transaction_repository_provider.dart';
import 'package:budgit/src/features/categories/domain/category.dart';
import 'package:budgit/src/features/wallet/domain/wallet_adjustment.dart';
import 'package:budgit/src/features/wallet/presentation/controllers/wallet_category_data_provider.dart';
import 'package:budgit/src/utils/clock_provider.dart';

part 'boost_controller.g.dart';

// The provider is no longer kept alive. It will re-fetch its state each time you enter the screen.
@riverpod
class BoostState extends _$BoostState {
  
  /// The build method is now async. It fetches the current week's adjustments
  /// and builds the initial state map.
  @override
  Future<Map<String, double>> build(Category toCategory) async {
    final repository = ref.watch(transactionRepositoryProvider);
    final clock = ref.watch(clockProvider);
    final adjustments = await repository.getWalletAdjustmentsForWeek(clock.now());

    final boostMap = <String, double>{};
    // We only care about boosts TO the current category we are editing.
    for (final adj in adjustments.where((a) => a.toCategoryId == toCategory.id)) {
      boostMap[adj.fromCategoryId] = adj.amount;
    }
    return boostMap;
  }

  /// Called by the slider widget to update the in-memory state.
  void updateAmount(String fromCategoryId, double amount) {
    if (state.hasError || state.isLoading) return; // Don't update while loading
    final newState = Map<String, double>.from(state.value!);
    if (amount > 0) {
      newState[fromCategoryId] = amount;
    } else {
      newState.remove(fromCategoryId);
    }
    state = AsyncValue.data(newState);
  }

  /// Called when the user presses "Confirm".
  Future<void> confirmBoosts() async {
    final repository = ref.read(transactionRepositoryProvider);
    final clock = ref.read(clockProvider);
    
    // First, delete all old adjustments for this "to" category for the week
    // to prevent duplicates.
    await repository.deleteWalletAdjustments(toCategory.id, clock.now());

    for (var entry in state.value!.entries) {
      final adjustment = WalletAdjustment(
        id: DateTime.now().toIso8601String(),
        fromCategoryId: entry.key,
        toCategoryId: toCategory.id,
        amount: entry.value,
        date: clock.now(),
      );
      await repository.addWalletAdjustment(adjustment);
    }
    
    // Invalidate providers to refresh the WalletScreen UI.
    ref.invalidate(walletCategoryDataProvider);
  }
}