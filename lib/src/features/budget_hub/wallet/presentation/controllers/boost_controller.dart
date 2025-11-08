// lib/src/features/wallet/presentation/controllers/boost_controller.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:equatable/equatable.dart';
import 'package:budgit/src/core/data/providers/transaction_repository_provider.dart';
import 'package:budgit/src/core/domain/models/category.dart';
import 'package:budgit/src/features/budget_hub/wallet/domain/wallet_adjustment.dart';
import 'package:budgit/src/features/budget_hub/wallet/presentation/providers/wallet_category_data_provider.dart';
import 'package:budgit/src/utils/clock_provider.dart';

part 'boost_controller.g.dart';

/// A dedicated state class to hold the initial (confirmed) boost values
/// separately from the current (edited) values.
class BoostControllerState extends Equatable {
  final Map<String, double> initialBoosts;
  final Map<String, double> currentBoosts;

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
  /// Fetches the current week's adjustments and builds the initial state.
  @override
  Future<BoostControllerState> build(Category toCategory) async {
    final repository = ref.watch(transactionRepositoryProvider);
    final clock = ref.watch(clockNotifierProvider);
    final adjustments = await repository.getWalletAdjustmentsForWeek(clock.now());

    final boostMap = <String, double>{};
    for (final adj in adjustments.where((a) => a.toCategoryId == toCategory.id)) {
      boostMap[adj.fromCategoryId] = adj.amount;
    }

    // Both initial and current boosts start with the same confirmed data from the database.
    return BoostControllerState(
      initialBoosts: boostMap,
      currentBoosts: Map.from(boostMap),
    );
  }

  /// Updates the temporary 'currentBoosts' state when the slider moves,
  /// leaving the 'initialBoosts' state untouched.
  void updateAmount(String fromCategoryId, double amount) {
    if (state.hasError || state.isLoading) return;
    
    final newCurrentBoosts = Map<String, double>.from(state.value!.currentBoosts);
    if (amount > 0) {
      newCurrentBoosts[fromCategoryId] = amount;
    } else {
      newCurrentBoosts.remove(fromCategoryId);
    }
    
    state = AsyncValue.data(state.value!.copyWith(currentBoosts: newCurrentBoosts));
  }

  /// Saves the final 'currentBoosts' state to the database upon confirmation.
  Future<void> confirmBoosts() async {
    if (state.hasError || state.isLoading) return;
    final repository = ref.read(transactionRepositoryProvider);
    final clock = ref.read(clockNotifierProvider);

    // First, delete old adjustments to prevent duplicates.
    await repository.deleteWalletAdjustments(toCategory.id, clock.now());

    // Save the edited 'currentBoosts' to the database.
    for (var entry in state.value!.currentBoosts.entries) {
      final adjustment = WalletAdjustment(
        id: DateTime.now().toIso8601String(),
        fromCategoryId: entry.key,
        toCategoryId: toCategory.id,
        amount: entry.value,
        date: clock.now(),
      );
      await repository.addWalletAdjustment(adjustment);
    }
    
    // Invalidate the main wallet data provider to refresh the UI.
    ref.invalidate(walletCategoryDataProvider);
  }
}