import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:equatable/equatable.dart';
import 'package:budgit/src/core/data/providers/transaction_repository_provider.dart';
import 'package:budgit/src/core/domain/models/category.dart';
import 'package:budgit/src/features/budget_hub/wallet/domain/wallet_adjustment.dart';
import 'package:budgit/src/features/budget_hub/wallet/presentation/providers/wallet_category_data_provider.dart';
import 'package:budgit/src/utils/clock_provider.dart';

part 'boost_controller.g.dart';

class BoostControllerState extends Equatable {
  final Map<String, double> initialBoosts; // What is in the DB
  final Map<String, double> currentBoosts; // What is being edited

  const BoostControllerState({
    required this.initialBoosts,
    required this.currentBoosts,
  });

  @override
  List<Object?> get props => [initialBoosts, currentBoosts];

  BoostControllerState copyWith({
    Map<String, double>? initialBoosts,
    Map<String, double>? currentBoosts,
  }) {
    return BoostControllerState(
      initialBoosts: initialBoosts ?? this.initialBoosts,
      currentBoosts: currentBoosts ?? this.currentBoosts,
    );
  }
}

@riverpod
class BoostState extends _$BoostState {
  @override
  FutureOr<BoostControllerState> build(Category toCategory) async {
    final repository = ref.watch(transactionRepositoryProvider);
    final clock = ref.watch(clockNotifierProvider);

    // Fetch existing adjustments from DB
    // Assuming getWalletAdjustments returns List<WalletAdjustment>
    final adjustments = await repository.getWalletAdjustments(toCategory.id, clock.now());
    
    // Map them: FromCategoryId -> Amount
    final Map<String, double> map = {};
    for (var adj in adjustments) {
      map[adj.fromCategoryId] = adj.amount;
    }

    return BoostControllerState(initialBoosts: map, currentBoosts: map);
  }

  void updateAmount(String fromCategoryId, double amount) {
    if (state.hasError || state.isLoading || state.value == null) return;
    
    final newCurrent = Map<String, double>.from(state.value!.currentBoosts);
    if (amount > 0) {
      newCurrent[fromCategoryId] = amount;
    } else {
      newCurrent.remove(fromCategoryId);
    }
    
    // Update local state immediately for UI feedback
    state = AsyncValue.data(state.value!.copyWith(currentBoosts: newCurrent));
  }

  Future<void> confirmBoosts() async {
    if (state.hasError || state.isLoading || state.value == null) return;
    
    final repository = ref.read(transactionRepositoryProvider);
    final clock = ref.read(clockNotifierProvider);
    final currentMap = state.value!.currentBoosts;

    state = const AsyncValue.loading();

    try {
      // 1. Clear old adjustments for this target
      await repository.deleteWalletAdjustments(toCategory.id, clock.now());

      // 2. Save new adjustments
      for (var entry in currentMap.entries) {
        final adjustment = WalletAdjustment(
          id: '${entry.key}_${toCategory.id}_${clock.now().millisecondsSinceEpoch}',
          fromCategoryId: entry.key,
          toCategoryId: toCategory.id,
          amount: entry.value,
          date: clock.now(),
        );
        await repository.addWalletAdjustment(adjustment);
      }

      // 3. UPDATE LOCAL STATE (Crucial for UI update)
      // The "Draft" (current) becomes the "Initial" (saved)
      state = AsyncValue.data(BoostControllerState(
        initialBoosts: currentMap,
        currentBoosts: currentMap,
      ));

      // 4. INVALIDATE DATA PROVIDERS
      // This forces the "Speedometer" and "Gauge" to recalculate with the new budget
      // Note: We use the family provider, so we must invalidate the specific instance
      ref.invalidate(walletCategoryDataProvider);
      
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}