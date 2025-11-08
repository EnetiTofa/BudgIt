import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:budgit/src/core/domain/models/transaction.dart'; // Assuming RecurrencePeriod is here

class PeriodSelectorField extends StatelessWidget {
  const PeriodSelectorField({
    super.key,
    required this.frequency,
    required this.period,
    required this.onFrequencyChanged,
    required this.onPeriodChanged,
    this.labelText = 'Repeats',
  });

  final int frequency;
  final RecurrencePeriod period;
  final ValueChanged<int> onFrequencyChanged;
  final ValueChanged<RecurrencePeriod> onPeriodChanged;
  final String labelText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final frequencyController = TextEditingController(text: frequency.toString());
    // Move cursor to the end of the text
    frequencyController.selection = TextSelection.fromPosition(
      TextPosition(offset: frequencyController.text.length),
    );


    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 55,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 55,
                child: TextFormField(
                  controller: frequencyController,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  keyboardType: TextInputType.number,
                  expands: true,
                  minLines: null,
                  maxLines: null,
                  textAlignVertical: TextAlignVertical.center,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (value) {
                    onFrequencyChanged(int.tryParse(value) ?? 1);
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: colorScheme.surfaceContainerLowest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(
                        color: Colors.red, // Set your desired static color here
                        width: 1.0,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: colorScheme.outline, width: 1.0),
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Period Dropdown Box
              Expanded(
                child: SizedBox(
                  child: DropdownButtonFormField<RecurrencePeriod>(
                    value: period,
                    onChanged: (value) {
                      if (value != null) {
                        onPeriodChanged(value);
                      }
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: colorScheme.surfaceContainerLowest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(
                          color: Colors.red, // Set your desired static color here
                          width: 1.0,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(color: colorScheme.outline, width: 1.0),
                      ),
                    ),
                    items: RecurrencePeriod.values
                        .map((p) => DropdownMenuItem(
                              value: p,
                              child: Text(
                                // Capitalize the first letter
                                p.name[0].toUpperCase() + p.name.substring(1),
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}