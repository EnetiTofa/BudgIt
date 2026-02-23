// lib/src/features/check_in/presentation/debt_rollover_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/features/check_in/presentation/controllers/check_in_controller.dart';
import 'package:budgit/src/core/data/providers/category_list_provider.dart';
import 'package:budgit/src/core/domain/models/category.dart';

class DebtRolloverPage extends ConsumerWidget {
  const DebtRolloverPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkInState = ref.watch(checkInControllerProvider);
    final categoriesAsync = ref.watch(categoryListProvider);
    final theme = Theme.of(context);

    return categoriesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => const Center(child: Text('Could not load categories')),
      data: (categories) {
        
        // Empty State: No Debt!
        if (checkInState.overspentFundsByCategory.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.celebration_outlined, size: 80, color: Colors.green.shade400),
                const SizedBox(height: 16),
                Text(
                  "No Overspending!",
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "Great job! You stayed within your limits for all categories this week.",
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.secondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        // Active State: Manage Debt
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Debt Management',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              
              Text(
                'Choose to absorb the debt now, or reduce next week\'s wallet.',
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.secondary),
                textAlign: TextAlign.center,
              ),
              
              // Streak saving tip
              Container(
                margin: const EdgeInsets.only(top: 16, bottom: 24),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: Colors.orange.shade500),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Tip: Rolling over your debt keeps your streak alive!",
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary),
                      ),
                    ),
                  ],
                ),
              ),

              // Debt Category Cards
              ...checkInState.overspentFundsByCategory.entries.map((entry) {
                final category = categories.firstWhere((c) => c.id == entry.key);
                final debtStreak = checkInState.debtStreaks[category.id] ?? 0;
                final isRollingOver = checkInState.rollingOverDebtCategoryIds.contains(category.id);

                return _DebtRolloverCard(
                  category: category,
                  overspentAmount: entry.value,
                  debtStreak: debtStreak,
                  isRollingOver: isRollingOver,
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _DebtRolloverCard extends ConsumerWidget {
  final Category category;
  final double overspentAmount;
  final int debtStreak;
  final bool isRollingOver;

  const _DebtRolloverCard({
    required this.category,
    required this.overspentAmount,
    required this.debtStreak,
    required this.isRollingOver,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isMaxDebt = debtStreak >= 4;

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      color: isRollingOver
          ? Colors.green.withOpacity(0.15)
          : theme.colorScheme.errorContainer.withOpacity(0.3),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Color(category.colorValue),
                  child: Icon(IconData(category.iconCodePoint, fontFamily: 'MaterialIcons'),
                      color: category.contentColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(category.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(
                        isRollingOver
                            ? 'Debt reduces next week\'s wallet'
                            : 'Overspent by \$${overspentAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: isRollingOver ? Colors.green.shade400 : theme.colorScheme.error,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Week ${debtStreak + 1}/4",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isMaxDebt ? theme.colorScheme.error : theme.colorScheme.secondary,
                  ),
                ),
                if (isMaxDebt)
                  Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error, size: 16),
                      const SizedBox(width: 4),
                      Text("Max Limit Hit", style: TextStyle(color: theme.colorScheme.error, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  )
                else
                  Row(
                    children: [
                      Text(
                        "Rollover Entire Debt",
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Checkbox(
                        value: isRollingOver,
                        onChanged: (_) {
                          ref.read(checkInControllerProvider.notifier).toggleDebtRollover(category.id);
                        },
                      )
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}