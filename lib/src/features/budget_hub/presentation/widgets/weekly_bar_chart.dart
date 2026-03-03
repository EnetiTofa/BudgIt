// lib/src/features/budget_hub/wallet/presentation/widgets/weekly_bar_chart.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/core/data/providers/category_list_provider.dart';
import 'package:intl/intl.dart';
import 'package:budgit/src/features/settings/data/settings_provider.dart';
import 'package:budgit/src/utils/clock_provider.dart';

// FIX: Point to the single consolidated weekly provider file
import 'package:budgit/src/features/budget_hub/presentation/providers/weekly_projection_providers.dart';

class WeeklyBarChart extends ConsumerStatefulWidget {
  const WeeklyBarChart({super.key});

  @override
  ConsumerState<WeeklyBarChart> createState() => _WeeklyBarChartState();
}

class _WeeklyBarChartState extends ConsumerState<WeeklyBarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    final now = ref.read(clockNotifierProvider).now();

    // FIX: Using weeklyChartDataProvider
    ref.read(weeklyChartDataProvider(selectedDate: now).future).then((_) {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // FIX: Using weeklyDateProvider
    final selectedDate = ref.watch(weeklyDateProvider);
    // FIX: Using weeklyChartDataProvider
    final chartDataAsync = ref.watch(
      weeklyChartDataProvider(selectedDate: selectedDate),
    );
    final categoriesAsync = ref.watch(categoryListProvider);
    final settingsAsync = ref.watch(settingsProvider);
    final theme = Theme.of(context);

    // FIX: Using weeklyChartDataProvider
    ref.listen(weeklyChartDataProvider(selectedDate: selectedDate), (_, __) {
      _controller.forward(from: 0.0);
    });

    // Removed Card wrapper to eliminate background color.
    return Padding(
      // Reduced padding to make it more compact
      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: SizedBox(
              height: 220, // Reduced height from 220 to make it compact
              child: chartDataAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Center(child: Text('Error: $e')),
                data: (chartData) {
                  const double interval = 5.0;
                  final roundedMaxY = chartData.maxY > 0
                      ? (chartData.maxY / interval).ceil() * interval
                      : interval;

                  return AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return BarChart(
                        BarChartData(
                          minY: -0.1,
                          maxY: roundedMaxY + 0.1,
                          borderData: FlBorderData(show: false),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: interval,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: Theme.of(
                                  context,
                                ).dividerColor.withValues(alpha: 0.1),
                                strokeWidth: 1,
                              );
                            },
                            checkToShowHorizontalLine: (value) => true,
                          ),
                          extraLinesData: ExtraLinesData(
                            horizontalLines: [
                              HorizontalLine(
                                y: chartData.dailyTarget * _animation.value,
                                color: Colors.redAccent.withOpacity(0.8),
                                strokeWidth: 1,
                              ),
                              HorizontalLine(
                                y:
                                    chartData.averageDailySpend *
                                    _animation.value,
                                color: theme.colorScheme.primary.withOpacity(
                                  0.8,
                                ),
                                strokeWidth: 1,
                              ),
                            ],
                          ),
                          titlesData: FlTitlesData(
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 28,
                                interval: interval,
                                getTitlesWidget: (value, meta) {
                                  if (value == meta.max) {
                                    return SideTitleWidget(
                                      meta: meta,
                                      child: const Text(''),
                                    );
                                  }
                                  if (value % interval == 0) {
                                    return SideTitleWidget(
                                      meta: meta,
                                      space: 4,
                                      child: Text(
                                        '${value.toInt()}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: theme.colorScheme.secondary
                                              .withValues(alpha: 0.9),
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                    );
                                  }
                                  return SideTitleWidget(
                                    meta: meta,
                                    child: const Text(''),
                                  );
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  return settingsAsync.when(
                                    data: (settings) {
                                      final checkInDay = settings
                                          .getCheckInDay();
                                      final startOfWeek = DateTime(
                                        selectedDate.year,
                                        selectedDate.month,
                                        selectedDate.day -
                                            (selectedDate.weekday -
                                                    checkInDay +
                                                    7) %
                                                7,
                                      );

                                      final date = startOfWeek.add(
                                        Duration(days: value.toInt()),
                                      );
                                      final text = DateFormat.E().format(date);

                                      final now = ref
                                          .read(clockNotifierProvider)
                                          .now();
                                      final isToday =
                                          date.year == now.year &&
                                          date.month == now.month &&
                                          date.day == now.day;

                                      return SideTitleWidget(
                                        meta: meta,
                                        space: 4,
                                        child: Text(
                                          text,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: isToday
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            color: isToday
                                                ? theme.colorScheme.primary
                                                : Colors.grey,
                                          ),
                                        ),
                                      );
                                    },
                                    loading: () => SideTitleWidget(
                                      meta: meta,
                                      child: const Text(''),
                                    ),
                                    error: (e, s) => SideTitleWidget(
                                      meta: meta,
                                      child: const Text(''),
                                    ),
                                  );
                                },
                                reservedSize: 24,
                              ),
                            ),
                          ),
                          barGroups: List.generate(7, (index) {
                            final spendingMap =
                                chartData.dailyTotals[index] ?? {};
                            double currentY = 0;
                            final rodStackItems = <BarChartRodStackItem>[];

                            if (categoriesAsync.hasValue) {
                              for (final category in categoriesAsync.value!) {
                                if (spendingMap.containsKey(category.id)) {
                                  final amount = spendingMap[category.id]!;
                                  rodStackItems.add(
                                    BarChartRodStackItem(
                                      currentY,
                                      currentY + amount,
                                      category.color,
                                    ),
                                  );
                                  currentY += amount;
                                }
                              }
                            }

                            return BarChartGroupData(
                              x: index,
                              barRods: [
                                BarChartRodData(
                                  toY: currentY * _animation.value,
                                  rodStackItems: rodStackItems
                                      .map(
                                        (item) => BarChartRodStackItem(
                                          item.fromY * _animation.value,
                                          item.toY * _animation.value,
                                          item.color,
                                        ),
                                      )
                                      .toList(),
                                  width: 16,
                                  borderRadius: BorderRadius.zero,
                                ),
                              ],
                            );
                          }),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ChartLegend(color: Colors.redAccent, text: 'Daily Target'),
              const SizedBox(width: 24),
              _ChartLegend(
                color: theme.colorScheme.primary,
                text: 'Daily Average',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChartLegend extends StatelessWidget {
  final Color color;
  final String text;

  const _ChartLegend({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 16, height: 4, color: color),
        const SizedBox(width: 8),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}
