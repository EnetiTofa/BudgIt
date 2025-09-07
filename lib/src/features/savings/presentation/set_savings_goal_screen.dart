import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/common_widgets/currency_input_field.dart';
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

  @override
  void initState() {
    super.initState();
    _targetAmount = widget.initialGoal?.targetAmount ?? 0.0;
  }

  void _onConfirm() {
    if (_targetAmount > 0) {
      // V-- Replace the TODO with this line
      ref.read(addTransactionControllerProvider.notifier).setSavingsGoal(_targetAmount);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialGoal == null ? 'Set Savings Goal' : 'Change Savings Goal'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CurrencyInputField(
              labelText: 'Goal Amount',
              initialValue: _targetAmount,
              onChanged: (value) {
                // We use setState to trigger a rebuild and update the estimate display
                setState(() {
                  _targetAmount = value;
                });
              },
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            _EstimateDisplay(targetAmount: _targetAmount), // The new display widget
            const Spacer(),
            ElevatedButton(
              onPressed: _onConfirm,
              child: const Text('Confirm Goal'),
            ),
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