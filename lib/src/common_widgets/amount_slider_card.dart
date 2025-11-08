// lib/src/common_widgets/amount_slider_card.dart
import 'package:flutter/material.dart';
import 'package:budgit/src/common_widgets/currency_input_field.dart';
import 'package:budgit/src/core/domain/models/category.dart';
import 'package:flutter/services.dart';

class AmountSliderCard extends StatelessWidget {
  final Category category;
  final double maxAmount;
  final double currentAmount;
  final ValueChanged<double> onChanged;

  const AmountSliderCard({
    super.key,
    required this.category,
    required this.maxAmount,
    required this.currentAmount,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // --- NEW COLORS ---
    final cardColor = theme.colorScheme.surfaceContainerLowest;
    final accentColor = category.color; // The category color is now the accent
    final sliderInactiveColor = accentColor.withOpacity(0.3);

    return Card(
      elevation: 0,
      // --- MODIFICATION: Use the neutral background color ---
      color: cardColor,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // --- MODIFICATION: Icon uses the category's color ---
                    Icon(category.icon, color: accentColor, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      category.name,
                      style: TextStyle(
                        // --- MODIFICATION: Text uses the primary theme color ---
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                // --- MODIFICATION: Use the default CurrencyInputField style ---
                CurrencyInputField(
                  width: 95,
                  height: 50,
                  key: ValueKey(currentAmount),
                  initialValue: currentAmount,
                  onChanged: onChanged,
                  // The 'style' and 'backgroundColor' props are removed to use the default.
                  textStyle: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            Slider(
              value: currentAmount.clamp(0.0, maxAmount),
              min: 0,
              max: maxAmount > 0 ? maxAmount : 1,
              // --- MODIFICATION: Slider uses the category color ---
              activeColor: accentColor,
              inactiveColor: sliderInactiveColor,
              onChanged: maxAmount > 0 ? onChanged : null,
            ),
          ],
        ),
      ),
    );
  }
}