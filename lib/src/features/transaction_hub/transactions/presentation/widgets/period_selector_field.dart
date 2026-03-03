import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:budgit/src/core/domain/models/transaction.dart';

class PeriodSelectorField extends StatefulWidget {
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
  State<PeriodSelectorField> createState() => _PeriodSelectorFieldState();
}

class _PeriodSelectorFieldState extends State<PeriodSelectorField> {
  late final TextEditingController _frequencyController;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _frequencyController = TextEditingController(
      text: widget.frequency.toString(),
    );
    _focusNode = FocusNode();

    // Listen for when the user clicks away from the text field
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        // If they left the field completely empty, default it back to 1
        if (_frequencyController.text.trim().isEmpty) {
          _frequencyController.text = '1';
          widget.onFrequencyChanged(1);
        } else {
          // If they left a valid number, ensure it stays as the widget frequency
          final parsed = int.tryParse(_frequencyController.text) ?? 1;
          _frequencyController.text = parsed.toString();
        }
      }
    });
  }

  @override
  void didUpdateWidget(covariant PeriodSelectorField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update the controller if the parent forcibly changed the frequency
    // AND the user isn't currently typing in the box.
    if (oldWidget.frequency != widget.frequency && !_focusNode.hasFocus) {
      if (_frequencyController.text != widget.frequency.toString()) {
        _frequencyController.text = widget.frequency.toString();
      }
    }
  }

  @override
  void dispose() {
    _frequencyController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.labelText,
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
                  controller: _frequencyController,
                  focusNode: _focusNode,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  keyboardType: TextInputType.number,
                  minLines: null,
                  maxLines: null,
                  textAlignVertical: TextAlignVertical.center,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      widget.onFrequencyChanged(int.tryParse(value) ?? 1);
                    }
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: colorScheme.surfaceContainerLowest,
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(
                        color: theme.colorScheme.primary,
                        width: 2.0,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(
                        color: colorScheme.outline,
                        width: 1.0,
                      ),
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
                    value: widget.period,
                    onChanged: (value) {
                      if (value != null) {
                        widget.onPeriodChanged(value);
                      }
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: colorScheme.surfaceContainerLowest,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(
                          color: theme.colorScheme.primary,
                          width: 2.0,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(
                          color: colorScheme.outline,
                          width: 1.0,
                        ),
                      ),
                    ),
                    items: RecurrencePeriod.values
                        .map(
                          (p) => DropdownMenuItem(
                            value: p,
                            child: Text(
                              // Capitalize the first letter
                              p.name[0].toUpperCase() + p.name.substring(1),
                            ),
                          ),
                        )
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
