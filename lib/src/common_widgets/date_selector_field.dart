import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// An enum to define the available layout styles for the widget
enum DateSelectorLayout { horizontal, vertical }

class DateSelectorField extends StatelessWidget {
  const DateSelectorField({
    super.key,
    required this.labelText,
    this.selectedDate,
    required this.onDateSelected,
    this.icon = Icons.calendar_today,
    this.layout = DateSelectorLayout.horizontal, // Default to the original layout
  });

  final String labelText;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final IconData icon;
  final DateSelectorLayout layout; // Parameter to control the layout

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      onDateSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Build the widget's content based on the chosen layout
    final Widget content = (layout == DateSelectorLayout.vertical)
        ? _buildVerticalLayout(context)
        : _buildHorizontalLayout(context);

    return InkWell(
      onTap: () => _pickDate(context),
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        height: (layout == DateSelectorLayout.vertical) ? null : 75.0,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          border: Border.all(
            color: colorScheme.outline, // Sets the border color
            width: 1.0,                 // Sets the border thickness
          ),
          color: colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12.0),
        ),
      child: content,
      ),
    );
  }

  Widget _buildHorizontalLayout(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Row(
      children: [
        Icon(icon, size: 20, color: colorScheme.primary),
        const SizedBox(width: 12),
        Text(
          labelText,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Expanded(child: SizedBox(width: 16)),
        Text(
          selectedDate == null
              ? 'Select...'
              : DateFormat.yMd().format(selectedDate!),
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.secondary,
          ),
        ),
      ],
    );
  }

  // The new vertical layout
  Widget _buildVerticalLayout(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              labelText,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Padding(
          padding: const EdgeInsets.only(left: 28.0), // Indent the date text
          child: Text(
            selectedDate == null
                ? 'Select...'
                : DateFormat.yMMMd().format(selectedDate!),
            style: theme.textTheme.bodySmall?.copyWith( // Use smaller text
              color: colorScheme.secondary,
            ),
          ),
        ),
      ],
    );
  }
}