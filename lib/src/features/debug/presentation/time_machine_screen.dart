import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:budgit/src/utils/clock_provider.dart';

class TimeMachineScreen extends ConsumerWidget {
  const TimeMachineScreen({super.key});

  Future<void> _selectDateTime(BuildContext context, WidgetRef ref, DateTime initialDate) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2040),
    );
    if (date == null || !context.mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );
    if (time == null) return;

    final newDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    ref.read(clockNotifierProvider.notifier).setTime(newDateTime);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The state of the provider *is* the Clock object itself.
    final clock = ref.watch(clockNotifierProvider);
    final currentTime = clock.now();
    // Access the public `forcedTime` property directly from the clock object.
    final forcedTime = clock.forcedTime;

    final timeFormatter = DateFormat.yMMMEd().add_jms();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Time Machine'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text('Current App Time', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            timeFormatter.format(currentTime),
            style: theme.textTheme.headlineSmall?.copyWith(
              color: forcedTime != null ? theme.colorScheme.primary : null,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            forcedTime != null ? 'Time is currently frozen.' : 'Using real device time.',
            style: theme.textTheme.bodySmall,
          ),
          const Divider(height: 32),
          FilledButton.icon(
            onPressed: () => _selectDateTime(context, ref, currentTime),
            icon: const Icon(Icons.edit_calendar),
            label: const Text('Set Date & Time'),
          ),
          const SizedBox(height: 16),
          const Text('Advance Time By:'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: OutlinedButton(onPressed: () => ref.read(clockNotifierProvider.notifier).advanceTime(const Duration(hours: 1)), child: const Text('+1 Hour'))),
              const SizedBox(width: 8),
              Expanded(child: OutlinedButton(onPressed: () => ref.read(clockNotifierProvider.notifier).advanceTime(const Duration(days: 1)), child: const Text('+1 Day'))),
              const SizedBox(width: 8),
              Expanded(child: OutlinedButton(onPressed: () => ref.read(clockNotifierProvider.notifier).advanceTime(const Duration(days: 7)), child: const Text('+7 Days'))),
            ],
          ),
          const Divider(height: 32),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              onPressed: forcedTime != null ? () => ref.read(clockNotifierProvider.notifier).reset() : null,
              icon: const Icon(Icons.replay_circle_filled_outlined),
              label: const Text('Reset to Real Time'),
            ),
          ),
        ],
      ),
    );
  }
}