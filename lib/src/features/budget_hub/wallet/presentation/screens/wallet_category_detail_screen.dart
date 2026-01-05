import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/features/budget_hub/wallet/domain/wallet_category_data.dart';
import 'package:budgit/src/features/settings/data/settings_provider.dart';
import 'package:budgit/src/features/budget_hub/wallet/presentation/providers/wallet_category_data_provider.dart';

// Widgets
import 'package:budgit/src/features/budget_hub/wallet/presentation/widgets/spending_speedometer.dart';
import 'package:budgit/src/features/budget_hub/wallet/presentation/widgets/segmented_linear_gauge.dart';
import 'package:budgit/src/features/budget_hub/wallet/presentation/widgets/weekly_pattern_chart.dart';
import 'package:budgit/src/features/budget_hub/wallet/presentation/widgets/active_boosts_section.dart';
import 'package:budgit/src/common_widgets/summary_card_base.dart';

// Helper provider to get check-in day simply
final checkInDayProvider = FutureProvider<int>((ref) async {
  final settingsRepo = await ref.watch(settingsProvider.future);
  return settingsRepo.getCheckInDay();
});

class WalletCategoryDetailScreen extends ConsumerWidget {
  final WalletCategoryData data;

  const WalletCategoryDetailScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Listen to the LIVE data source
    final date = ref.watch(walletDateProvider);
    final asyncDataList = ref.watch(walletCategoryDataProvider(selectedDate: date));
    
    // 2. Extract the fresh data for THIS category
    final liveData = asyncDataList.valueOrNull?.firstWhere(
      (element) => element.category.id == data.category.id,
      orElse: () => data,
    ) ?? data;

    final catColor = Color(liveData.category.colorValue);
    final contentColor = liveData.category.contentColor; 
    
    final checkInDayAsync = ref.watch(checkInDayProvider);
    final startDay = checkInDayAsync.valueOrNull ?? 1; 

    // --- Insight Calculations ---
    // Calculate past days (Total Week Days - Days Remaining)
    final daysPassed = (7 - liveData.daysRemaining).clamp(0, 7);
    
    // 1. Actual Daily Average (based only on fully completed days)
    final double actualDailyAvg = daysPassed > 0 
        ? liveData.spentInCompletedDays / daysPassed 
        : 0.0; // Avoid dividing by zero on Day 1

    // 2. Projection: Avg * 7 days
    final double projectedTotalSpend = actualDailyAvg * 7;
    final double projectedEndBalance = liveData.effectiveWeeklyBudget - projectedTotalSpend;
    final bool isProjectedPositive = projectedEndBalance >= 0;

    // 3. New Stats Calculations
    final double totalSpent = liveData.spentInCompletedDays + liveData.spendingToday;
    final double remainingBudget = liveData.effectiveWeeklyBudget - totalSpent;

    return Scaffold(
      appBar: AppBar(
        title: Text(liveData.category.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Metrics Speedometer
            SpendingSpeedometer(
              currentSpeed: liveData.currentSpeed,
              recommendedSpeed: liveData.recommendedSpeed,
              daysRemaining: liveData.daysRemaining, 
              color: catColor,
            ),
            const SizedBox(height: 24),

            // 2. Spending Bar
            SegmentedLinearGauge(
              totalBudget: liveData.effectiveWeeklyBudget,
              spent: liveData.totalSpentThisWeek,
              dailySpending: liveData.currentWeekPattern,
              backgroundColor: catColor,       
              foregroundColor: contentColor,   
            ),
            const SizedBox(height: 18),

            // 3. Weekly Pattern
            WeeklyPatternChart(
              currentPattern: liveData.currentWeekPattern,
              averagePattern: liveData.averageWeekPattern,
              color: catColor,
              startDayOfWeek: startDay,
            ),
            const SizedBox(height: 18),

            // 4. Active Boosts
            ActiveBoostsSection(category: liveData.category),
            const SizedBox(height: 18),

            // 5. Weekly Stats Card
            // Increased height to 560 to accommodate 5 stats rows + spacing
            SizedBox(
              height: 510, 
              child: SummaryCardBase(
                title: 'Weekly Snapshot', // Renamed slightly to reflect broader stats
                subtitle: 'Current status and future projections',
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // --- NEW STAT 1: Days Remaining ---
                    _StatRow(
                      value: '${liveData.daysRemaining}',
                      unit: 'days left',
                      title: 'Time Remaining',
                      description: 'Days left until your budget resets.',
                      valueColor: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),

                    // --- NEW STAT 2: Total Spent ---
                    _StatRow(
                      value: '\$${totalSpent.toStringAsFixed(0)}',
                      unit: 'this week',
                      title: 'Total Spent',
                      description: 'Includes today and past days.',
                      valueColor: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),

                    // --- NEW STAT 3: Budget Left ---
                    _StatRow(
                      value: '\$${remainingBudget.toStringAsFixed(0)}',
                      unit: 'available',
                      title: 'Budget Left',
                      description: 'Remaining funds for this week.',
                      valueColor: remainingBudget >= 0 
                          ? Theme.of(context).colorScheme.primary 
                          : Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),

                    // --- EXISTING STAT: Actual Average ---
                    _StatRow(
                      value: '\$${actualDailyAvg.toStringAsFixed(0)}',
                      unit: '/ day',
                      title: 'Actual Average',
                      description: 'Avg spending on completed days.',
                      valueColor: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),

                    // --- EXISTING STAT: Projected Outcome ---
                    _StatRow(
                      value: '${isProjectedPositive ? "+" : ""}\$${projectedEndBalance.abs().toStringAsFixed(0)}',
                      unit: 'at end of week',
                      title: isProjectedPositive ? 'Potential Savings' : 'Potential Overspend',
                      description: 'If you maintain this daily average.',
                      valueColor: isProjectedPositive 
                          ? Colors.greenAccent
                          : Colors.redAccent,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// Helper widget to match the visual style of rows in SummaryStatCard
class _StatRow extends StatelessWidget {
  final String value;
  final String unit;
  final String title;
  final String description;
  final Color valueColor;

  const _StatRow({
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
        // Boxed Value
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
        // Text Description
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