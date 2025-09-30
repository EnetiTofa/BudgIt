// lib/src/common_widgets/color_picker_field.dart

import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';

class ColorPickerField extends StatelessWidget {
  const ColorPickerField({
    super.key,
    this.selectedColor,
    required this.onColorSelected,
    this.labelText = 'Color',
  });

  final Color? selectedColor;
  final ValueChanged<Color> onColorSelected;
  final String labelText;

  Future<void> _showColorPicker(BuildContext context) async {
    // We can use the same flex_color_picker dialog you had before.
    final color = await showColorPickerDialog(
      context,
      selectedColor ?? Colors.blue,
      width: 40,
      height: 40,
      spacing: 5,
      runSpacing: 5,
      borderRadius: 4,
      wheelDiameter: 150,
      enableOpacity: false,
      showColorCode: true,
      colorCodeHasColor: true,
      pickersEnabled: const <ColorPickerType, bool>{
        ColorPickerType.both: false,
        ColorPickerType.primary: true,
        ColorPickerType.accent: false,
        ColorPickerType.bw: false,
        ColorPickerType.custom: false,
        ColorPickerType.wheel: true,
      },
    );
    onColorSelected(color);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _showColorPicker(context),
          borderRadius: BorderRadius.circular(12.0),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: selectedColor ?? Colors.transparent,
                  radius: 12,
                  // Add a border if no color is selected yet
                  child: selectedColor == null
                      ? Icon(Icons.color_lens_outlined,
                          size: 16, color: colorScheme.onSurfaceVariant)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Choose a color...',
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}