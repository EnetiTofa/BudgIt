// lib/src/features/savings/presentation/set_savings_goal_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/common_widgets/currency_input_field.dart';
import 'package:budgit/src/common_widgets/date_selector_field.dart';
import 'package:budgit/src/features/savings/domain/savings_goal.dart';
import 'package:budgit/src/features/savings/presentation/savings_providers.dart';
import 'package:budgit/src/features/transactions/presentation/controllers/add_transaction_controller.dart';

class SetSavingsGoalScreen extends ConsumerStatefulWidget {
  final SavingsGoal? initialGoal;
  const SetSavingsGoalScreen({super.key, this.initialGoal});

  @override
  ConsumerState<SetSavingsGoalScreen> createState() => _SetSavingsGoalScreenState();
}

class _SetSavingsGoalScreenState extends ConsumerState<SetSavingsGoalScreen> {
  double _targetAmount = 0.0;
  late DateTime _startDate;

  @override
  void initState() {
    super.initState();
    _targetAmount = widget.initialGoal?.targetAmount ?? 0.0;
    _startDate = widget.initialGoal?.createdAt ?? DateTime.now();
  }

  void _onConfirm() {
    if (_targetAmount > 0) {
      ref.read(addTransactionControllerProvider.notifier)
         .setSavingsGoal(_targetAmount, startDate: _startDate);
      Navigator.of(context).pop();
    }
  }

  // --- NEW METHOD to handle deletion ---
  void _onDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Savings Goal?'),
        content: const Text('Are you sure you want to delete this goal? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(addTransactionControllerProvider.notifier).deleteSavingsGoal();
      // Pop twice to go back to the main savings screen
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialGoal == null ? 'Set Savings Goal' : 'Edit Savings Goal'),
        // --- MODIFICATION START ---
        actions: [
          // Only show the delete button if we are editing an existing goal
          if (widget.initialGoal != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _onDelete,
            ),
        ],
        // --- MODIFICATION END ---
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CurrencyInputField(
              labelText: 'Goal Amount',
              initialValue: _targetAmount,
              onChanged: (value) {
                setState(() {
                  _targetAmount = value;
                });
              },
            ),
            const SizedBox(height: 16),
            DateSelectorField(
              labelText: 'Start Date',
              selectedDate: _startDate,
              onDateSelected: (newDate) {
                setState(() {
                  _startDate = newDate;
                });
              },
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            _EstimateDisplay(targetAmount: _targetAmount),
            const Spacer(),
            FilledButton(
              onPressed: _onConfirm,
              child: const Text('Confirm Goal'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _EstimateDisplay extends ConsumerWidget {
  final double targetAmount;
  const _EstimateDisplay({required this.targetAmount});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historicalAsync = ref.watch(averageWeeklySavingsProvider);
    final potentialAsync = ref.watch(potentialWeeklySavingsProvider);
    final totalSavingsAsync = ref.watch(totalSavingsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Estimated Completion', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        totalSavingsAsync.when(
          data: (totalSavings) {
            final amountToSave = targetAmount - totalSavings;
            if (amountToSave <= 0) {
              return const Text('Goal reached!');
            }
            return Column(
              children: [
                historicalAsync.when(
                  data: (avg) => _buildEstimateRow('At your current pace:', amountToSave, avg),
                  loading: () => const CircularProgressIndicator(),
                  error: (e, s) => const Text('Could not calculate pace.'),
                ),
                const SizedBox(height: 12),
                potentialAsync.when(
                  data: (pot) => _buildEstimateRow('If you meet your budget:', amountToSave, pot),
                  loading: () => const CircularProgressIndicator(),
                  error: (e, s) => const Text('Could not calculate potential.'),
                ),
              ],
            );
          },
          loading: () => const CircularProgressIndicator(),
          error: (e, s) => const Text('Could not load total savings.'),
        )
      ],
    );
  }

  Widget _buildEstimateRow(String label, double amountToSave, double weeklyRate) {
    final weeksRemaining = weeklyRate > 0 ? (amountToSave / weeklyRate).ceil() : 0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          weeksRemaining > 0 ? '~ $weeksRemaining weeks' : '-',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}