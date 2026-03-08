// lib/src/features/check_in/presentation/pages/first_time_weekly_log_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:grouped_list/grouped_list.dart';

import 'package:budgit/src/core/domain/models/transaction.dart';
import 'package:budgit/src/features/check_in/presentation/controllers/check_in_controller.dart';
import 'package:budgit/src/core/data/providers/category_list_provider.dart';
import 'package:budgit/src/features/settings/data/settings_provider.dart';
import 'package:budgit/src/features/transaction_hub/transactions/presentation/screens/add_payment_screen.dart';
import 'package:budgit/src/features/transaction_hub/transactions/presentation/screens/edit_payment_screen.dart';
import 'package:budgit/src/features/transaction_hub/transactions/domain/log_filter_state.dart';
import 'package:budgit/src/features/transaction_hub/transactions/presentation/controllers/log_filter_controller.dart';
import 'package:budgit/src/features/transaction_hub/transactions/presentation/providers/transaction_log_provider.dart';

class FirstTimeWeeklyLogPage extends ConsumerStatefulWidget {
  const FirstTimeWeeklyLogPage({super.key});

  @override
  ConsumerState<FirstTimeWeeklyLogPage> createState() =>
      _FirstTimeWeeklyLogPageState();
}

class _FirstTimeWeeklyLogPageState
    extends ConsumerState<FirstTimeWeeklyLogPage> {
  int? _selectedDayIndex;
  late final dynamic _filterNotifier;

  DateTime? _weekStart;
  DateTime? _todayClean;

  @override
  void initState() {
    super.initState();
    _filterNotifier = ref.read(logFilterProvider.notifier);
    _setupFirstTimeFilters();
  }

  Future<void> _setupFirstTimeFilters() async {
    final settingsRepo = await ref.read(settingsProvider.future);
    final int checkInDay = settingsRepo.getCheckInDay();

    final now = DateTime.now();
    final todayClean = DateTime(now.year, now.month, now.day);

    DateTime weekStart = todayClean;
    while (weekStart.weekday != checkInDay) {
      weekStart = weekStart.subtract(const Duration(days: 1));
    }

    if (mounted) {
      setState(() {
        _weekStart = weekStart;
        _todayClean = todayClean;
      });
      _filterNotifier.setDateRange(weekStart, todayClean);
    }
  }

  @override
  void dispose() {
    Future.microtask(() {
      _filterNotifier.setDateRange(null, null);
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_weekStart == null || _todayClean == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final state = ref.watch(checkInControllerProvider);
    final categories = ref.watch(categoryListProvider).valueOrNull ?? [];
    final transactionsAsyncValue = ref.watch(transactionLogProvider);
    final filterState = ref.watch(logFilterProvider);

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final dailyTotals = List.generate(7, (_) => <String, double>{});
    double maxY = 10.0;

    for (final tx in state.weekTransactions) {
      if (tx is OneOffPayment) {
        final txDateClean = DateTime(tx.date.year, tx.date.month, tx.date.day);
        final dayIndex = txDateClean.difference(_weekStart!).inDays;

        if (dayIndex >= 0 && dayIndex < 7) {
          dailyTotals[dayIndex][tx.category.id] =
              (dailyTotals[dayIndex][tx.category.id] ?? 0.0) + tx.amount;
        }
      }
    }

    for (final dayMap in dailyTotals) {
      final dayTotal = dayMap.values.fold(0.0, (sum, val) => sum + val);
      if (dayTotal > maxY) maxY = dayTotal;
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: Column(
            children: [
              Text(
                "Log Your Spending",
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "Add any transactions you've made since the start of your budget week to ensure your balances are accurate.",
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.secondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            _selectedDayIndex == null
                ? 'Showing spending up to Today'
                : 'Showing spending for ${DateFormat('EEEE, MMM d').format(_weekStart!.add(Duration(days: _selectedDayIndex!)))}.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.secondary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(
          height: 220,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 4),
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      minY: 0,
                      maxY: maxY * 1.2,
                      barTouchData: BarTouchData(enabled: false),
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: theme.dividerColor.withOpacity(0.1),
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
                              final date = _weekStart!.add(
                                Duration(days: value.toInt()),
                              );
                              final isSelected =
                                  _selectedDayIndex == value.toInt();
                              final isToday = date.isAtSameMomentAs(
                                _todayClean!,
                              );
                              final isFuture = date.isAfter(_todayClean!);

                              return SideTitleWidget(
                                meta: meta,
                                space: 8,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      DateFormat.E().format(date),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: isSelected || isToday
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: isSelected
                                            ? theme.colorScheme.primary
                                            : isFuture
                                            ? theme.colorScheme.onSurface
                                                  .withOpacity(0.2)
                                            : isToday
                                            ? theme.colorScheme.primary
                                            : theme.colorScheme.secondary,
                                      ),
                                    ),
                                    if (isToday)
                                      Container(
                                        margin: const EdgeInsets.only(top: 2),
                                        width: 4,
                                        height: 4,
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primary,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      barGroups: List.generate(7, (index) {
                        final date = _weekStart!.add(Duration(days: index));
                        final isFuture = date.isAfter(_todayClean!);
                        final isSelected =
                            _selectedDayIndex == null ||
                            _selectedDayIndex == index;
                        final opacity = isFuture
                            ? 0.1
                            : (isSelected ? 1.0 : 0.3);

                        double currentY = 0;
                        final rodStackItems = <BarChartRodStackItem>[];

                        if (!isFuture) {
                          for (final category in categories) {
                            if (dailyTotals[index].containsKey(category.id)) {
                              final amount = dailyTotals[index][category.id]!;
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
                        }

                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: currentY > 0 ? currentY : 0.1,
                              rodStackItems: rodStackItems,
                              width: 20,
                              borderRadius: BorderRadius.circular(4),
                              color: theme.colorScheme.surfaceContainerHighest
                                  .withOpacity(opacity),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: List.generate(7, (index) {
                      final date = _weekStart!.add(Duration(days: index));
                      final isFuture = date.isAfter(_todayClean!);
                      final isSelected = _selectedDayIndex == index;

                      return Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: isFuture
                              ? null
                              : () {
                                  setState(() {
                                    _selectedDayIndex =
                                        _selectedDayIndex == index
                                        ? null
                                        : index;
                                  });

                                  if (_selectedDayIndex == null) {
                                    _filterNotifier.setDateRange(
                                      _weekStart!,
                                      _todayClean!,
                                    );
                                  } else {
                                    final selectedDate = _weekStart!.add(
                                      Duration(days: index),
                                    );
                                    _filterNotifier.setDateRange(
                                      selectedDate,
                                      selectedDate,
                                    );
                                  }
                                },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: isSelected
                                ? BoxDecoration(
                                    border: Border.all(
                                      color: theme.colorScheme.primary,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    color: theme.colorScheme.primary
                                        .withOpacity(0.05),
                                  )
                                : null,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: OutlinedButton.icon(
            onPressed: () async {
              final defaultDate = _selectedDayIndex != null
                  ? _weekStart!.add(Duration(days: _selectedDayIndex!))
                  : _todayClean!;

              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AddPaymentScreen(
                    initialDate: defaultDate,
                    minDate: _weekStart,
                    maxDate: _todayClean,
                  ),
                ),
              );
              ref.read(checkInControllerProvider.notifier).refreshData();
            },
            icon: const Icon(Icons.add),
            label: Text(
              _selectedDayIndex == null
                  ? 'Add Payment for Today'
                  : 'Add Payment for ${DateFormat('EEEE').format(_weekStart!.add(Duration(days: _selectedDayIndex!)))}',
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ),
        Expanded(
          child: switch (transactionsAsyncValue) {
            AsyncData(:final value) || AsyncLoading(:final value?) =>
              value.isEmpty
                  ? Center(
                      child: Text(
                        'No spending recorded.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                    )
                  : GroupedListView<Transaction, String>(
                      elements: value,
                      groupBy: (transaction) {
                        final date = transaction is OneOffPayment
                            ? transaction.date
                            : (transaction as OneOffIncome).date;
                        switch (filterState.sortBy) {
                          case SortBy.category:
                            return transaction is OneOffPayment
                                ? transaction.category.name
                                : 'Income';
                          case SortBy.store:
                            return transaction is OneOffPayment
                                ? transaction.store
                                : 'Income';
                          case SortBy.date:
                            return DateFormat('yyyy-MM-dd').format(date);
                          case SortBy.amount:
                            return 'Sorted by Amount';
                        }
                      },
                      groupSeparatorBuilder: (String groupByValue) {
                        String headerText;
                        if (filterState.sortBy == SortBy.date) {
                          final date = DateTime.parse(groupByValue);
                          headerText = date.isAtSameMomentAs(_todayClean!)
                              ? 'Today'
                              : DateFormat.yMMMd().format(date);
                        } else {
                          headerText = groupByValue;
                        }
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          color: colorScheme.surfaceContainerLowest,
                          child: Text(
                            headerText,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.secondary,
                            ),
                          ),
                        );
                      },
                      itemBuilder: (context, transaction) {
                        if (transaction is! OneOffPayment) {
                          return const SizedBox.shrink();
                        }

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Color(
                              transaction.category.colorValue,
                            ),
                            child: Icon(
                              transaction.iconCodePoint != null
                                  ? IconData(
                                      transaction.iconCodePoint!,
                                      fontFamily: transaction.iconFontFamily,
                                      fontPackage: transaction.iconFontPackage,
                                    )
                                  : transaction.category.icon,
                              color: colorScheme.surface,
                            ),
                          ),
                          title: Text(
                            transaction.itemName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(transaction.store),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '-\$${transaction.amount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.chevron_right,
                                color: theme.colorScheme.outline,
                              ),
                            ],
                          ),
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => EditPaymentScreen(
                                  transaction: transaction,
                                  minDate: _weekStart,
                                  maxDate: _todayClean,
                                ),
                              ),
                            );
                            ref
                                .read(checkInControllerProvider.notifier)
                                .refreshData();
                          },
                        );
                      },
                      order: GroupedListOrder.DESC,
                    ),
            AsyncError(:final error) => Center(child: Text('Error: $error')),
            _ => const SizedBox.shrink(),
          },
        ),
      ],
    );
  }
}
