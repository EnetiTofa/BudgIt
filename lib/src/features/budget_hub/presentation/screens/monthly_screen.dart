// lib/src/features/budget_hub/presentation/screens/monthly_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart'; // Added for the history chart
import 'package:intl/intl.dart'; // Added for DateFormat

import 'package:budgit/src/common_widgets/pulsing_button.dart';
import 'package:budgit/src/features/categories/presentation/screens/add_category_screen.dart';
import 'package:budgit/src/features/categories/presentation/screens/manage_category_screen.dart';
import 'package:budgit/src/common_widgets/summary_stat_card.dart';
import 'package:budgit/src/core/domain/models/category.dart';
import 'package:budgit/src/features/budget_hub/presentation/widgets/budget_list.dart';
import 'package:budgit/src/features/budget_hub/presentation/widgets/month_selector.dart';
import 'package:budgit/src/features/budget_hub/presentation/widgets/category_detail_view.dart';
import 'package:budgit/src/features/budget_hub/presentation/widgets/unified_budget_gauge.dart';
import 'package:budgit/src/features/budget_hub/domain/category_gauge_data.dart';
import 'package:budgit/src/core/data/providers/category_list_provider.dart';

// --- NEW IMPORTS (Consolidated Providers) ---
import 'package:budgit/src/features/budget_hub/presentation/providers/monthly_projection_providers.dart';

final selectedCategoryProvider = StateProvider<Category?>((ref) => null);

class MonthlyScreen extends ConsumerWidget {
  const MonthlyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // WATCH THE NEW CONSOLIDATED PROVIDER
    final budgetDataAsync = ref.watch(monthlyScreenDataProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return budgetDataAsync.when(
      skipLoadingOnReload: true,
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (screenData) {
        // We still use selectedMonthProvider, but it now lives in the consolidated file
        final selectedMonth =
            ref.watch(selectedMonthProvider) ??
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
                  const SizedBox(height: 8),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        MonthSelector(
                          selectedDate: selectedMonth,
                          onMonthChanged: (newMonth) {
                            final now = DateTime.now();
                            final currentMonth = DateTime(now.year, now.month);

                            if (newMonth.isAfter(currentMonth)) return;

                            ref.read(selectedMonthProvider.notifier).state =
                                newMonth;
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
                                      category: selectedCategory,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
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
                      transitionBuilder: (child, animation) =>
                          FadeTransition(opacity: animation, child: child),
                      child: selectedCategory == null
                          ? Align(
                              alignment: Alignment.topCenter,
                              child: _buildGlobalGauge(
                                context,
                                screenData,
                                selectedMonth,
                              ),
                            )
                          : Align(
                              alignment: Alignment.topCenter,
                              child: _CategoryGaugeWrapper(
                                key: ValueKey(
                                  'CatGauge_${selectedCategory.id}',
                                ),
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
                            MaterialPageRoute(
                              builder: (_) => const AddCategoryScreen(),
                            ),
                          );
                        },
                      ),
                    )
                  else
                    BudgetList(
                      progressList: screenData.budgetProgress,
                      selectedCategory: selectedCategory,
                      onCategoryTap: (category) {
                        ref.read(selectedCategoryProvider.notifier).state =
                            category;
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
                    transitionBuilder: (child, animation) =>
                        FadeTransition(opacity: animation, child: child),
                    child: selectedCategory == null
                        ? _buildGlobalDetails(
                            context,
                            screenData,
                            selectedMonth,
                          )
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
    BuildContext context,
    MonthlyScreenData screenData,
    DateTime selectedDate,
  ) {
    final totalSpent = screenData.budgetProgress.fold(
      0.0,
      (sum, item) => sum + item.amountSpent,
    );
    final totalBudget = screenData.budgetProgress.fold(
      0.0,
      (sum, item) => sum + item.projectedBudget,
    );

    final segments = screenData.budgetProgress
        .map(
          (p) => GaugeSegment(
            label: p.category.name,
            amount: p.amountSpent,
            color: p.category.color,
          ),
        )
        .toList();

    return Padding(
      key: const ValueKey('GlobalGauge'),
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: UnifiedBudgetGauge(
        segments: segments,
        totalBudget: totalBudget,
        totalSpent: totalSpent,
        labelSuffix: "of \$${totalBudget.toStringAsFixed(0)} Budget",
        showLegend: false,
      ),
    );
  }

  // Consolidated the history chart and summary card for the global view
  Widget _buildGlobalDetails(
    BuildContext context,
    MonthlyScreenData screenData,
    DateTime selectedMonth,
  ) {
    return Column(
      key: const ValueKey('GlobalDetails'),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: _GlobalHistoryChart(
            historicalData: screenData.historicalSpending,
            selectedMonth: selectedMonth,
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SummaryStatCard(
            stats: [
              SummaryStat(
                value:
                    '\$${screenData.summaryDetails.dailyAverage.toStringAsFixed(2)}',
                unit: 'NZD / day',
                title: 'Daily Average',
                description: 'Your average spending per day for this month.',
              ),
              SummaryStat(
                value: screenData.summaryDetails.monthsCounted.toString(),
                unit: 'Months',
                title: 'Months Counted',
                description:
                    'The total number of months with transaction data.',
              ),
              SummaryStat(
                value: screenData.summaryDetails.highestMonth,
                unit: 'Month',
                title: 'Highest Month',
                description: 'The month where you spent the most amount.',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CategoryGaugeWrapper extends ConsumerWidget {
  final Category category;
  final DateTime month;

  const _CategoryGaugeWrapper({
    required this.category,
    required this.month,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // WATCH THE NEW CONSOLIDATED SYNCHRONOUS PROVIDER
    final gaugeData = ref.watch(
      categoryGaugeDataProvider(category: category, month: month),
    );

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

class _GlobalHistoryChart extends ConsumerStatefulWidget {
  final List<dynamic> historicalData;
  final DateTime selectedMonth;

  const _GlobalHistoryChart({
    required this.historicalData,
    required this.selectedMonth,
  });

  @override
  ConsumerState<_GlobalHistoryChart> createState() =>
      _GlobalHistoryChartState();
}

class _GlobalHistoryChartState extends ConsumerState<_GlobalHistoryChart> {
  late final ScrollController _chartScrollController;
  static const double _itemWidth = 65.0;
  bool _hasScrolledToEnd = false;

  @override
  void initState() {
    super.initState();
    _chartScrollController = ScrollController();
  }

  @override
  void dispose() {
    _chartScrollController.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    if (_chartScrollController.hasClients) {
      _chartScrollController.jumpTo(
        _chartScrollController.position.maxScrollExtent,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // --- NEW: Watch categories to get their colors ---
    final categories = ref.watch(categoryListProvider).valueOrNull ?? [];

    double maxAmount = 10.0;
    if (widget.historicalData.isNotEmpty) {
      final highestDataPoint = widget.historicalData
          .map((d) => d.amount as double)
          .reduce((a, b) => a > b ? a : b);
      if (highestDataPoint > maxAmount) {
        maxAmount = highestDataPoint;
      }
    }
    final maxY = maxAmount * 1.2;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16.0),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monthly History',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: Builder(
              builder: (context) {
                if (widget.historicalData.isEmpty) {
                  return Center(
                    child: Text(
                      'No spending data yet.',
                      style: TextStyle(color: colorScheme.secondary),
                    ),
                  );
                }

                if (!_hasScrolledToEnd) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollToEnd();
                    if (mounted) {
                      setState(() => _hasScrolledToEnd = true);
                    }
                  });
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      controller: _chartScrollController,
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: _itemWidth * widget.historicalData.length,
                        height: constraints.maxHeight,
                        child: Stack(
                          children: [
                            // A. The Chart underneath
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 16,
                                bottom: 4,
                              ),
                              child: BarChart(
                                BarChartData(
                                  alignment: BarChartAlignment.spaceAround,
                                  minY: 0,
                                  maxY: maxY,
                                  barTouchData: BarTouchData(enabled: false),
                                  borderData: FlBorderData(show: false),
                                  gridData: FlGridData(
                                    show: true,
                                    drawVerticalLine: false,
                                    getDrawingHorizontalLine: (value) => FlLine(
                                      color: Theme.of(
                                        context,
                                      ).dividerColor.withOpacity(0.1),
                                      strokeWidth: 1,
                                    ),
                                  ),
                                  titlesData: FlTitlesData(
                                    topTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    rightTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    leftTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 32,
                                        getTitlesWidget: (value, meta) {
                                          final index = value.toInt();
                                          if (index < 0 ||
                                              index >=
                                                  widget.historicalData.length)
                                            return const SizedBox.shrink();

                                          final item =
                                              widget.historicalData[index];
                                          final isSelected =
                                              item.date.year ==
                                                  widget.selectedMonth.year &&
                                              item.date.month ==
                                                  widget.selectedMonth.month;

                                          return SideTitleWidget(
                                            meta: meta,
                                            space: 8,
                                            child: Text(
                                              DateFormat.MMM().format(
                                                item.date,
                                              ),
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: isSelected
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                                color: isSelected
                                                    ? colorScheme.primary
                                                    : colorScheme.secondary,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  barGroups: List.generate(
                                    widget.historicalData.length,
                                    (index) {
                                      final item = widget.historicalData[index];
                                      final isSelected =
                                          item.date.year ==
                                              widget.selectedMonth.year &&
                                          item.date.month ==
                                              widget.selectedMonth.month;
                                      final opacity = isSelected ? 1.0 : 0.3;

                                      // --- NEW: Generate Stacked Segments ---
                                      double currentY = 0;
                                      final rodStackItems =
                                          <BarChartRodStackItem>[];

                                      for (final category in categories) {
                                        if (item.categoryTotals.containsKey(
                                          category.id,
                                        )) {
                                          final amount =
                                              item.categoryTotals[category.id]!;
                                          rodStackItems.add(
                                            BarChartRodStackItem(
                                              currentY,
                                              currentY + amount,
                                              Color(
                                                category.colorValue,
                                              ).withOpacity(opacity),
                                            ),
                                          );
                                          currentY += amount;
                                        }
                                      }
                                      // ----------------------------------------

                                      return BarChartGroupData(
                                        x: index,
                                        barRods: [
                                          BarChartRodData(
                                            toY: currentY > 0 ? currentY : 0.1,
                                            width: 22,
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                            rodStackItems:
                                                rodStackItems, // Feed the stacks in
                                            color: colorScheme
                                                .surfaceContainerHighest
                                                .withOpacity(opacity),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),

                            // B. The Touch Overlay on top
                            Positioned.fill(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: List.generate(
                                  widget.historicalData.length,
                                  (index) {
                                    final item = widget.historicalData[index];
                                    final isSelected =
                                        item.date.year ==
                                            widget.selectedMonth.year &&
                                        item.date.month ==
                                            widget.selectedMonth.month;

                                    return Expanded(
                                      child: GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () {
                                          ref
                                              .read(
                                                selectedMonthProvider.notifier,
                                              )
                                              .state = item
                                              .date;
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 2,
                                            vertical: 0,
                                          ),
                                          decoration: isSelected
                                              ? BoxDecoration(
                                                  border: Border.all(
                                                    color: colorScheme.primary,
                                                    width: 2,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  color: colorScheme.primary
                                                      .withOpacity(0.05),
                                                )
                                              : null,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
