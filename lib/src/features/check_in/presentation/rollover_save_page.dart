import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/common_widgets/custom_toggle.dart';
import 'package:budgit/src/features/check_in/domain/check_in_state.dart';
import 'package:budgit/src/features/check_in/presentation/check_in_controller.dart';
import 'package:budgit/src/features/check_in/presentation/rollover_card.dart';
import 'package:budgit/src/core/data/providers/category_list_provider.dart';

class RolloverSavePage extends ConsumerWidget {
  const RolloverSavePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkInState = ref.watch(checkInControllerProvider);
    final categoriesAsync = ref.watch(categoryListProvider);

    final totalUnspent = checkInState.unspentFundsByCategory.values
        .fold(0.0, (sum, val) => sum + val);
        
    final totalToRollover = checkInState.decision == RolloverDecision.save
        ? 0.0
        : checkInState.rolloverAmounts.values
            .fold(0.0, (sum, val) => sum + val);
            
    final totalToSave = totalUnspent - totalToRollover;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          CustomToggle(
            options: const ['Save', 'Rollover'],
            selectedValue:
                checkInState.decision == RolloverDecision.save ? 'Save' : 'Rollover',
            onChanged: (value) {
              final newDecision =
                  value == 'Save' ? RolloverDecision.save : RolloverDecision.rollover;
              ref
                  .read(checkInControllerProvider.notifier)
                  .makeDecision(newDecision);
            },
          ),
          const SizedBox(height: 24),

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
                    height: 50, // Give the divider a specific height
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

          const SizedBox(height: 16),
          categoriesAsync.when(
            data: (categories) => Column(
              children: checkInState.unspentFundsByCategory.entries.map((entry) {
                final category = categories.firstWhere((c) => c.id == entry.key);
                return RolloverCard(
                    category: category, unspentAmount: entry.value);
              }).toList(),
            ),
            loading: () => const SizedBox.shrink(),
            error: (e, s) => const Text('Could not load categories'),
          ),
        ],
      ),
    );
  }
}

// --- MODIFICATION: New private widget for a vertical stat display ---
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