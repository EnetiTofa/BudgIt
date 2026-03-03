// lib/src/features/budget_hub/presentation/widgets/weekly_category_detail_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:budgit/src/features/budget_hub/domain/weekly_category_data.dart';
import 'package:budgit/src/features/budget_hub/presentation/providers/weekly_projection_providers.dart';
import 'package:budgit/src/features/budget_hub/presentation/screens/weekly_screen.dart';
import 'package:budgit/src/features/budget_hub/presentation/widgets/weekly_category_summary_card.dart';
import 'package:budgit/src/features/budget_hub/presentation/widgets/weekly_pattern_chart.dart';
import 'package:budgit/src/features/budget_hub/presentation/widgets/active_transfers_section.dart';
import 'package:budgit/src/common_widgets/summary_card_base.dart';
import 'package:budgit/src/features/budget_hub/presentation/widgets/recent_transactions_list.dart';

class WeeklyCategoryDetailView extends ConsumerWidget {
  final WeeklyCategoryData data;

  const WeeklyCategoryDetailView({super.key, required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = ref.watch(weeklyDateProvider);
    final asyncDataList = ref.watch(
      weeklyCategoryDataProvider(selectedDate: date),
    );

    final liveData =
        asyncDataList.valueOrNull?.firstWhere(
          (element) => element.category.id == data.category.id,
          orElse: () => data,
        ) ??
        data;

    final catColor = Color(liveData.category.colorValue);
    final checkInDayAsync = ref.watch(checkInDayProvider);
    final startDay = checkInDayAsync.valueOrNull ?? 1;

    // Note: We use the currently selected 'date' to bound the week,
    // so we can look at past/future weeks accurately!
    final startOfSelectedWeek = DateTime(
      date.year,
      date.month,
      date.day - (date.weekday - startDay + 7) % 7,
    );
    final endOfSelectedWeek = startOfSelectedWeek.add(const Duration(days: 7));

    // Calculations
    final daysPassed = (7 - liveData.daysRemaining).clamp(0, 7);
    final double actualDailyAvg = daysPassed > 0
        ? liveData.spentInCompletedDays / daysPassed
        : 0.0;
    final double projectedTotalSpend = actualDailyAvg * 7;
    final double projectedEndBalance =
        liveData.effectiveWeeklyBudget - projectedTotalSpend;
    final bool isProjectedPositive = projectedEndBalance >= 0;

    final double totalSpent =
        liveData.spentInCompletedDays + liveData.spendingToday;
    final double remainingBudget = liveData.effectiveWeeklyBudget - totalSpent;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          WeeklyCategorySummaryCard(data: liveData),
          const SizedBox(height: 24),

          WeeklyPatternChart(
            currentPattern: liveData.currentWeekPattern,
            averagePattern: liveData.averageWeekPattern,
            color: catColor,
            startDayOfWeek: startDay,
          ),
          const SizedBox(height: 18),

          ActiveTransfersSection(category: liveData.category),
          const SizedBox(height: 18),

          // --- Category-Specific Recent Transactions ---
          RecentTransactionsList(
            categoryId: liveData.category.id,
            weekStartDate: startOfSelectedWeek,
            weekEndDate: endOfSelectedWeek,
          ),
          const SizedBox(height: 18),

          SizedBox(
            height: 510,
            child: SummaryCardBase(
              title: '${liveData.category.name} Snapshot',
              subtitle: 'Current status and future projections',
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  WeeklyStatRow(
                    value: '${liveData.daysRemaining}',
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
        ],
      ),
    );
  }
}

// Made this public so the main WeeklyScreen can use it for the global stats too!
class WeeklyStatRow extends StatelessWidget {
  final String value;
  final String unit;
  final String title;
  final String description;
  final Color valueColor;

  const WeeklyStatRow({
    super.key,
    required this.value,
    required this.unit,
    required this.title,
    required this.description,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 110,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: valueColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  unit,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
