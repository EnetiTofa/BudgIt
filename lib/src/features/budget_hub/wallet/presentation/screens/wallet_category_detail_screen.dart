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
    // If loading or error, fall back to the passed 'data' (optimistic UI)
    // If data arrives, find the matching category ID.
    final liveData = asyncDataList.valueOrNull?.firstWhere(
      (element) => element.category.id == data.category.id,
      orElse: () => data,
    ) ?? data;

    final catColor = Color(liveData.category.colorValue);
    final contentColor = liveData.category.contentColor; 
    
    final checkInDayAsync = ref.watch(checkInDayProvider);
    final startDay = checkInDayAsync.valueOrNull ?? 1; 

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
          ],
        ),
      ),
    );
  }
}