// lib/src/features/budgets/presentation/screens/budgets_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// --- MODIFICATION START ---
import 'package:budgit/src/common_widgets/pulsing_button.dart';
import 'package:budgit/src/features/categories/presentation/screens/add_category_screen.dart';
// --- MODIFICATION END ---
import 'package:budgit/src/features/budgets/presentation/providers/budget_screen_data_provider.dart';
import 'package:budgit/src/features/budgets/presentation/widgets/budget_gauge.dart';
import 'package:budgit/src/features/budgets/presentation/widgets/budget_list.dart';
import 'package:budgit/src/features/budgets/presentation/widgets/budget_timeline.dart';
import 'package:budgit/src/common_widgets/summary_stat_card.dart';
import 'package:budgit/src/features/budgets/presentation/screens/category_drilldown_screen.dart';

final selectedMonthProvider = StateProvider<DateTime?>((ref) => null);

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetDataAsync = ref.watch(budgetScreenDataProvider);

    return budgetDataAsync.when(
      skipLoadingOnReload: true,
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (screenData) {
        final selectedMonth = ref.watch(selectedMonthProvider) ??
            (screenData.historicalSpending.isNotEmpty
                ? screenData.historicalSpending.last.date
                : DateTime.now());
        
        return _buildOverview(context, ref, screenData, selectedMonth);
      },
    );
  }

  Widget _buildOverview(BuildContext context, WidgetRef ref, BudgetScreenData screenData, DateTime selectedMonth) {
    final summary = screenData.summaryDetails;

    // --- MODIFICATION START ---
    // If there are no categories with budgets, show the prompt to add one.
    if (screenData.budgetProgress.isEmpty) {
      return Center(
        child: PulsingButton(
          label: 'Add Category',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AddCategoryScreen()),
            );
          },
        ),
      );
    }
    // --- MODIFICATION END ---
    
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(62.0, 0.0, 62.0, 0.0),
            child: BudgetGauge(
              progressList: screenData.budgetProgress,
              selectedDate: selectedMonth,
            ),
          ),
          const SizedBox(height: 0),
          BudgetTimeline(
            spendingData: screenData.historicalSpending,
            selectedMonth: selectedMonth,
            onMonthSelected: (newMonth) {
              ref.read(selectedMonthProvider.notifier).state = newMonth;
            },
          ),
          const SizedBox(height: 12),
          BudgetList(
            progressList: screenData.budgetProgress,
            onCategoryTap: (tappedCategory) {
              final allCategories = screenData.budgetProgress.map((p) => p.category).toList();
              final initialIndex = allCategories.indexWhere((c) => c.id == tappedCategory.id);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => CategoryDrilldownScreen(
                    categories: allCategories,
                    initialIndex: initialIndex,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SummaryStatCard(
              stats: [
                SummaryStat(
                  value: '\$${summary.totalSpending.toStringAsFixed(2)}',
                  unit: 'NZD',
                  title: 'Total Spending',
                  description: 'The total amount spent in the selected month.',
                ),
                 SummaryStat(
                  value: '\$${summary.dailyAverage.toStringAsFixed(2)}',
                  unit: 'NZD / day',
                  title: 'Daily Average',
                  description: 'Your average spending per day for this month.',
                ),
                 SummaryStat(
                  value: summary.monthsCounted.toString(),
                  unit: 'Months',
                  title: 'Months Counted',
                  description: 'The total number of months with transaction data.',
                ),
                SummaryStat(
                  value: summary.highestMonth,
                  unit: 'Month',
                  title: 'Highest Month',
                  description: 'The month where you spent the most amount.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}