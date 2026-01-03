// lib/src/features/budget_hub/wallet/presentation/widgets/wallet_bar_chart.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/core/data/providers/category_list_provider.dart';
import 'package:budgit/src/features/budget_hub/wallet/presentation/providers/wallet_bar_chart_provider.dart';
import 'package:budgit/src/features/budget_hub/wallet/presentation/providers/wallet_category_data_provider.dart';
import 'package:intl/intl.dart';
import 'package:budgit/src/features/settings/data/settings_provider.dart';
import 'package:budgit/src/utils/clock_provider.dart';

class WalletBarChart extends ConsumerStatefulWidget {
  const WalletBarChart({super.key});

  @override
  ConsumerState<WalletBarChart> createState() => _WalletBarChartState();
}

class _WalletBarChartState extends ConsumerState<WalletBarChart> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 700), vsync: this);
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    
    final now = ref.read(clockNotifierProvider).now();
    ref.read(walletBarChartDataProvider(selectedDate: now).future).then((_) {
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
    final selectedDate = ref.watch(walletDateProvider);
    final chartDataAsync = ref.watch(walletBarChartDataProvider(selectedDate: selectedDate));
    final categoriesAsync = ref.watch(categoryListProvider);
    final settingsAsync = ref.watch(settingsProvider);
    final theme = Theme.of(context);

    ref.listen(walletBarChartDataProvider(selectedDate: selectedDate), (_, __) {
      _controller.forward(from: 0.0);
    });

    return Padding(
      // --- MODIFICATION: Removed top padding (was 16.0) ---
      padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      child: Column(
        children: [
          _WeekSelector(
            selectedDate: selectedDate,
            onDateChanged: (newDate) {
              ref.read(walletDateProvider.notifier).state = newDate;
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 250,
            child: chartDataAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e,s) => Center(child: Text('Error: $e')),
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
                              color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                              strokeWidth: 1,
                            );
                          },
                          checkToShowHorizontalLine: (value) => true,
                        ),
                        extraLinesData: ExtraLinesData(
                          horizontalLines: [
                            HorizontalLine(
                              y: chartData.dailyWalletTarget * _animation.value,
                              color: Colors.redAccent.withOpacity(0.8),
                              strokeWidth: 1,
                              dashArray: [5, 5],
                            ),
                            HorizontalLine(
                              y: chartData.averageDailySpend * _animation.value,
                              color: theme.colorScheme.primary.withOpacity(0.8),
                              strokeWidth: 1,
                              dashArray: [5, 5],
                            ),
                          ],
                        ),
                        titlesData: FlTitlesData(
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 28,
                              interval: interval,
                              getTitlesWidget: (value, meta) {
                                if (value == meta.max) {
                                  return SideTitleWidget(meta: meta, child: const Text(''));
                                }
                                if (value % interval == 0) {
                                  return SideTitleWidget(
                                    meta: meta,
                                    space: 4, 
                                    child: Text(
                                      '${value.toInt()}',
                                      style: TextStyle(fontSize: 12, color: theme.colorScheme.secondary.withValues(alpha: 0.9)),
                                      textAlign: TextAlign.left,
                                    ),
                                  );
                                }
                                return SideTitleWidget(meta: meta, child: const Text(''));
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return settingsAsync.when(
                                  data: (settings) {
                                    final checkInDay = settings.getCheckInDay();
                                    final startOfWeek = DateTime(
                                      selectedDate.year, 
                                      selectedDate.month, 
                                      selectedDate.day - (selectedDate.weekday - checkInDay + 7) % 7
                                    );
                                    
                                    final date = startOfWeek.add(Duration(days: value.toInt()));
                                    final text = DateFormat.E().format(date); 
                                    
                                    final now = ref.read(clockNotifierProvider).now();
                                    final isToday = date.year == now.year && 
                                                    date.month == now.month && 
                                                    date.day == now.day;
                                    
                                    return SideTitleWidget(
                                      meta: meta,
                                      space: 4, 
                                      child: Text(
                                        text, 
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                          color: isToday ? theme.colorScheme.primary : Colors.grey,
                                        ),
                                      ),
                                    );
                                  },
                                  loading: () => SideTitleWidget(meta: meta, child: const Text('')),
                                  error: (e, s) => SideTitleWidget(meta: meta, child: const Text('')),
                                );
                              },
                              reservedSize: 24,
                            ),
                          ),
                        ),
                        barGroups: List.generate(7, (index) {
                          final spendingMap = chartData.dailyTotals[index] ?? {};
                          double currentY = 0;
                          final rodStackItems = <BarChartRodStackItem>[];
                          
                          if (categoriesAsync.hasValue) {
                            for (final category in categoriesAsync.value!) {
                              if (spendingMap.containsKey(category.id)) {
                                final amount = spendingMap[category.id]!;
                                rodStackItems.add(BarChartRodStackItem(currentY, currentY + amount, category.color));
                                currentY += amount;
                              }
                            }
                          }
                          
                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: currentY * _animation.value,
                                rodStackItems: rodStackItems.map((item) => BarChartRodStackItem(
                                  item.fromY * _animation.value, 
                                  item.toY * _animation.value, 
                                  item.color
                                )).toList(),
                                width: 16,
                                borderRadius: BorderRadius.zero,
                              )
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
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ChartLegend(color: Colors.redAccent, text: 'Daily Target'),
              const SizedBox(width: 24),
              _ChartLegend(color: theme.colorScheme.primary, text: 'Daily Average'),
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

class _WeekSelector extends ConsumerWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;

  const _WeekSelector({required this.selectedDate, required this.onDateChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    
    return settingsAsync.when(
      loading: () => const SizedBox(height: 48),
      error: (_, __) => const SizedBox(height: 48),
      data: (settings) {
        final checkInDay = settings.getCheckInDay();
        final now = ref.read(clockNotifierProvider).now();
        
        final startOfSelectedWeek = DateTime(
          selectedDate.year, 
          selectedDate.month, 
          selectedDate.day - (selectedDate.weekday - checkInDay + 7) % 7
        );
        final endOfSelectedWeek = startOfSelectedWeek.add(const Duration(days: 6));
        final startOfCurrentWeek = DateTime(
          now.year, 
          now.month, 
          now.day - (now.weekday - checkInDay + 7) % 7
        );
        
        final canGoNext = startOfSelectedWeek.isBefore(startOfCurrentWeek);

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left_rounded),
              onPressed: () => onDateChanged(startOfSelectedWeek.subtract(const Duration(days: 7))),
            ),
            const SizedBox(width: 8),
            Text(
              '${DateFormat('d MMM').format(startOfSelectedWeek)} - ${DateFormat('d MMM y').format(endOfSelectedWeek)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.chevron_right_rounded, color: canGoNext ? null : Theme.of(context).disabledColor.withOpacity(0.3)),
              onPressed: canGoNext ? () => onDateChanged(startOfSelectedWeek.add(const Duration(days: 7))) : null,
            ),
          ],
        );
      },
    );
  }
}