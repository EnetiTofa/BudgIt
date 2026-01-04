import 'package:flutter/material.dart';
import 'package:budgit/src/common_widgets/currency_input_field.dart';

class AmountSliderField extends StatelessWidget {
  final double value;
  final double maxAvailable;
  final ValueChanged<double> onChanged;
  final Color? activeColor;

  const AmountSliderField({
    super.key,
    required this.value,
    required this.maxAvailable,
    required this.onChanged,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    // Ensure value is within bounds for display
    final displayValue = value.clamp(0.0, maxAvailable > 0 ? maxAvailable : 0.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. The Currency Field
        CurrencyInputField(
          initialValue: displayValue,
          onChanged: (val) {
             // Allow typing up to max
             final clamped = val.clamp(0.0, maxAvailable);
             onChanged(clamped);
          },
          height: 50,
          // Optional: You can pass a label or style here
          style: CurrencyInputFieldStyle.outlined, 
          // Assuming your CurrencyInputField supports a controller or key updates,
          // otherwise it might not update when slider moves. 
          // Key helps force rebuild if the input field doesn't expose a controller setter.
          key: ValueKey("currency_field_$value"), 
        ),
        
        const SizedBox(height: 8),

        // 2. The Slider
        Row(
          children: [
            Text("\$0", style: Theme.of(context).textTheme.bodySmall),
            Expanded(
              child: Slider(
                value: displayValue,
                min: 0.0,
                max: maxAvailable > 0 ? maxAvailable : 1.0, // Prevent 0.0 max error
                activeColor: activeColor,
                onChanged: maxAvailable > 0 ? onChanged : null,
              ),
            ),
            Text(
              "\$${maxAvailable.toStringAsFixed(0)}", 
              style: Theme.of(context).textTheme.bodySmall
            ),
          ],
        ),
      ],
    );
  }
}