// lib/src/common_widgets/icon_picker_field.dart

import 'package:flutter/material.dart';
import 'package:budgit/src/constants/app_icons.dart'; // Import your app icons

class IconPickerField extends StatelessWidget {
  const IconPickerField({
    super.key,
    this.selectedIcon,
    required this.onIconSelected,
    this.labelText = 'Icon',
  });

  final IconData? selectedIcon;
  final ValueChanged<IconData> onIconSelected;
  final String labelText;

  // REMOVED: The old hardcoded list is no longer needed.

  void _showIconPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
        ),
        // UPDATED: Use the icon list from AppIcons
        itemCount: AppIcons.categoryIcons.length,
        itemBuilder: (context, index) {
          final icon = AppIcons.categoryIcons[index];
          return InkWell(
            borderRadius: BorderRadius.circular(50),
            onTap: () {
              onIconSelected(icon);
              Navigator.of(context).pop();
            },
            child: Icon(icon, size: 30, color: Theme.of(context).colorScheme.primary),
          );
        },
      ),
    );
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
          onTap: () => _showIconPicker(context),
          borderRadius: BorderRadius.circular(12.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Row(
              children: [
                if (selectedIcon != null) ...[
                  Icon(selectedIcon, color: colorScheme.onSurfaceVariant),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    selectedIcon != null ? 'Icon Selected' : 'Choose an icon...',
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