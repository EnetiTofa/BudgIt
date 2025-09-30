// lib/src/common_widgets/custom_dropdown_field.dart

import 'package:flutter/material.dart';

class CustomDropdownField<T> extends StatelessWidget {
  final String labelText;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const CustomDropdownField({
    super.key,
    required this.labelText,
    this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      // Add this to allow the dropdown's content to fill the space.
      isExpanded: true, 
      decoration: InputDecoration(
        labelText: labelText,
        // Add this to make the field more compact.
        isDense: true, 
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}