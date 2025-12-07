// lib/src/features/budgets/presentation/screens/budgets_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:budgit/src/common_widgets/pulsing_button.dart';
import 'package:budgit/src/features/categories/presentation/screens/add_category_screen.dart';
import 'package:budgit/src/features/budget_hub/budgets/presentation/providers/budget_screen_data_provider.dart';
import 'package:budgit/src/features/budget_hub/budgets/presentation/providers/category_gauge_data_provider.dart';
import 'package:budgit/src/features/budget_hub/budgets/presentation/providers/monthly_summary_provider.dart';
import 'package:budgit/src/features/budget_hub/budgets/presentation/widgets/budget_list.dart';
import 'package:budgit/src/features/budget_hub/budgets/presentation/widgets/month_selector.dart';
import 'package:budgit/src/features/budget_hub/budgets/presentation/widgets/category_detail_view.dart';
import 'package:budgit/src/features/budget_hub/budgets/presentation/widgets/unified_budget_gauge.dart';
import 'package:budgit/src/common_widgets/summary_stat_card.dart';
import 'package:budgit/src/core/domain/models/category.dart';
import 'package:budgit/src/features/categories/presentation/screens/manage_category_screen.dart';

final selectedMonthProvider = StateProvider<DateTime?>((ref) => null);
final selectedCategoryProvider = StateProvider<Category?>((ref) => null);

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetDataAsync = ref.watch(budgetScreenDataProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return budgetDataAsync.when(
      skipLoadingOnReload: true,
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (screenData) {
        final selectedMonth = ref.watch(selectedMonthProvider) ??
            (screenData.historicalSpending.isNotEmpty
                ? screenData.historicalSpending.last.date
                : DateTime.now());
        
        return WillPopScope(
          onWillPop: () async {
            if (selectedCategory != null) {
              ref.read(selectedCategoryProvider.notifier).state = null;
              return false;
            }
            return true;
          },
          child: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        MonthSelector(
                          selectedDate: selectedMonth,
                          onMonthChanged: (newMonth) {
                            // --- MODIFICATION START: Limit to current month ---
                            final now = DateTime.now();
                            final currentMonth = DateTime(now.year, now.month);
                            
                            // Prevent navigating to future months
                            if (newMonth.isAfter(currentMonth)) return;
                            
                            ref.read(selectedMonthProvider.notifier).state = newMonth;
                            // --- MODIFICATION END ---
                          },
                        ),
                        if (selectedCategory != null)
                          Positioned(
                            right: 0,
                            child: IconButton(
                              iconSize: 28,
                              icon: Icon(
                                Icons.tune, 
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => ManageCategoryScreen(
                                      category: selectedCategory
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),

                  SizedBox(
                    height: 300, 
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      switchInCurve: Curves.easeInOut,
                      switchOutCurve: Curves.easeInOut,
                      layoutBuilder: (currentChild, previousChildren) {
                        return Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            ...previousChildren,
                            if (currentChild != null) currentChild,
                          ],
                        );
                      },
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                      child: selectedCategory == null
                          ? Align(
                              alignment: Alignment.topCenter,
                              child: _buildGlobalGauge(context, screenData, selectedMonth),
                            )
                          : Align(
                              alignment: Alignment.topCenter,
                              child: _CategoryGaugeWrapper(
                                key: ValueKey('CatGauge_${selectedCategory.id}'),
                                category: selectedCategory,
                                month: selectedMonth,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 4), 

                  if (screenData.budgetProgress.isEmpty)
                     Padding(
                       padding: const EdgeInsets.all(24.0),
                       child: PulsingButton(
                        label: 'Add Category',
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const AddCategoryScreen()),
                          );
                        },
                      ),
                     )
                  else
                    BudgetList(
                      progressList: screenData.budgetProgress,
                      selectedCategory: selectedCategory,
                      onCategoryTap: (category) {
                        ref.read(selectedCategoryProvider.notifier).state = category;
                      },
                    ),

                  const SizedBox(height: 4),

                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    switchInCurve: Curves.easeInOut,
                    switchOutCurve: Curves.easeInOut,
                    layoutBuilder: (currentChild, previousChildren) {
                      return Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          ...previousChildren,
                          if (currentChild != null) currentChild,
                        ],
                      );
                    },
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                    child: selectedCategory == null
                        ? _buildSummaryCard(context, screenData.summaryDetails)
                        : CategoryDetailView(
                            key: ValueKey('Detail_${selectedCategory.id}'),
                            categoryId: selectedCategory.id,
                            selectedMonth: selectedMonth,
                          ),
                  ),
                  
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGlobalGauge(
      BuildContext context, BudgetScreenData screenData, DateTime selectedDate) {
    final totalSpent = screenData.budgetProgress
        .fold(0.0, (sum, item) => sum + item.amountSpent);
    final totalBudget = screenData.budgetProgress
        .fold(0.0, (sum, item) => sum + item.projectedBudget);
        
    final now = DateTime.now();
    final bool isThisMonth =
        selectedDate.year == now.year && selectedDate.month == now.month;
    final String monthLabel = isThisMonth
        ? "Spent this Month"
        : "Spent ${DateFormat.MMM().format(selectedDate)}";

    final segments = screenData.budgetProgress.map((p) => GaugeSegment(
      label: p.category.name,
      amount: p.amountSpent,
      color: p.category.color,
    )).toList();

    return Padding(
      key: const ValueKey('GlobalGauge'),
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: UnifiedBudgetGauge(
        segments: segments,
        totalBudget: totalBudget,
        totalSpent: totalSpent,
        labelSuffix: monthLabel,
        showLegend: false, 
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, BudgetSummaryDetails summary) {
    return Padding(
      key: const ValueKey('SummaryCard'),
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
    );
  }
}

class _CategoryGaugeWrapper extends ConsumerWidget {
  final Category category;
  final DateTime month;

  const _CategoryGaugeWrapper({required this.category, required this.month, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gaugeData = ref.watch(categoryGaugeDataProvider(
      category: category,
      month: month,
    ));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: UnifiedBudgetGauge(
        segments: gaugeData.segments,
        totalBudget: gaugeData.totalBudget,
        totalSpent: gaugeData.totalSpent,
        labelSuffix: "of \$${gaugeData.totalBudget.toStringAsFixed(0)} Budget",
        showLegend: true, 
      ),
    );
  }
}