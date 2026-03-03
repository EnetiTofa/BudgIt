// lib/src/features/budget_hub/presentation/screens/weekly_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';

import 'package:budgit/src/core/domain/models/category.dart';
import 'package:budgit/src/common_widgets/pulsing_button.dart';
import 'package:budgit/src/features/categories/presentation/screens/add_category_screen.dart';
import 'package:budgit/src/features/categories/presentation/screens/manage_category_screen.dart';
import 'package:budgit/src/features/budget_hub/presentation/widgets/weekly_category_detail_view.dart';
import 'package:budgit/src/features/budget_hub/presentation/widgets/weekly_bar_chart.dart';
import 'package:budgit/src/features/budget_hub/presentation/widgets/budget_list.dart';
import 'package:budgit/src/features/budget_hub/domain/budget_progress.dart';
import 'package:budgit/src/features/budget_hub/domain/weekly_category_data.dart';
import 'package:budgit/src/features/settings/data/settings_provider.dart';
import 'package:budgit/src/features/budget_hub/presentation/providers/weekly_projection_providers.dart';
import 'package:budgit/src/features/categories/presentation/screens/edit_basic_category_screen.dart';
import 'package:budgit/src/features/budget_hub/presentation/widgets/spending_speedometer.dart';
import 'package:budgit/src/common_widgets/summary_card_base.dart';
import 'package:budgit/src/features/budget_hub/presentation/widgets/recent_transactions_list.dart';
import 'package:budgit/src/utils/clock_provider.dart';

// --- FIXED: Imported WeekSelector instead of MonthSelector ---
import 'package:budgit/src/features/budget_hub/presentation/widgets/week_selector.dart';

final checkInDayProvider = FutureProvider<int>((ref) async {
  final settingsRepo = await ref.watch(settingsProvider.future);
  return settingsRepo.getCheckInDay();
});

final selectedWeeklyCategoryProvider = StateProvider<Category?>((ref) => null);

class WeeklyScreen extends ConsumerWidget {
  const WeeklyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(weeklyDateProvider);
    final selectedCategory = ref.watch(selectedWeeklyCategoryProvider);

    final weeklyCategoryDataAsync = ref.watch(
      weeklyCategoryDataProvider(selectedDate: selectedDate),
    );

    return weeklyCategoryDataAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (data) {
        if (data.isEmpty) {
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

        final selectedCategoryData = selectedCategory != null
            ? data.firstWhereOrNull((d) => d.category.id == selectedCategory.id)
            : null;

        final progressList = data.map((d) {
          return BudgetProgress(
            category: d.category,
            amountSpent: d.spentInCompletedDays + d.spendingToday,
            projectedBudget: d.effectiveWeeklyBudget,
          );
        }).toList();

        return WillPopScope(
          onWillPop: () async {
            if (selectedCategory != null) {
              ref.read(selectedWeeklyCategoryProvider.notifier).state = null;
              return false;
            }
            return true;
          },
          child: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 8),

                  // --- 1. THE FIXED HEADER ROW (48px tall) ---
                  SizedBox(
                    height: 48,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: selectedCategoryData == null
                          // A. Global Header: The Week Selector
                          ? WeekSelector(
                              key: const ValueKey('GlobalHeader'),
                              selectedDate: selectedDate,
                              onDateChanged: (newDate) {
                                final now = ref
                                    .read(clockNotifierProvider)
                                    .now();
                                if (newDate.isAfter(
                                  now.add(const Duration(days: 7)),
                                ))
                                  return;
                                ref.read(weeklyDateProvider.notifier).state =
                                    newDate;
                              },
                            )
                          // B. Category Header: "This Week" with Icons
                          : Row(
                              key: ValueKey(
                                'CategoryHeader_${selectedCategoryData.category.id}',
                              ),
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 16.0),
                                  child: IconButton(
                                    iconSize: 28,
                                    icon: Icon(
                                      Icons.edit,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              EditBasicCategoryScreen(
                                                category: selectedCategoryData
                                                    .category,
                                              ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Text(
                                  'This Week',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                      ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 16.0),
                                  child: IconButton(
                                    iconSize: 28,
                                    icon: Icon(
                                      Icons.tune,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ManageCategoryScreen(
                                                category: selectedCategoryData
                                                    .category,
                                              ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

                  // --- INCREASED SPACING BELOW HEADER ---
                  const SizedBox(height: 24),

                  // --- 2. THE FIXED CHART AREA ---
                  // DECREASED height from 310 to 270.
                  // This removes the dead space at the bottom and pulls the BudgetList up!
                  SizedBox(
                    height: 270,
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
                      transitionBuilder: (child, animation) =>
                          FadeTransition(opacity: animation, child: child),
                      child: selectedCategoryData == null
                          ? const SizedBox(
                              key: ValueKey('WeeklyBarChart'),
                              height: 270,
                              child: WeeklyBarChart(),
                            )
                          : SizedBox(
                              key: ValueKey(
                                'Speedometer_${selectedCategoryData.category.id}',
                              ),
                              height: 270,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24.0,
                                ),
                                child: SpendingSpeedometer(
                                  currentSpeed:
                                      selectedCategoryData.currentSpeed,
                                  recommendedSpeed:
                                      selectedCategoryData.recommendedSpeed,
                                  daysRemaining:
                                      selectedCategoryData.daysRemaining,
                                  color: Color(
                                    selectedCategoryData.category.colorValue,
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ),

                  BudgetList(
                    progressList: progressList,
                    selectedCategory: selectedCategory,
                    onCategoryTap: (category) {
                      final isSelected = selectedCategory?.id == category?.id;
                      ref.read(selectedWeeklyCategoryProvider.notifier).state =
                          isSelected ? null : category;
                    },
                  ),

                  const SizedBox(height: 8),

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
                    transitionBuilder: (child, animation) =>
                        FadeTransition(opacity: animation, child: child),
                    child: selectedCategoryData == null
                        ? _buildGlobalWeeklyDetails(context, data, ref)
                        : WeeklyCategoryDetailView(
                            key: ValueKey(
                              'Detail_${selectedCategoryData.category.id}',
                            ),
                            data: selectedCategoryData,
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

  Widget _buildGlobalWeeklyDetails(
    BuildContext context,
    List<WeeklyCategoryData> allData,
    WidgetRef ref,
  ) {
    if (allData.isEmpty) return const SizedBox.shrink();

    final checkInDayAsync = ref.watch(checkInDayProvider);
    final startDay = checkInDayAsync.valueOrNull ?? 1;

    List<double> globalCurrentPattern = List.filled(7, 0.0);
    List<double> globalAvgPattern = List.filled(7, 0.0);
    double globalSpentInCompletedDays = 0;
    double globalSpendingToday = 0;
    double globalEffectiveBudget = 0;
    int daysRemaining = allData.first.daysRemaining;

    for (final d in allData) {
      globalSpentInCompletedDays += d.spentInCompletedDays;
      globalSpendingToday += d.spendingToday;
      globalEffectiveBudget += d.effectiveWeeklyBudget;
      for (int i = 0; i < 7; i++) {
        globalCurrentPattern[i] += d.currentWeekPattern[i];
        globalAvgPattern[i] += d.averageWeekPattern[i];
      }
    }

    final double totalSpent = globalSpentInCompletedDays + globalSpendingToday;
    final double remainingBudget = globalEffectiveBudget - totalSpent;
    final int daysPassed = (7 - daysRemaining).clamp(0, 7);
    final double actualDailyAvg = daysPassed > 0
        ? globalSpentInCompletedDays / daysPassed
        : 0.0;
    final double projectedTotalSpend = actualDailyAvg * 7;
    final double projectedEndBalance =
        globalEffectiveBudget - projectedTotalSpend;
    final bool isProjectedPositive = projectedEndBalance >= 0;

    final selectedDate = ref.read(weeklyDateProvider);
    final startOfSelectedWeek = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day - (selectedDate.weekday - startDay + 7) % 7,
    );
    final endOfSelectedWeek = startOfSelectedWeek.add(const Duration(days: 7));

    return Column(
      key: const ValueKey('GlobalWeeklyDetails'),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              RecentTransactionsList(
                categoryId: null,
                weekStartDate: startOfSelectedWeek,
                weekEndDate: endOfSelectedWeek,
              ),
              const SizedBox(height: 18),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SizedBox(
            height: 510,
            child: SummaryCardBase(
              title: 'Global Weekly Snapshot',
              subtitle: 'Current status across all categories',
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  WeeklyStatRow(
                    value: '$daysRemaining',
                    unit: 'days left',
                    title: 'Time Remaining',
                    description: 'Days left until your budget resets.',
                    valueColor: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  WeeklyStatRow(
                    value: '\$${totalSpent.toStringAsFixed(0)}',
                    unit: 'this week',
                    title: 'Total Spent',
                    description: 'Includes today and past days.',
                    valueColor: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  WeeklyStatRow(
                    value: '\$${remainingBudget.toStringAsFixed(0)}',
                    unit: 'available',
                    title: 'Budget Left',
                    description: 'Remaining funds for this week.',
                    valueColor: remainingBudget >= 0
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  WeeklyStatRow(
                    value: '\$${actualDailyAvg.toStringAsFixed(0)}',
                    unit: '/ day',
                    title: 'Actual Average',
                    description: 'Avg spending on completed days.',
                    valueColor: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  WeeklyStatRow(
                    value:
                        '${isProjectedPositive ? "+" : ""}\$${projectedEndBalance.abs().toStringAsFixed(0)}',
                    unit: 'at end of week',
                    title: isProjectedPositive
                        ? 'Potential Savings'
                        : 'Potential Overspend',
                    description: 'If you maintain this daily average.',
                    valueColor: isProjectedPositive
                        ? Colors.greenAccent
                        : Colors.redAccent,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
