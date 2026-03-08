import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:budgit/src/core/data/providers/category_list_provider.dart';
import 'package:budgit/src/features/settings/data/settings_provider.dart';
import 'package:budgit/src/utils/clock_provider.dart';
import 'package:budgit/src/features/budget_hub/presentation/providers/weekly_projection_providers.dart';

// Needed for the transaction list and models
import 'package:budgit/src/core/domain/models/transaction.dart';
import 'package:budgit/src/features/transaction_hub/transactions/presentation/providers/transaction_log_provider.dart';

class WeeklyBarChart extends ConsumerStatefulWidget {
  const WeeklyBarChart({super.key});

  @override
  ConsumerState<WeeklyBarChart> createState() => _WeeklyBarChartState();
}

class _WeeklyBarChartState extends ConsumerState<WeeklyBarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  int? _selectedDayIndex;

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

    ref.read(weeklyChartDataProvider(selectedDate: now).future).then((_) {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleBarTap(int dayIndex, DateTime selectedDate) async {
    final settings = await ref.read(settingsProvider.future);
    final checkInDay = settings.getCheckInDay();

    final startOfSelectedWeek = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day - (selectedDate.weekday - checkInDay + 7) % 7,
    );
    final tappedDate = startOfSelectedWeek.add(Duration(days: dayIndex));

    final occurrences = await ref.read(
      allTransactionOccurrencesProvider.future,
    );

    final dayTxs = occurrences.whereType<OneOffPayment>().where((tx) {
      return tx.date.year == tappedDate.year &&
          tx.date.month == tappedDate.month &&
          tx.date.day == tappedDate.day &&
          tx.parentRecurringId == null;
    }).toList();

    dayTxs.sort((a, b) => b.date.compareTo(a.date));

    if (dayTxs.isEmpty || !mounted) {
      // Fallback: Deselect if a tap somehow got through on an empty day
      setState(() => _selectedDayIndex = null);
      return;
    }

    // --- FIX 2: Await the bottom sheet so we know when it closes ---
    await _showDayTransactions(context, tappedDate, dayTxs);
  }

  // --- FIX 2: Change to Future<void> to await closure ---
  Future<void> _showDayTransactions(
    BuildContext context,
    DateTime date,
    List<OneOffPayment> transactions,
  ) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final theme = Theme.of(context);
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.85,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  DateFormat('EEEE, MMMM d').format(date),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final tx = transactions[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Color(tx.category.colorValue),
                          child: Icon(
                            IconData(
                              tx.category.iconCodePoint,
                              fontFamily: tx.category.iconFontFamily,
                              fontPackage: tx.category.iconFontPackage,
                            ),
                            color: tx.category.contentColor,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          tx.itemName,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          'Variable',
                          style: TextStyle(
                            color: theme.colorScheme.secondary,
                            fontSize: 12,
                          ),
                        ),
                        trailing: Text(
                          "-\$${tx.amount.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    // --- FIX 2: Deselect the day automatically when the sheet finishes closing ---
    if (mounted) {
      setState(() {
        _selectedDayIndex = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(weeklyDateProvider);
    final chartDataAsync = ref.watch(
      weeklyChartDataProvider(selectedDate: selectedDate),
    );
    final categoriesAsync = ref.watch(categoryListProvider);
    final settingsAsync = ref.watch(settingsProvider);
    final theme = Theme.of(context);

    ref.listen(weeklyChartDataProvider(selectedDate: selectedDate), (_, __) {
      _controller.forward(from: 0.0);
    });

    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: SizedBox(
              height: 220,
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
                      return Stack(
                        children: [
                          BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              barTouchData: BarTouchData(enabled: false),
                              minY: -0.1,
                              maxY: roundedMaxY + 0.1,
                              borderData: FlBorderData(show: false),
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                horizontalInterval: interval,
                                getDrawingHorizontalLine: (value) {
                                  return FlLine(
                                    color: theme.dividerColor.withValues(
                                      alpha: 0.1,
                                    ),
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
                                    color: theme.colorScheme.primary
                                        .withOpacity(0.8),
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
                                          final text = DateFormat.E().format(
                                            date,
                                          );

                                          final now = ref
                                              .read(clockNotifierProvider)
                                              .now();
                                          final isToday =
                                              date.year == now.year &&
                                              date.month == now.month &&
                                              date.day == now.day;

                                          final isSelected =
                                              _selectedDayIndex ==
                                              value.toInt();

                                          return SideTitleWidget(
                                            meta: meta,
                                            space: 4,
                                            child: Text(
                                              text,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight:
                                                    isSelected || isToday
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                                color: isSelected || isToday
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
                                final isSelected =
                                    _selectedDayIndex == null ||
                                    _selectedDayIndex == index;
                                final opacity = isSelected ? 1.0 : 0.3;

                                final spendingMap =
                                    chartData.dailyTotals[index] ?? {};
                                double currentY = 0;
                                final rodStackItems = <BarChartRodStackItem>[];

                                if (categoriesAsync.hasValue) {
                                  for (final category
                                      in categoriesAsync.value!) {
                                    if (spendingMap.containsKey(category.id)) {
                                      final amount = spendingMap[category.id]!;
                                      rodStackItems.add(
                                        BarChartRodStackItem(
                                          currentY,
                                          currentY + amount,
                                          category.color.withValues(
                                            alpha: opacity,
                                          ),
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
                                      color: Colors.transparent,
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
                          ),

                          Positioned.fill(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 28.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: List.generate(7, (index) {
                                  final isSelected = _selectedDayIndex == index;

                                  // --- FIX 1: Verify this day has transactions before allowing selection ---
                                  final spendingMap =
                                      chartData.dailyTotals[index] ?? {};
                                  final hasTransactions =
                                      spendingMap.values.fold(
                                        0.0,
                                        (sum, amount) => sum + amount,
                                      ) >
                                      0;

                                  return Expanded(
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () {
                                        // Ignore the tap entirely if there is no spending recorded
                                        if (!hasTransactions) return;

                                        setState(() {
                                          _selectedDayIndex =
                                              _selectedDayIndex == index
                                              ? null
                                              : index;
                                        });

                                        if (_selectedDayIndex != null) {
                                          _handleBarTap(index, selectedDate);
                                        }
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 2,
                                          vertical: 0,
                                        ),
                                        decoration: isSelected
                                            ? BoxDecoration(
                                                border: Border.all(
                                                  color:
                                                      theme.colorScheme.primary,
                                                  width: 2,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                color: theme.colorScheme.primary
                                                    .withValues(alpha: 0.05),
                                              )
                                            : null,
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ),
                        ],
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
