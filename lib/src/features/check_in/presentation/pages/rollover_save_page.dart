// lib/src/features/check_in/presentation/rollover_save_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/features/check_in/presentation/controllers/check_in_controller.dart';
import 'package:budgit/src/features/check_in/presentation/widgets/rollover_card.dart';
import 'package:budgit/src/core/data/providers/category_list_provider.dart';

class RolloverSavePage extends ConsumerWidget {
  const RolloverSavePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkInState = ref.watch(checkInControllerProvider);
    final categoriesAsync = ref.watch(categoryListProvider);
    final theme = Theme.of(context);

    // Calculate directly from the allocations, ignoring any global toggle
    final totalUnspent = checkInState.unspentFundsByCategory.values
        .fold(0.0, (sum, val) => sum + val);

    final totalToRollover = checkInState.rolloverAmounts.values
        .fold(0.0, (sum, val) => sum + val);

    final totalToSave = totalUnspent - totalToRollover;

    return categoriesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => const Center(child: Text('Could not load categories')),
      data: (categories) {
        
        // Empty State
        if (checkInState.unspentFundsByCategory.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.account_balance_wallet_outlined, size: 80, color: theme.colorScheme.secondary.withOpacity(0.5)),
                const SizedBox(height: 16),
                Text(
                  "No Surplus Funds",
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "You utilized your full budget this week. Let's look at your individual categories next.",
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.secondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        // Active State
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Rollover Unspent Funds',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Choose to save or rollover funds in categories with positive balances',
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // --- NEW HERO SUMMARY CARD ---
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    const Text(
                      "Adding to Savings",
                      style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${totalToSave.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold, height: 1.0),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.shade500.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '+\$${totalToRollover.toStringAsFixed(2)} rolling over',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),

              // Category Cards
              ...checkInState.unspentFundsByCategory.entries.map((entry) {
                final category = categories.firstWhere((c) => c.id == entry.key);
                return RolloverCard(category: category, unspentAmount: entry.value);
              }),
            ],
          ),
        );
      },
    );
  }
}