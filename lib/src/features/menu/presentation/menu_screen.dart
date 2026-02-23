// lib/src/features/menu/presentation/menu_screen.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/features/categories/presentation/screens/manage_categories_screen.dart';
import 'package:budgit/src/features/check_in/presentation/screens/check_in_screen.dart';
import 'package:budgit/src/features/check_in/presentation/providers/is_check_in_available_provider.dart';
import 'package:budgit/src/features/settings/data/settings_provider.dart';
import 'package:budgit/src/features/settings/presentation/theme_selector_screen.dart';
import 'package:budgit/src/features/transaction_hub/transactions/presentation/controllers/add_transaction_controller.dart';
import 'package:budgit/src/features/check_in/presentation/providers/streak_provider.dart';
import 'package:budgit/src/features/check_in/presentation/providers/app_bar_info_provider.dart';
import 'package:budgit/src/features/debug/presentation/time_machine_screen.dart';
// Note: Ensure this path matches your project structure for CheckInController
import 'package:budgit/src/features/check_in/presentation/controllers/check_in_controller.dart'; 

class MenuScreen extends ConsumerWidget {
  const MenuScreen({super.key});

  Future<bool> _showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String content,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: title.toLowerCase().contains('delete')
                  ? Theme.of(context).colorScheme.error
                  : null,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  // --- NEW: Inline Undo Logic ---
  Future<void> _handleUndoCheckIn(BuildContext context, WidgetRef ref) async {
    final theme = Theme.of(context);
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text('Undo Check-In?'),
          ],
        ),
        content: const Text(
          'This will safely reverse your most recent check-in, reverting your savings, rollovers, and streak to exactly how they were before you confirmed it.\n\nAre you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel', style: TextStyle(color: theme.colorScheme.secondary)),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.orange.shade700),
            child: const Text('Yes, Undo'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reversing check-in...')),
      );
    }

    final success = await ref.read(checkInControllerProvider.notifier).undoLastCheckIn();

    if (context.mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Check-in successfully undone!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No recent check-in found to undo.'),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final headerStyle = theme.textTheme.titleLarge?.copyWith(
      color: theme.colorScheme.primary,
      fontWeight: FontWeight.bold,
    );
    final isCheckInAvailableAsync = ref.watch(isCheckInAvailableProvider);

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
          child: Text('Management', style: headerStyle),
        ),
        isCheckInAvailableAsync.when(
          data: (available) => available
              ? ListTile(
                  leading: const Icon(Icons.checklist_rtl_outlined),
                  title: const Text('Weekly Check-in'),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CheckInScreen())),
                )
              : const SizedBox.shrink(),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => const SizedBox.shrink(),
        ),
        
        // --- MODIFICATION: Standardized Undo Tile ---
        ListTile(
          leading: const Icon(Icons.undo_rounded),
          title: const Text('Undo Last Check-in'),
          onTap: () => _handleUndoCheckIn(context, ref),
        ),

        ListTile(
          leading: const Icon(Icons.calendar_month_outlined),
          title: const Text('Set Check-in Day'),
          onTap: () => _showCheckInDayPicker(context, ref),
        ),
        ListTile(
          leading: const Icon(Icons.category_outlined),
          title: const Text('Manage Categories'),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ManageCategoriesScreen())),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
          child: Text('Settings', style: headerStyle),
        ),
        ListTile(
          leading: const Icon(Icons.dashboard_customize_outlined),
          title: const Text('Customize Dashboard'),
          subtitle: const Text('Coming soon!'),
          onTap: () { /* Placeholder */ },
        ),
        ListTile(
          leading: const Icon(Icons.wallet_outlined),
          title: const Text('Customize Wallet Screen'),
          subtitle: const Text('Coming soon!'),
          onTap: () { /* Placeholder */ },
        ),
        ListTile(
          leading: const Icon(Icons.brightness_6_outlined),
          title: const Text('Theme Settings'),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ThemeSelectorScreen())),
        ),
        if (kDebugMode) ...[
          const Divider(),
          ListTile(
            leading: const Icon(Icons.timelapse_rounded, color: Colors.purpleAccent),
            title: const Text('DEBUG: Time Machine'),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TimeMachineScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.history_toggle_off, color: Colors.orange),
            title: const Text('DEBUG: Reset Check-in History'),
            onTap: () {
              ref.read(addTransactionControllerProvider.notifier).debugClearCheckInHistory();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Check-in history cleared.')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.auto_awesome, color: Colors.orange),
            title: const Text('DEBUG: Generate Dummy Data'),
            onTap: () async {
              final confirmed = await _showConfirmationDialog(
                context,
                title: 'Generate Data?',
                content: 'This will generate a large number of transactions for the past year based on your current budgets. Are you sure?',
              );
              if (confirmed && context.mounted) {
                await ref.read(addTransactionControllerProvider.notifier).generateDummyData();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Dummy data generated.')),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('DEBUG: Delete All Transactions'),
            onTap: () async {
              final confirmed = await _showConfirmationDialog(
                context,
                title: 'Delete All Transactions?',
                content: 'This will permanently delete all transaction and adjustment data. This action cannot be undone.',
              );
              if (confirmed && context.mounted) {
                await ref.read(addTransactionControllerProvider.notifier).deleteAllData();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All transactions deleted.')),
                );
              }
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.bug_report, color: Colors.orange),
            title: const Text('DEBUG: Reset Check-in'),
            onTap: () async { 
              await ref.read(addTransactionControllerProvider.notifier).debugResetCheckInData();
              ref.invalidate(isCheckInAvailableProvider);
            },
          ),
          ListTile(
            leading: const Icon(Icons.replay, color: Colors.orange),
            title: const Text('DEBUG: Reset Streak'),
            onTap: () {
              ref.read(addTransactionControllerProvider.notifier).debugResetStreak();
              ref.invalidate(checkInStreakProvider);
              ref.invalidate(appBarInfoProvider);
               ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Streak has been reset.')),
              );
            },
          ),
        ],
      ],
    );
  }

  Future<void> _showCheckInDayPicker(BuildContext context, WidgetRef ref) async {
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final currentDay = await settingsNotifier.getCheckInDay();

    final daysOfWeek = {
      'Monday': 1, 'Tuesday': 2, 'Wednesday': 3, 'Thursday': 4,
      'Friday': 5, 'Saturday': 6, 'Sunday': 7,
    };

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        int selectedDay = currentDay;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Select Check-in Day'),
              content: DropdownButton<int>(
                value: selectedDay,
                isExpanded: true,
                items: daysOfWeek.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.value,
                    child: Text(entry.key),
                  );
                }).toList(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedDay = newValue;
                    });
                  }
                },
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                FilledButton(
                  child: const Text('Save'),
                  onPressed: () {
                    settingsNotifier.setCheckInDay(selectedDay);
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          },
        );
      },
    );
  }
}