import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/common_widgets/currency_input_field.dart';
import 'package:budgit/src/features/categories/domain/category.dart';
import 'package:budgit/src/features/wallet/presentation/controllers/boost_controller.dart';

class BoostSliderCard extends ConsumerWidget {
  final Category fromCategory;
  final Category toCategory; // <-- Add this parameter

  const BoostSliderCard({
    super.key,
    required this.fromCategory,
    required this.toCategory, // <-- Add this parameter
  });

  void _onAmountChanged(WidgetRef ref, double newAmount) {
    final maxAmount = fromCategory.walletAmount ?? 0;
    final clampedAmount = newAmount.clamp(0.0, maxAmount);

    // Pass the toCategory to the provider's notifier
    ref.read(boostStateProvider(toCategory).notifier)
       .updateAmount(fromCategory.id, clampedAmount);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Pass the toCategory to the provider to watch the correct instance
    final boostMap = ref.watch(boostStateProvider(toCategory));
    
    // The build method now correctly handles the async state of the provider
    return boostMap.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (data) {
        final currentBoostAmount = data[fromCategory.id] ?? 0.0;
        final maxAmount = fromCategory.walletAmount ?? 0;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(fromCategory.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('\$0'),
                    Expanded(
                      child: Slider(
                        value: currentBoostAmount,
                        min: 0,
                        max: maxAmount,
                        divisions: maxAmount > 0 ? (maxAmount * 4).toInt() : null,
                        label: currentBoostAmount.toStringAsFixed(2),
                        onChanged: (value) => _onAmountChanged(ref, value),
                      ),
                    ),
                    Text('\$${maxAmount.toStringAsFixed(2)}'),
                  ],
                ),
                SizedBox(
                  width: 150,
                  child: CurrencyInputField(
                    initialValue: currentBoostAmount,
                    onChanged: (value) => _onAmountChanged(ref, value),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}