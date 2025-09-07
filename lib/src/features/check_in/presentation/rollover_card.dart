import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/common_widgets/currency_input_field.dart';
import 'package:budgit/src/features/check_in/domain/check_in_state.dart';
import 'package:budgit/src/features/check_in/presentation/check_in_controller.dart';
import 'package:budgit/src/features/categories/domain/category.dart';

// Change to a simple ConsumerWidget
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
    
    final showSlider = checkInState.decision == RolloverDecision.rollover;
    // Get the value directly from the provider in the build method
    final rolloverAmount = checkInState.rolloverAmounts[category.id] ?? unspentAmount;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(backgroundColor: category.color, child: Icon(category.icon, color: Colors.white)),
                const SizedBox(width: 12),
                Expanded(child: Text(category.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                Text('\$${unspentAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            if (showSlider) ...[
              const Divider(height: 24),
              Row(
                children: [
                  const Text('Save'),
                  Expanded(
                    child: Slider(
                      value: rolloverAmount,
                      min: 0,
                      max: unspentAmount,
                      divisions: unspentAmount > 0 ? (unspentAmount * 100).toInt() : null,
                      label: rolloverAmount.toStringAsFixed(2),
                      onChanged: (value) {
                        controller.updateRolloverAmount(category.id, value);
                      },
                    ),
                  ),
                  const Text('Rollover'),
                ],
              ),
              SizedBox(
                width: 150,
                child: CurrencyInputField(
                  initialValue: rolloverAmount,
                  onChanged: (value) {
                    controller.updateRolloverAmount(category.id, value);
                  },
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}