// lib/src/features/budget_hub/presentation/widgets/week_selector.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:budgit/src/features/settings/data/settings_provider.dart';
import 'package:budgit/src/utils/clock_provider.dart';

class WeekSelector extends ConsumerWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;

  const WeekSelector({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    return settingsAsync.when(
      loading: () => const SizedBox(height: 48),
      error: (_, __) => const SizedBox(height: 48),
      data: (settings) {
        final checkInDay = settings.getCheckInDay();
        final now = ref.read(clockNotifierProvider).now();

        // Calculate the start and end of the currently selected week
        final startOfSelectedWeek = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day - (selectedDate.weekday - checkInDay + 7) % 7,
        );
        final endOfSelectedWeek = startOfSelectedWeek.add(
          const Duration(days: 6),
        );

        // Calculate the start of the current real-world week to prevent navigating to the future
        final startOfCurrentWeek = DateTime(
          now.year,
          now.month,
          now.day - (now.weekday - checkInDay + 7) % 7,
        );

        final canGoNext = startOfSelectedWeek.isBefore(startOfCurrentWeek);

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left_rounded),
              onPressed: () => onDateChanged(
                startOfSelectedWeek.subtract(const Duration(days: 7)),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${DateFormat('d MMM').format(startOfSelectedWeek)} - ${DateFormat('d MMM y').format(endOfSelectedWeek)}',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(
                Icons.chevron_right_rounded,
                color: canGoNext
                    ? null
                    : Theme.of(context).disabledColor.withOpacity(0.3),
              ),
              onPressed: canGoNext
                  ? () => onDateChanged(
                      startOfSelectedWeek.add(const Duration(days: 7)),
                    )
                  : null,
            ),
          ],
        );
      },
    );
  }
}
