// lib/src/features/check_in/presentation/rollover_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/features/check_in/domain/check_in_state.dart';
import 'package:budgit/src/features/check_in/presentation/check_in_controller.dart';
import 'package:budgit/src/features/categories/domain/category.dart';
// --- MODIFICATION: Import the new reusable card ---
import 'package:budgit/src/common_widgets/amount_slider_card.dart';

class RolloverCard extends ConsumerWidget {
  final Category category;
  final double unspentAmount;

  const RolloverCard({
    super.key,
    required this.category,
    required this.unspentAmount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkInState = ref.watch(checkInControllerProvider);
    final controller = ref.read(checkInControllerProvider.notifier);
    
    // Only show the card if the decision is to 'Rollover'
    if (checkInState.decision != RolloverDecision.rollover) {
      // Return an empty container if not visible to avoid taking up space
      return const SizedBox.shrink();
    }

    // Determine the current amount to show in the slider
    final currentRolloverAmount = checkInState.rolloverAmounts[category.id] ?? 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: AmountSliderCard(
        category: category,
        maxAmount: unspentAmount,
        currentAmount: currentRolloverAmount,
        onChanged: (newAmount) {
          controller.updateRolloverAmount(category.id, newAmount);
        },
      ),
    );
  }
}