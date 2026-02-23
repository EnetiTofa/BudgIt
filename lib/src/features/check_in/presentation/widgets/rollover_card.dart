// lib/src/features/check_in/presentation/widgets/rollover_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/core/domain/models/category.dart';
import 'package:budgit/src/features/check_in/presentation/controllers/check_in_controller.dart';
import 'package:budgit/src/features/budget_hub/wallet/presentation/widgets/amount_slider_field.dart';

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
    final state = ref.watch(checkInControllerProvider);
    final theme = Theme.of(context);
    
    // Get the currently selected rollover amount (defaults to 0.0)
    final rolloverAmount = state.rolloverAmounts[category.id] ?? 0.0;
    
    // Whatever isn't rolled over is automatically saved
    final saveAmount = unspentAmount - rolloverAmount;

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- HEADER ---
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Color(category.colorValue),
                  child: Icon(
                    IconData(category.iconCodePoint, fontFamily: 'MaterialIcons'),
                    color: category.contentColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(category.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(
                        'Unspent: \$${unspentAmount.toStringAsFixed(2)}',
                        style: TextStyle(color: theme.colorScheme.secondary, fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // --- LABELS ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Saving: \$${saveAmount.toStringAsFixed(2)}',
                  style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Rolling Over: \$${rolloverAmount.toStringAsFixed(2)}',
                  style: TextStyle(color: theme.colorScheme.secondary, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            
            const SizedBox(height: 8),

            // --- SLIDER ---
            AmountSliderField(
              value: rolloverAmount,
              maxAvailable: unspentAmount,
              activeColor: Color(category.colorValue),
              onChanged: (val) {
                // This talks directly to the controller method we already set up!
                ref.read(checkInControllerProvider.notifier).updateRolloverAmount(category.id, val);
              },
            ),
          ],
        ),
      ),
    );
  }
}