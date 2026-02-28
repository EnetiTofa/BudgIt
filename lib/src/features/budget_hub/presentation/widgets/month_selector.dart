// lib/src/features/budget_hub/budgets/presentation/widgets/month_selector.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthSelector extends StatelessWidget {
  const MonthSelector({
    super.key,
    required this.selectedDate,
    required this.onMonthChanged,
  });

  final DateTime selectedDate;
  final ValueChanged<DateTime> onMonthChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            onMonthChanged(DateTime(selectedDate.year, selectedDate.month - 1));
          },
        ),
        const SizedBox(width: 8),
        Text(
          DateFormat('MMMM yyyy').format(selectedDate),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () {
            onMonthChanged(DateTime(selectedDate.year, selectedDate.month + 1));
          },
        ),
      ],
    );
  }
}