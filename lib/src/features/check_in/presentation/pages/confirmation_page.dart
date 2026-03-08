// lib/src/features/check_in/presentation/confirmation_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/features/check_in/presentation/controllers/check_in_controller.dart';
import 'package:budgit/src/core/data/providers/category_list_provider.dart';

class ConfirmationPage extends ConsumerWidget {
  const ConfirmationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkInState = ref.watch(checkInControllerProvider);
    final categoriesAsync = ref.watch(categoryListProvider);
    final theme = Theme.of(context);

    // --- Calculate Totals ---
    final totalUnspent = checkInState.unspentFundsByCategory.values.fold(
      0.0,
      (sum, val) => sum + val,
    );
    final totalToRollover = checkInState.rolloverAmounts.values.fold(
      0.0,
      (sum, val) => sum + val,
    );
    final totalToSave = totalUnspent - totalToRollover;

    // --- Calculate Debt ---
    double totalDebtRollover = 0;
    for (final id in checkInState.rollingOverDebtCategoryIds) {
      totalDebtRollover += (checkInState.overspentFundsByCategory[id] ?? 0.0);
    }

    // --- Filter Manual Boosts ---
    final manualBoosts = checkInState.checkInWeekTransfers
        .where((b) => b.fromCategoryId != 'rollover')
        .toList();

    return categoriesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => const Center(child: Text("Error loading summary")),
      data: (categories) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Review & Confirm',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Here is the summary of your week. Press complete to finalize these actions.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.secondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // --- 1. SAVINGS & POSITIVE ROLLOVER SUMMARY ---
              Text(
                "Positive Balances",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                color: theme.colorScheme.surfaceContainerLow,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 20.0,
                    horizontal: 8.0,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _SummaryStat(
                          label: 'To Save',
                          amount: totalToSave,
                          color: const Color.fromARGB(255, 72, 171, 98),
                          icon: Icons.savings_outlined,
                        ),
                      ),
                      SizedBox(
                        height: 50,
                        child: VerticalDivider(
                          color: theme.dividerColor.withOpacity(0.5),
                          width: 16,
                        ),
                      ),
                      Expanded(
                        child: _SummaryStat(
                          label: 'To Rollover',
                          amount: totalToRollover,
                          color: theme.colorScheme.primary,
                          icon: Icons.next_week_outlined,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // --- 2. DEBT ROLLOVER SUMMARY ---
              if (checkInState.rollingOverDebtCategoryIds.isNotEmpty) ...[
                Text(
                  "Debt Rollover",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  color: Colors.orange.withOpacity(0.1),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.orange.shade800,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Total Debt Forward: \$${totalDebtRollover.toStringAsFixed(2)}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade900,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...checkInState.rollingOverDebtCategoryIds.map((id) {
                          final category = categories.firstWhere(
                            (c) => c.id == id,
                          );
                          final amount =
                              checkInState.overspentFundsByCategory[id] ?? 0.0;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "• ${category.name}",
                                  style: TextStyle(
                                    color: Colors.orange.shade900,
                                  ),
                                ),
                                Text(
                                  "-\$${amount.toStringAsFixed(2)}",
                                  style: TextStyle(
                                    color: Colors.orange.shade900,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // --- 3. INTERNAL BOOSTS SUMMARY ---
              if (manualBoosts.isNotEmpty) ...[
                Text(
                  "Internal Transfers",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  color: theme.colorScheme.surfaceContainerLowest,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: theme.colorScheme.surfaceContainerHighest,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: manualBoosts.map((boost) {
                        final sourceCat = categories.firstWhere(
                          (c) => c.id == boost.fromCategoryId,
                          orElse: () => categories.first,
                        );
                        final targetCat = categories.firstWhere(
                          (c) => c.id == boost.toCategoryId,
                          orElse: () => categories.first,
                        );

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.compare_arrows_rounded,
                                size: 16,
                                color: theme.colorScheme.secondary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "${sourceCat.name} → ${targetCat.name}",
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                              Text(
                                "\$${boost.amount.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });
  final String label;
  final double amount;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
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
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.secondary,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
