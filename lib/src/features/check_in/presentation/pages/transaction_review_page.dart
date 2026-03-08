// lib/src/features/check_in/presentation/transaction_review_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:grouped_list/grouped_list.dart';

import 'package:budgit/src/core/domain/models/transaction.dart';
import 'package:budgit/src/features/check_in/presentation/controllers/check_in_controller.dart';
import 'package:budgit/src/core/data/providers/category_list_provider.dart';
import 'package:budgit/src/features/transaction_hub/transactions/presentation/screens/add_payment_screen.dart';
import 'package:budgit/src/features/transaction_hub/transactions/presentation/screens/edit_payment_screen.dart';

// --- NEW IMPORTS FOR FILTERING & LOGIC ---
import 'package:budgit/src/features/transaction_hub/transactions/domain/log_filter_state.dart';
import 'package:budgit/src/features/transaction_hub/transactions/presentation/controllers/log_filter_controller.dart';
import 'package:budgit/src/features/transaction_hub/transactions/presentation/providers/transaction_log_provider.dart';

class TransactionReviewPage extends ConsumerStatefulWidget {
  const TransactionReviewPage({super.key});

  @override
  ConsumerState<TransactionReviewPage> createState() =>
      _TransactionReviewPageState();
}

class _TransactionReviewPageState extends ConsumerState<TransactionReviewPage> {
  int? _selectedDayIndex;

  // --- NEW: A variable to hold our notifier safely ---
  late final dynamic _filterNotifier;

  @override
  void initState() {
    super.initState();

    // 1. Cache the notifier immediately so we don't need 'ref' during disposal
    _filterNotifier = ref.read(logFilterProvider.notifier);

    // 2. Set the global filter to the check-in week
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(checkInControllerProvider);
      final checkInEnd = state.checkInWeekDate ?? DateTime.now();
      final startOfWeek = DateTime(
        checkInEnd.year,
        checkInEnd.month,
        checkInEnd.day - 6,
      );

      _filterNotifier.setDateRange(startOfWeek, checkInEnd);
    });
  }

  @override
  void dispose() {
    // 3. Clear the date filter using our cached notifier.
    // We completely bypass the "ref was disposed" error!
    Future.microtask(() {
      _filterNotifier.setDateRange(null, null);
    });

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(checkInControllerProvider);
    final categories = ref.watch(categoryListProvider).valueOrNull ?? [];

    // --- WATCH THE SHARED LOG PROVIDERS ---
    final transactionsAsyncValue = ref.watch(transactionLogProvider);
    final filterState = ref.watch(logFilterProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final checkInEnd = state.checkInWeekDate ?? DateTime.now();
    final startOfWeek = DateTime(
      checkInEnd.year,
      checkInEnd.month,
      checkInEnd.day - 6,
    );

    // Aggregate data for the chart (This still uses state.weekTransactions so the chart always shows the whole week)
    final dailyTotals = List.generate(7, (_) => <String, double>{});
    double maxY = 10.0;

    for (final tx in state.weekTransactions) {
      if (tx is OneOffPayment) {
        final txDateClean = DateTime(tx.date.year, tx.date.month, tx.date.day);
        final dayIndex = txDateClean.difference(startOfWeek).inDays;

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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Review Last Week',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _selectedDayIndex == null
                    ? 'Tap a day to filter transactions.'
                    : 'Showing transactions for ${DateFormat('EEEE, MMM d').format(startOfWeek.add(Duration(days: _selectedDayIndex!)))}.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.secondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        // --- INTERACTIVE CHART WITH STACK OVERLAY ---
        SizedBox(
          height: 220,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Stack(
              children: [
                // 1. THE CHART (Underneath)
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
                              final date = startOfWeek.add(
                                Duration(days: value.toInt()),
                              );
                              final isSelected =
                                  _selectedDayIndex == value.toInt();
                              return SideTitleWidget(
                                meta: meta,
                                space: 8,
                                child: Text(
                                  DateFormat.E().format(date),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.secondary,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      barGroups: List.generate(7, (index) {
                        final isSelected =
                            _selectedDayIndex == null ||
                            _selectedDayIndex == index;
                        final opacity = isSelected ? 1.0 : 0.3;

                        double currentY = 0;
                        final rodStackItems = <BarChartRodStackItem>[];

                        for (final category in categories) {
                          if (dailyTotals[index].containsKey(category.id)) {
                            final amount = dailyTotals[index][category.id]!;
                            rodStackItems.add(
                              BarChartRodStackItem(
                                currentY,
                                currentY + amount,
                                Color(category.colorValue).withOpacity(opacity),
                              ),
                            );
                            currentY += amount;
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

                // 2. THE TOUCH OVERLAY (On Top)
                Positioned.fill(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: List.generate(7, (index) {
                      final isSelected = _selectedDayIndex == index;
                      return Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            setState(() {
                              _selectedDayIndex = _selectedDayIndex == index
                                  ? null
                                  : index;
                            });

                            // --- DYNAMICALLY UPDATE THE SHARED FILTER PROVIDER ---
                            if (_selectedDayIndex == null) {
                              // Revert to full week
                              ref
                                  .read(logFilterProvider.notifier)
                                  .setDateRange(startOfWeek, checkInEnd);
                            } else {
                              // Narrow down to a single selected day
                              final selectedDate = startOfWeek.add(
                                Duration(days: index),
                              );
                              ref
                                  .read(logFilterProvider.notifier)
                                  .setDateRange(selectedDate, selectedDate);
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

        // --- ADD BUTTON ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: OutlinedButton.icon(
            onPressed: () async {
              final defaultDate = _selectedDayIndex != null
                  ? startOfWeek.add(Duration(days: _selectedDayIndex!))
                  : checkInEnd;

              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AddPaymentScreen(initialDate: defaultDate),
                ),
              );
              ref.read(checkInControllerProvider.notifier).refreshData();
            },
            icon: const Icon(Icons.add),
            label: Text(
              _selectedDayIndex == null
                  ? 'Add Missing Payment'
                  : 'Add Payment for ${DateFormat('EEEE').format(startOfWeek.add(Duration(days: _selectedDayIndex!)))}',
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ),

        // --- TRANSACTION LIST (PULLED FROM TRANSACTION HUB PROVIDER) ---
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
                          headerText = DateFormat.yMMMd().format(date);
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
                        if (transaction is! OneOffPayment)
                          return const SizedBox.shrink();

                        // Visual clone of the Transaction Hub ListTile
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
                                  // --- FIX: Use the actual category icon as the fallback! ---
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
                                builder: (_) =>
                                    EditPaymentScreen(transaction: transaction),
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
