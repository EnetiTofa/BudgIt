import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/features/check_in/domain/check_in_state.dart';
import 'package:budgit/src/features/check_in/presentation/check_in_controller.dart';

class ConfirmationPage extends ConsumerWidget {
  const ConfirmationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkInState = ref.watch(checkInControllerProvider);
    final textTheme = Theme.of(context).textTheme;

    // --- View Logic to Calculate Totals ---
    double totalToSave = 0;
    double totalToRollover = 0;

    if (checkInState.decision == RolloverDecision.save) {
      totalToSave = checkInState.unspentFundsByCategory.values.fold(0.0, (sum, val) => sum + val);
    } else { // Rollover decision
      totalToRollover = checkInState.rolloverAmounts.values.fold(0.0, (sum, val) => sum + val);
      final totalUnspent = checkInState.unspentFundsByCategory.values.fold(0.0, (sum, val) => sum + val);
      totalToSave = totalUnspent - totalToRollover;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Confirm Your Check-in', style: textTheme.headlineSmall, textAlign: TextAlign.center),
            const SizedBox(height: 32),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _SummaryRow(
                      label: 'Amount to Save:',
                      amount: totalToSave,
                      color: Colors.green,
                    ),
                    const Divider(height: 24),
                    _SummaryRow(
                      label: 'Amount to Rollover:',
                      amount: totalToRollover,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.amount, this.color});
  final String label;
  final double amount;
  final Color? color;
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}