import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/features/budget_hub/wallet/domain/wallet_category_data.dart';
import 'package:budgit/src/features/budget_hub/wallet/domain/wallet_adjustment.dart';
import 'package:budgit/src/core/data/providers/category_list_provider.dart';
import 'package:budgit/src/core/domain/models/category.dart';
// Widgets
import 'package:budgit/src/features/budget_hub/wallet/presentation/widgets/spending_speedometer.dart';
import 'package:budgit/src/features/budget_hub/wallet/presentation/widgets/segmented_linear_gauge.dart';
import 'package:budgit/src/features/budget_hub/wallet/presentation/widgets/weekly_pattern_chart.dart';
// Providers
import 'package:budgit/src/features/budget_hub/wallet/presentation/controllers/boost_controller.dart';
// Screens
import 'package:budgit/src/features/budget_hub/wallet/presentation/screens/add_boost_screen.dart';
import 'package:budgit/src/features/budget_hub/wallet/presentation/screens/edit_boost_screen.dart';

class WalletCategoryDetailScreen extends ConsumerWidget {
  final WalletCategoryData data;

  const WalletCategoryDetailScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final catColor = Color(data.category.colorValue);

    return Scaffold(
      appBar: AppBar(
        title: Text(data.category.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Metrics
            SpendingSpeedometer(
              currentSpeed: data.currentSpeed,
              recommendedSpeed: data.recommendedSpeed,
              color: catColor,
            ),
            const SizedBox(height: 32),

            SegmentedLinearGauge(
              totalBudget: data.effectiveWeeklyBudget,
              spent: data.totalSpentThisWeek,
              color: catColor,
              daysInPeriod: 7,
            ),
            const SizedBox(height: 32),

            WeeklyPatternChart(
              currentPattern: data.currentWeekPattern,
              averagePattern: data.averageWeekPattern,
              color: catColor,
            ),
            const SizedBox(height: 40),

            // 2. Active Boosts Section
            Text("Active Boosts", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            ref.watch(boostStateProvider(data.category)).when(
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const SizedBox.shrink(),
              data: (state) {
                final boostsMap = state.initialBoosts;
                
                if (boostsMap.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: Text(
                      "No active boosts.", 
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)
                    ),
                  );
                }

                return Column(
                  children: boostsMap.entries.map((entry) {
                    final fromCategoryId = entry.key;
                    final amount = entry.value;

                    // --- ADDED: Dismissible Wrapper ---
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Dismissible(
                        key: Key('boost_$fromCategoryId'), // Unique key for this boost
                        direction: DismissDirection.endToStart,
                        background: Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.error,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20.0),
                          child: Icon(Icons.delete, color: theme.colorScheme.onError),
                        ),
                        confirmDismiss: (direction) async {
                          return await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Delete Boost?"),
                                content: const Text("Are you sure you want to remove this boost? Funds will return to the source category."),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: const Text("Cancel"),
                                  ),
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      foregroundColor: theme.colorScheme.error,
                                    ),
                                    onPressed: () => Navigator.of(context).pop(true),
                                    child: const Text("Delete"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        onDismissed: (direction) {
                          // Logic to delete the boost
                          final controller = ref.read(boostStateProvider(data.category).notifier);
                          
                          // Setting amount to 0 removes it
                          controller.updateAmount(fromCategoryId, 0.0);
                          controller.confirmBoosts();
                        },
                        child: _ExistingBoostCard(
                          fromCategoryId: fromCategoryId,
                          amount: amount,
                          targetCategory: data.category,
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => EditBoostScreen(
                              targetCategory: data.category,
                              boost: WalletAdjustment(
                                id: 'temp_edit', 
                                fromCategoryId: fromCategoryId,
                                toCategoryId: data.category.id,
                                amount: amount,
                                date: DateTime.now(),
                              ),
                            )));
                          },
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 16),
            
            // Add Boost Button
            OutlinedButton.icon(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => AddBoostScreen(
                  targetCategory: data.category
                )));
              },
              icon: const Icon(Icons.add_circle_outline),
              label: const Text("Add Boost"),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExistingBoostCard extends ConsumerWidget {
  final String fromCategoryId;
  final double amount;
  final Category targetCategory;
  final VoidCallback onTap;

  const _ExistingBoostCard({
    required this.fromCategoryId,
    required this.amount,
    required this.targetCategory,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoryListProvider).valueOrNull ?? [];
    
    // Resolve Source Category
    final source = categories.firstWhere(
      (c) => c.id == fromCategoryId, 
      orElse: () => Category(
        id: 'unknown', 
        name: 'Unknown', 
        iconCodePoint: Icons.help_outline.codePoint, 
        colorValue: Colors.grey.value, 
        budgetAmount: 0
      )
    );

    final sourceColor = Color(source.colorValue);
    final contentColor = source.contentColor; // Helper from category.dart
    final theme = Theme.of(context);

    // Styled Card
    return Container(
      decoration: BoxDecoration(
        color: sourceColor, // Solid Background
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ]
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        dense: true,
        leading: Icon(
          IconData(source.iconCodePoint, fontFamily: 'MaterialIcons'), 
          color: contentColor,
          size: 24,
        ),
        title: Text(
          "From ${source.name}",
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: contentColor,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
             Text(
               "+\$${amount.toStringAsFixed(0)}", 
               style: theme.textTheme.titleMedium?.copyWith(
                 fontWeight: FontWeight.bold, 
                 color: contentColor
               ),
             ),
             const SizedBox(width: 8),
             Icon(Icons.edit, size: 16, color: contentColor.withOpacity(0.7)),
          ],
        ),
      ),
    );
  }
}