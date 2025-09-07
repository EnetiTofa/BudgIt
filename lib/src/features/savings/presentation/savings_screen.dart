import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/features/savings/domain/savings_goal.dart';
import 'package:budgit/src/features/savings/presentation/savings_providers.dart';
import 'package:budgit/src/features/savings/presentation/set_savings_goal_screen.dart';

class SavingsScreen extends ConsumerWidget {
  const SavingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // --- Total Savings Card ---
        Text('All-Time Savings', style: textTheme.headlineSmall),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ref.watch(totalSavingsProvider).when(
              data: (total) => Text(
                '\$${total.toStringAsFixed(2)}',
                style: textTheme.headlineMedium?.copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => const Text('Could not load savings.'),
            ),
          ),
        ),
        const SizedBox(height: 24),
        
        // --- Savings Goal Section ---
        Text('Savings Goal', style: textTheme.headlineSmall),
        const SizedBox(height: 8),
        ref.watch(savingsGoalProvider).when(
          data: (goal) {
            if (goal == null) {
              return Card(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const SetSavingsGoalScreen(),
                        ));
                      },
                      child: const Text('Set a Savings Goal'),
                    ),
                  ),
                ),
              );
            }
            // If a goal exists, show the progress card
            return _SavingsGoalProgressCard(goal: goal);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => const Text('Could not load savings goal.'),
        ),
      ],
    );
  }
}


// --- The new Progress Card Widget ---
class _SavingsGoalProgressCard extends ConsumerWidget {
  final SavingsGoal goal;
  const _SavingsGoalProgressCard({required this.goal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalSavings = ref.watch(totalSavingsProvider);
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: totalSavings.when(
          data: (currentAmount) {
            final progress = (goal.targetAmount > 0) ? (currentAmount / goal.targetAmount).clamp(0.0, 1.0) : 0.0;
            final amountToSave = goal.targetAmount - currentAmount;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Goal: \$${goal.targetAmount.toStringAsFixed(2)}', style: textTheme.titleMedium),
                    TextButton(
                      onPressed: () {
                         Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => SetSavingsGoalScreen(initialGoal: goal),
                        ));
                      },
                      child: const Text('Change'),
                    )
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(5),
                ),
                const SizedBox(height: 8),
                Text('\$${currentAmount.toStringAsFixed(2)} saved so far'),
                const Divider(height: 24),
                // Estimated completion display
                _EstimateDisplay(amountToSave: amountToSave > 0 ? amountToSave : 0),
              ],
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (e, s) => const SizedBox.shrink(),
        ),
      ),
    );
  }
}


// --- Helper widget for displaying the two time estimates ---
class _EstimateDisplay extends ConsumerWidget {
  final double amountToSave;
  const _EstimateDisplay({required this.amountToSave});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (amountToSave <= 0) {
      return const Center(child: Text('Goal Reached! 🎉', style: TextStyle(fontSize: 18, color: Colors.green, fontWeight: FontWeight.bold)));
    }

    final historicalAsync = ref.watch(averageWeeklySavingsProvider);
    final potentialAsync = ref.watch(potentialWeeklySavingsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Estimated Completion', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        historicalAsync.when(
          data: (avg) => _buildEstimateRow('At your current pace:', amountToSave, avg),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => const SizedBox.shrink(),
        ),
        const SizedBox(height: 12),
        potentialAsync.when(
          data: (pot) => _buildEstimateRow('If you meet your budget:', amountToSave, pot),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => const SizedBox.shrink(),
        ),
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
          weeksRemaining > 0 ? '~ $weeksRemaining weeks' : 'Calculating...',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}