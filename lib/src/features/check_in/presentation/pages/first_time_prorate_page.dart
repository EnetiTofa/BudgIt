import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/features/check_in/presentation/controllers/check_in_controller.dart';
import 'package:budgit/src/features/check_in/domain/check_in_state.dart';

class FirstTimeProratePage extends ConsumerWidget {
  const FirstTimeProratePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(checkInControllerProvider);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            Icon(
              Icons.auto_fix_high_rounded,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              "Handling the Past",
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              "Since you are starting BudgIt in the middle of a cycle, how would you like to handle the days that have already passed?",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.secondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // --- THIS WEEK SECTION ---
            Text(
              "This Week",
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildChoiceCard(
              context: context,
              title: "Log Manually (Recommended)", // MOVED HERE
              description: "Give me my full weekly budgets, and I will manually add past transactions to catch up.",
              icon: Icons.edit_note_rounded,
              isSelected: state.firstTimeWeekHandling == HistoricalHandling.logManually,
              onTap: () {
                ref.read(checkInControllerProvider.notifier).updateHistoricalHandling(
                  weekHandling: HistoricalHandling.logManually,
                );
              },
            ),
            const SizedBox(height: 8),
            _buildChoiceCard(
              context: context,
              title: "Auto-Prorate", // REMOVED FROM HERE
              description: "Reduce my starting weekly budgets to account for the days that have already passed.",
              icon: Icons.percent_rounded,
              isSelected: state.firstTimeWeekHandling == HistoricalHandling.prorate,
              onTap: () {
                ref.read(checkInControllerProvider.notifier).updateHistoricalHandling(
                  weekHandling: HistoricalHandling.prorate,
                );
              },
            ),

            const SizedBox(height: 32),

            // --- THIS MONTH SECTION ---
            Text(
              "This Month",
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildChoiceCard(
              context: context,
              title: "Auto-Prorate (Recommended)",
              description: "Reduce my starting monthly budgets to account for the days that have already passed.",
              icon: Icons.percent_rounded,
              isSelected: state.firstTimeMonthHandling == HistoricalHandling.prorate,
              onTap: () {
                ref.read(checkInControllerProvider.notifier).updateHistoricalHandling(
                  monthHandling: HistoricalHandling.prorate,
                );
              },
            ),
            const SizedBox(height: 8),
            _buildChoiceCard(
              context: context,
              title: "Log Manually",
              description: "Give me my full monthly budgets, and I will manually add past transactions to catch up.",
              icon: Icons.edit_note_rounded,
              isSelected: state.firstTimeMonthHandling == HistoricalHandling.logManually,
              onTap: () {
                ref.read(checkInControllerProvider.notifier).updateHistoricalHandling(
                  monthHandling: HistoricalHandling.logManually,
                );
              },
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primaryContainer.withOpacity(0.5) : theme.colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.secondary,
              size: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isSelected ? theme.colorScheme.onSurface : theme.colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline,
            ),
          ],
        ),
      ),
    );
  }
}