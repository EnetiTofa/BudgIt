import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum DateSelectorLayout { horizontal, vertical }

class DateSelectorField extends StatelessWidget {
  const DateSelectorField({
    super.key,
    required this.labelText,
    this.selectedDate,
    required this.onDateSelected,
    this.icon = Icons.calendar_today,
    this.layout = DateSelectorLayout.horizontal,
    this.allowFutureDates = false,
    this.minDate,
    this.maxDate,
    this.onOpenPicker, // <-- ADDED: Hook to fire right before opening
  });

  final String labelText;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final IconData icon;
  final DateSelectorLayout layout;
  final bool allowFutureDates;
  final DateTime? minDate;
  final DateTime? maxDate;
  final VoidCallback? onOpenPicker; // <-- ADDED

  Future<void> _pickDate(BuildContext context) async {
    // 1. Tell the parent to close the dropdown immediately
    onOpenPicker?.call();

    // 2. WAIT for the dropdown overlay to vanish before showing the calendar
    await Future.delayed(const Duration(milliseconds: 150));

    // 3. Calculate constraints
    final first = minDate ?? DateTime(2000);
    final last =
        maxDate ?? (allowFutureDates ? DateTime(2101) : DateTime.now());

    DateTime initial = selectedDate ?? DateTime.now();
    if (initial.isBefore(first)) initial = first;
    if (initial.isAfter(last)) initial = last;

    // 4. Open the picker
    if (!context.mounted) return; // Safety check after the delay
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
    );

    if (picked != null && picked != selectedDate) {
      onDateSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
          border: Border.all(color: colorScheme.outline, width: 1.0),
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
          padding: const EdgeInsets.only(left: 28.0),
          child: Text(
            selectedDate == null
                ? 'Select...'
                : DateFormat.yMMMd().format(selectedDate!),
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.secondary,
            ),
          ),
        ),
      ],
    );
  }
}
