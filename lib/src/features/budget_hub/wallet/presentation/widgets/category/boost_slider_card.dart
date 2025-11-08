// lib/src/features/wallet/presentation/widgets/boost_slider_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/core/domain/models/category.dart';
import 'package:budgit/src/features/budget_hub/wallet/presentation/controllers/boost_controller.dart';
import 'package:budgit/src/common_widgets/amount_slider_card.dart';
import 'package:budgit/src/features/budget_hub/wallet/presentation/providers/wallet_category_data_provider.dart';

class BoostSliderCard extends ConsumerWidget {
  final Category fromCategory;
  final Category toCategory;

  const BoostSliderCard({
    super.key,
    required this.fromCategory,
    required this.toCategory,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletCategoriesAsync = ref.watch(walletCategoryDataProvider);
    final boostControllerStateAsync = ref.watch(boostStateProvider(toCategory));

    // Combine the loading/error states of both providers
    if (walletCategoriesAsync.isLoading || boostControllerStateAsync.isLoading) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 8.0),
        child: SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
      );
    }

    if (walletCategoriesAsync.hasError || boostControllerStateAsync.hasError) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Center(child: Text('Error loading boost data.')),
      );
    }

    final walletDataList = walletCategoriesAsync.value!;
    final boostState = boostControllerStateAsync.value!;

    // --- LOGIC TO CALCULATE MAX AMOUNT USING SEPARATE STATES ---
    final fromCategoryData = walletDataList.firstWhere(
      (data) => data.category.id == fromCategory.id,
      orElse: () => throw Exception('Could not find wallet data for category ${fromCategory.name}'),
    );

    final totalSpent = fromCategoryData.spentInCompletedDays + fromCategoryData.spendingToday;
    final availableToBoost = fromCategoryData.effectiveWeeklyBudget - totalSpent;

    // The current value on the slider comes from the temporary 'currentBoosts'
    final currentBoostAmount = boostState.currentBoosts[fromCategory.id] ?? 0.0;
    
    // The amount already committed from the DB comes from 'initialBoosts'
    final initialBoostAmount = boostState.initialBoosts[fromCategory.id] ?? 0.0;
    
    // The slider's max value is the available funds PLUS the initially committed boost.
    // This value is stable and does not change when the slider moves.
    final maxAmount = (availableToBoost < 0 ? 0 : availableToBoost) + initialBoostAmount;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: AmountSliderCard(
        category: fromCategory,
        maxAmount: maxAmount,
        currentAmount: currentBoostAmount,
        onChanged: (newAmount) {
          ref
              .read(boostStateProvider(toCategory).notifier)
              .updateAmount(fromCategory.id, newAmount);
        },
      ),
    );
  }
}