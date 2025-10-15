import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/features/categories/presentation/providers/category_list_provider.dart';
import 'package:budgit/src/features/wallet/presentation/providers/wallet_bar_chart_provider.dart';
import 'package:intl/intl.dart';
import 'package:budgit/src/features/settings/presentation/settings_provider.dart';
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
    // When the data is first loaded, start the animation.
    ref.read(walletBarChartDataProvider.future).then((_) {
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
    final chartDataAsync = ref.watch(walletBarChartDataProvider);
    final categoriesAsync = ref.watch(categoryListProvider);
    final settingsAsync = ref.watch(settingsProvider);
    final theme = Theme.of(context);

    // Refresh animation if the data changes
    ref.listen(walletBarChartDataProvider, (_, __) {
      _controller.forward(from: 0.0);
    });

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            'Weekly Spending Chart',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: chartDataAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e,s) => const Center(child: Text('Error')),
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
                          horizontalInterval: interval, // Use the fixed interval for grid lines
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
                            // This is the target spending line
                            HorizontalLine(
                              y: chartData.dailyWalletTarget * _animation.value,
                              color: Colors.redAccent.withOpacity(0.8),
                              strokeWidth: 2,
                              dashArray: [5, 5],
                            ),
                            // This is the average spending line
                            HorizontalLine(
                              y: chartData.averageDailySpend * _animation.value,
                              color: theme.colorScheme.primary.withOpacity(0.8),
                              strokeWidth: 2,
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
                                  return const SizedBox.shrink();
                                }
                                if (value % interval == 0) {
                                  return Text(
                                    '${value.toInt()}',
                                    style: TextStyle(fontSize: 12, color: theme.colorScheme.secondary.withValues(alpha: 0.9)),
                                    textAlign: TextAlign.left,
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                // V-- Now handle the async value here
                                return settingsAsync.when(
                                  data: (settings) {
                                    final checkInDay = settings.getCheckInDay();
                                    
                                    final now = ref.read(clockNotifierProvider).now();
                                    final startOfWeek = DateTime(now.year, now.month, now.day - (now.weekday - checkInDay + 7) % 7);
                                    final date = startOfWeek.add(Duration(days: value.toInt()));
                                    final text = DateFormat.E().format(date); 
                                    final isToday = now.difference(startOfWeek).inDays == value.toInt();
                                    return SideTitleWidget(
                                      axisSide: meta.axisSide, 
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
                                  loading: () => const SizedBox.shrink(),
                                  error: (e, s) => const SizedBox.shrink(),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ChartLegend(
                color: Colors.redAccent,
                text: 'Daily Target',
              ),
              const SizedBox(width: 24), // Add space between the items
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
        Container(
          width: 16,
          height: 4,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          // V-- Apply the secondary color from your theme
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}