// lib/src/features/savings/presentation/savings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:budgit/src/features/savings/presentation/savings_providers.dart';
import 'package:budgit/src/features/savings/presentation/widgets/savings_timeline.dart';
import 'package:budgit/src/features/savings/presentation/widgets/savings_goal_gauge.dart';
import 'package:budgit/src/features/savings/presentation/set_savings_goal_screen.dart';
// --- MODIFICATION START ---
// Import the reusable summary card widget
import 'package:budgit/src/common_widgets/summary_stat_card.dart';
// --- MODIFICATION END ---


class SavingsScreen extends ConsumerWidget {
  const SavingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(savingsScreenSelectedMonthProvider);
    final screenDataAsync = ref.watch(savingsScreenDataProvider);
    
    final goalAsync = ref.watch(savingsGoalProvider);
    final gaugeDataAsync = ref.watch(savingsGaugeDataProvider);

    return screenDataAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error loading data: $e')),
      data: (screenData) {
        final monthKey = DateFormat('yyyy-MM').format(selectedMonth);
        final details = screenData.monthlyDetailsMap[monthKey] ?? MonthlySavingsDetails();

        return ListView(
          // Removed the horizontal padding from here to give the card full width
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          children: [
            goalAsync.when(
              data: (goal) {
                if (goal == null) {
                  return Card(
                    color: Theme.of(context).colorScheme.surface,
                    elevation: 0,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SizedBox(
                          width: 220, // diameter of the circle
                          height: 220,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.only(top: 12), // inner spacing
                            ),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const SetSavingsGoalScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Set Savings \nGoal',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 26),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }
                // If a goal exists, show the gauge and an edit button
                return gaugeDataAsync.when(
                  data: (gaugeData) => Column(
                    children: [
                      SizedBox(
                        width: 300, // Set your desired width
                        height: 300, // Set your desired height
                        child: SavingsGoalGauge(data: gaugeData),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => SetSavingsGoalScreen(initialGoal: goal),
                          ));
                        },
                        child: const Text('Edit Goal'),
                      ),
                    ],
                  ),
                  loading: () => const Center(heightFactor: 8, child: CircularProgressIndicator()),
                  error: (e,s) => const Center(child: Text('Could not load gauge data.')),
                );
              },
              loading: () => const Center(heightFactor: 8, child: CircularProgressIndicator()),
              error: (e,s) => const Center(child: Text('Could not load savings goal.')),
            ),
            SavingsTimeline(
              savingsData: screenData.historicalSavings,
              selectedMonth: selectedMonth,
              onMonthSelected: (newMonth) {
                ref.read(savingsScreenSelectedMonthProvider.notifier).state = newMonth;
              },
            ),
            // --- MODIFICATION START ---
            // Replace the old Row of cards with the new SummaryStatCard
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SummaryStatCard(
                stats: [
                  SummaryStat(
                    value: '\$${details.income.toStringAsFixed(2)}',
                    unit: 'NZD',
                    title: 'Total Income',
                    description: 'All income received in ${DateFormat.yMMMM().format(selectedMonth)}.',
                  ),
                  SummaryStat(
                    value: '\$${details.spending.toStringAsFixed(2)}',
                    unit: 'NZD',
                    title: 'Total Spending',
                    description: 'All expenses paid in ${DateFormat.yMMMM().format(selectedMonth)}.',
                  ),
                   SummaryStat(
                    value: '\$${details.savings.toStringAsFixed(2)}',
                    unit: 'NZD',
                    title: 'Net Savings',
                    description: 'Your net total (Income - Spending) for the month.',
                  ),
                ],
              ),
            ),
            // --- MODIFICATION END ---
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }
}