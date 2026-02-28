// lib/src/features/budgets/presentation/widgets/category_detail_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart'; // Add this import
import 'package:intl/intl.dart';
import 'package:budgit/src/core/domain/models/category.dart';
import 'package:budgit/src/core/data/providers/category_list_provider.dart';
import 'package:budgit/src/utils/palette_generator.dart';
import 'package:budgit/src/features/transaction_hub/transactions/presentation/providers/next_recurring_payment_provider.dart';
import 'package:budgit/src/common_widgets/summary_stat_card.dart';
import 'package:budgit/src/features/budget_hub/presentation/providers/monthly_projection_providers.dart';

class CategoryDetailView extends ConsumerStatefulWidget {
  const CategoryDetailView({
    super.key,
    required this.categoryId,
    required this.selectedMonth,
  });

  final String categoryId;
  final DateTime selectedMonth;

  @override
  ConsumerState<CategoryDetailView> createState() => _CategoryDetailViewState();
}

class _CategoryDetailViewState extends ConsumerState<CategoryDetailView> {
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
    final categoryListAsync = ref.watch(categoryListProvider);

    return categoryListAsync.when(
      data: (categories) {
        final category = categories.firstWhere(
          (cat) => cat.id == widget.categoryId,
          orElse: () => Category(
            id: '',
            name: '',
            iconCodePoint: 0,
            colorValue: 0,
            budgetAmount: 0,
          ),
        );

        if (category.id.isEmpty) {
          return const SizedBox.shrink();
        }

        // --- FETCH DATA ---
        final historicalData = ref.watch(
          historicalCategorySpendingProvider(categoryId: category.id),
        );

        final breakdown = ref.watch(
          categoryMonthlyBreakdownProvider(
            categoryId: category.id,
            month: widget.selectedMonth,
          ),
        );

        final nextPayment = ref.watch(
          nextRecurringPaymentProvider(categoryId: category.id),
        );
        // ---------------------------------

        final palette = generateSpendingPalette(category.color);
        final colorScheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;

        // Calculate maximum Y value for the chart to scale properly
        double maxAmount = 10.0;
        if (historicalData.isNotEmpty) {
          final highestDataPoint = historicalData
              .map((d) => d.total)
              .reduce((a, b) => a > b ? a : b);
          if (highestDataPoint > maxAmount) {
            maxAmount = highestDataPoint;
          }
        }
        final maxY = maxAmount * 1.2; // Add 20% padding to the top

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 8),

              // 1. Upcoming Transactions Card
              _DetailCard(
                child: InkWell(
                  borderRadius: BorderRadius.circular(16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Upcoming Transactions',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Builder(
                          builder: (context) {
                            if (nextPayment == null) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Text(
                                    'No upcoming recurring payments.',
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            }
                            return Row(
                              children: [
                                if (nextPayment.iconCodePoint != null)
                                  Icon(
                                    IconData(
                                      nextPayment.iconCodePoint!,
                                      fontFamily: nextPayment.iconFontFamily,
                                      fontPackage:
                                          'material_design_icons_flutter',
                                    ),
                                    size: 32,
                                    color: colorScheme.secondary,
                                  )
                                else
                                  Icon(
                                    Icons.refresh_rounded,
                                    size: 32,
                                    color: colorScheme.secondary,
                                  ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        nextPayment.itemName,
                                        style: textTheme.bodyLarge?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        DateFormat.yMMMd().format(
                                          nextPayment.date,
                                        ),
                                        style: textTheme.bodyMedium?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '-\$${nextPayment.amount.toStringAsFixed(2)}',
                                  style: textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 2. History Card (Updated with fl_chart)
              _DetailCard(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'History',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 180, // Slightly taller to fit fl_chart cleanly
                        child: Builder(
                          builder: (context) {
                            if (historicalData.isEmpty) {
                              return Center(
                                child: Text(
                                  'No spending data yet.',
                                  style: TextStyle(
                                    color: colorScheme.secondary,
                                  ),
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
                                    width: _itemWidth * historicalData.length,
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
                                              alignment:
                                                  BarChartAlignment.spaceAround,
                                              minY: 0,
                                              maxY: maxY,
                                              barTouchData: BarTouchData(
                                                enabled: false,
                                              ), // Handle touches manually below
                                              borderData: FlBorderData(
                                                show: false,
                                              ),
                                              gridData: FlGridData(
                                                show: true,
                                                drawVerticalLine: false,
                                                getDrawingHorizontalLine:
                                                    (value) => FlLine(
                                                      color: Theme.of(context)
                                                          .dividerColor
                                                          .withOpacity(0.1),
                                                      strokeWidth: 1,
                                                    ),
                                              ),
                                              titlesData: FlTitlesData(
                                                topTitles: const AxisTitles(
                                                  sideTitles: SideTitles(
                                                    showTitles: false,
                                                  ),
                                                ),
                                                rightTitles: const AxisTitles(
                                                  sideTitles: SideTitles(
                                                    showTitles: false,
                                                  ),
                                                ),
                                                leftTitles: const AxisTitles(
                                                  sideTitles: SideTitles(
                                                    showTitles: false,
                                                  ),
                                                ),
                                                bottomTitles: AxisTitles(
                                                  sideTitles: SideTitles(
                                                    showTitles: true,
                                                    reservedSize: 32,
                                                    getTitlesWidget: (value, meta) {
                                                      final index = value
                                                          .toInt();
                                                      if (index < 0 ||
                                                          index >=
                                                              historicalData
                                                                  .length)
                                                        return const SizedBox.shrink();

                                                      final item =
                                                          historicalData[index];
                                                      final isSelected =
                                                          item.date.year ==
                                                              widget
                                                                  .selectedMonth
                                                                  .year &&
                                                          item.date.month ==
                                                              widget
                                                                  .selectedMonth
                                                                  .month;

                                                      return SideTitleWidget(
                                                        meta: meta,
                                                        space: 8,
                                                        child: Text(
                                                          DateFormat.MMM()
                                                              .format(
                                                                item.date,
                                                              ),
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                isSelected
                                                                ? FontWeight
                                                                      .bold
                                                                : FontWeight
                                                                      .normal,
                                                            color: isSelected
                                                                ? colorScheme
                                                                      .primary
                                                                : colorScheme
                                                                      .secondary,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                              barGroups: List.generate(
                                                historicalData.length,
                                                (index) {
                                                  final item =
                                                      historicalData[index];
                                                  final isSelected =
                                                      item.date.year ==
                                                          widget
                                                              .selectedMonth
                                                              .year &&
                                                      item.date.month ==
                                                          widget
                                                              .selectedMonth
                                                              .month;
                                                  final opacity = isSelected
                                                      ? 1.0
                                                      : 0.3;

                                                  return BarChartGroupData(
                                                    x: index,
                                                    barRods: [
                                                      BarChartRodData(
                                                        toY: item.total > 0
                                                            ? item.total
                                                            : 0.1,
                                                        width:
                                                            22, // Match your old bar width
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              4,
                                                            ),
                                                        // Stack the recurring and variable values
                                                        rodStackItems: [
                                                          if (item.recurring >
                                                              0)
                                                            BarChartRodStackItem(
                                                              0,
                                                              item.recurring,
                                                              palette.recurring
                                                                  .withOpacity(
                                                                    opacity,
                                                                  ),
                                                            ),
                                                          if (item.variable > 0)
                                                            BarChartRodStackItem(
                                                              item.recurring,
                                                              item.total,
                                                              palette.wallet
                                                                  .withOpacity(
                                                                    opacity,
                                                                  ),
                                                            ),
                                                        ],
                                                        color: colorScheme
                                                            .surfaceContainerHighest
                                                            .withOpacity(
                                                              opacity,
                                                            ),
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
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: List.generate(
                                              historicalData.length,
                                              (index) {
                                                final item =
                                                    historicalData[index];
                                                final isSelected =
                                                    item.date.year ==
                                                        widget
                                                            .selectedMonth
                                                            .year &&
                                                    item.date.month ==
                                                        widget
                                                            .selectedMonth
                                                            .month;

                                                return Expanded(
                                                  child: GestureDetector(
                                                    behavior:
                                                        HitTestBehavior.opaque,
                                                    onTap: () {
                                                      // Update selected month provider
                                                      ref
                                                          .read(
                                                            selectedMonthProvider
                                                                .notifier,
                                                          )
                                                          .state = item
                                                          .date;
                                                    },
                                                    child: Container(
                                                      margin:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 2,
                                                            vertical: 0,
                                                          ),
                                                      decoration: isSelected
                                                          ? BoxDecoration(
                                                              border: Border.all(
                                                                color:
                                                                    colorScheme
                                                                        .primary,
                                                                width: 2,
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    12,
                                                                  ),
                                                              color: colorScheme
                                                                  .primary
                                                                  .withOpacity(
                                                                    0.05,
                                                                  ),
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
                ),
              ),

              const SizedBox(height: 16),
              // 3. Summary Card
              SummaryStatCard(
                stats: [
                  SummaryStat(
                    value: '\$${breakdown.recurring.toStringAsFixed(2)}',
                    unit: 'Fixed',
                    title: 'Fixed Spending',
                    description: 'Spent on recurring bills.',
                  ),
                  SummaryStat(
                    value: '\$${breakdown.variable.toStringAsFixed(2)}',
                    unit: 'Variable',
                    title: 'Variable Spending',
                    description: 'Spent on day-to-day items.',
                  ),
                  SummaryStat(
                    value: '\$${breakdown.dailyAverage.toStringAsFixed(2)}',
                    unit: '/ day',
                    title: 'Daily Average',
                    description: 'Average total spending per day this month.',
                  ),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final Widget child;

  const _DetailCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: child,
    );
  }
}

// NOTE: ChartPainter and _ChartSegment have been safely removed!
