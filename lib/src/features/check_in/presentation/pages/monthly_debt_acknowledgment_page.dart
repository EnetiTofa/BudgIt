import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/features/check_in/presentation/controllers/check_in_controller.dart';
import 'package:budgit/src/core/data/providers/category_list_provider.dart';

class MonthlyDebtAcknowledgmentPage extends ConsumerWidget {
  const MonthlyDebtAcknowledgmentPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(checkInControllerProvider);
    final categoriesAsync = ref.watch(categoryListProvider);

    final overspent = state.overspentFundsByCategory;
    final totalDebt = overspent.values.fold(0.0, (sum, amount) => sum + amount);

    // Safety fallback in case the page is lingering in the routing tree
    if (totalDebt <= 0) {
      return Center(
        child: Text(
          "You finished the month completely in the green!",
          style: theme.textTheme.titleLarge,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          CircleAvatar(
            radius: 40,
            backgroundColor: theme.colorScheme.errorContainer.withOpacity(0.5),
            child: Icon(
              Icons.warning_amber_rounded,
              size: 48,
              color: theme.colorScheme.error,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Over Budget",
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            "Unfortunately, you ended the month in the negative for a few categories.",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.secondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Total Debt Display
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Text(
                  "Total Overspent",
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "-\$${totalDebt.toStringAsFixed(2)}",
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Breakdown List
          Expanded(
            child: categoriesAsync.when(
              data: (categories) {
                final overspentCategories = categories
                    .where((c) => overspent.containsKey(c.id))
                    .toList();

                return ListView.builder(
                  itemCount: overspentCategories.length,
                  itemBuilder: (context, index) {
                    final cat = overspentCategories[index];
                    final amount = overspent[cat.id]!;

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        IconData(
                          cat.iconCodePoint,
                          fontFamily: 'MaterialIcons',
                        ),
                        color: Color(cat.colorValue),
                      ),
                      title: Text(
                        cat.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: Text(
                        "-\$${amount.toStringAsFixed(2)}",
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),

          const SizedBox(height: 16),
          // Empathetic Acknowledgment Text
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: theme.colorScheme.secondary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Since it's the end of the month, this simply reduces your total calculated savings. Next month is a fresh start!",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
