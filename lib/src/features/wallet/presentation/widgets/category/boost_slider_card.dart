import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:budgit/src/common_widgets/currency_input_field.dart';
import 'package:budgit/src/features/categories/domain/category.dart';
import 'package:budgit/src/features/wallet/presentation/controllers/boost_controller.dart';


class BoostSliderCard extends ConsumerStatefulWidget {
  final Category fromCategory;
  final Category toCategory;
  // --- NEW: Add maxAmount as a required parameter ---
  final double maxAmount;

  const BoostSliderCard({
    super.key,
    required this.fromCategory,
    required this.toCategory,
    // --- NEW: Initialize the parameter ---
    required this.maxAmount,
  });

  @override
  ConsumerState<BoostSliderCard> createState() => _BoostSliderCardState();
}

class _BoostSliderCardState extends ConsumerState<BoostSliderCard> {
  void _onAmountChanged(double newAmount) {
    final maxAmount = widget.fromCategory.walletAmount ?? 0;
    final clampedAmount = newAmount.clamp(0.0, maxAmount);

    ref
        .read(boostStateProvider(widget.toCategory).notifier)
        .updateAmount(widget.fromCategory.id, clampedAmount);
  }

  @override
  Widget build(BuildContext context) {
    final boostState = ref.watch(boostStateProvider(widget.toCategory));
    final currentBoostAmount = boostState.value?[widget.fromCategory.id] ?? 0.0;
    final maxAmount = widget.maxAmount;

    final categoryColor =
        widget.fromCategory.color;
    final brightness = ThemeData.estimateBrightnessForColor(categoryColor);
    final contentColor = brightness == Brightness.dark
        ? Colors.white
        : const Color(0xFF121212).withAlpha(200);

    final sliderActiveColor = Theme.of(context).colorScheme.primary;
    final sliderInactiveColor =
        Theme.of(context).colorScheme.surface.withAlpha(100);

    return Card(
      elevation: 0,
      color: categoryColor,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(widget.fromCategory.icon,
                        color: contentColor, size: 32),
                    const SizedBox(width: 12),
                    Text(
                      widget.fromCategory.name,
                      style: TextStyle(
                        color: contentColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
                CurrencyInputField(
                  width: 95,
                  key: ValueKey(currentBoostAmount),
                  initialValue: currentBoostAmount,
                  onChanged: _onAmountChanged,
                  style: CurrencyInputFieldStyle.borderless,
                  textStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  // --- MODIFIED: Explicitly set the background color ---
                  backgroundColor: Theme.of(context).colorScheme.surface.withAlpha(150),
                ),
              ],
            ),
            Slider(
              value: currentBoostAmount.clamp(0.0, maxAmount),
              min: 0,
              max: maxAmount > 0 ? maxAmount : 1,
              activeColor: sliderActiveColor,
              inactiveColor: sliderInactiveColor,
              onChanged: maxAmount > 0 ? _onAmountChanged : null,
            ),
          ],
        ),
      ),
    );
  }
}