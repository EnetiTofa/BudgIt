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

    // --- View Logic to Calculate Totals (remains the same) ---
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
            Text(
              'Confirm Your Check-in',
              style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // --- MODIFICATION: The summary card layout is now a Row ---
            Card(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: _SummaryStat(
                        label: 'Amount to Save',
                        amount: totalToSave,
                        color: Colors.greenAccent,
                      ),
                    ),
                    SizedBox(
                      height: 50,
                      child: VerticalDivider(
                        color: Theme.of(context).dividerColor.withOpacity(0.5),
                        width: 16,
                      ),
                    ),
                    Expanded(
                      child: _SummaryStat(
                        label: 'Amount to Rollover',
                        amount: totalToRollover,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // --- END MODIFICATION ---
          ],
        ),
      ),
    );
  }
}

// --- MODIFICATION: Replaced _SummaryRow with the vertical _SummaryStat widget ---
class _SummaryStat extends StatelessWidget {
  const _SummaryStat({required this.label, required this.amount, this.color});
  final String label;
  final double amount;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.secondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}