// lib/src/features/check_in/presentation/transaction_review_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:budgit/src/core/domain/models/transaction.dart';
import 'package:budgit/src/features/check_in/presentation/controllers/check_in_controller.dart';
import 'package:budgit/src/core/data/providers/category_list_provider.dart';
import 'package:budgit/src/features/transaction_hub/transactions/presentation/screens/add_payment_screen.dart';
import 'package:budgit/src/features/transaction_hub/transactions/presentation/screens/edit_payment_screen.dart';

class TransactionReviewPage extends ConsumerStatefulWidget {
  const TransactionReviewPage({super.key});

  @override
  ConsumerState<TransactionReviewPage> createState() => _TransactionReviewPageState();
}

class _TransactionReviewPageState extends ConsumerState<TransactionReviewPage> {
  int? _selectedDayIndex;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(checkInControllerProvider);
    final categories = ref.watch(categoryListProvider).valueOrNull ?? [];
    final theme = Theme.of(context);

    // 1. Calculate the start of the Check-In week
    final checkInEnd = state.checkInWeekDate ?? DateTime.now();
    final startOfWeek = DateTime(checkInEnd.year, checkInEnd.month, checkInEnd.day - 6);

    // 2. Aggregate data for the chart
    final dailyTotals = List.generate(7, (_) => <String, double>{});
    double maxY = 10.0;

    for (final tx in state.weekTransactions) {
      if (tx is OneOffPayment) {
        final txDateClean = DateTime(tx.date.year, tx.date.month, tx.date.day);
        final dayIndex = txDateClean.difference(startOfWeek).inDays;
        
        if (dayIndex >= 0 && dayIndex < 7) {
          dailyTotals[dayIndex][tx.category.id] = (dailyTotals[dayIndex][tx.category.id] ?? 0.0) + tx.amount;
        }
      }
    }

    for (final dayMap in dailyTotals) {
      final dayTotal = dayMap.values.fold(0.0, (sum, val) => sum + val);
      if (dayTotal > maxY) maxY = dayTotal;
    }

    // 3. Filter transactions based on selection
    final displayedTransactions = state.weekTransactions.where((tx) {
      if (_selectedDayIndex == null) return true;
      if (tx is! OneOffPayment) return false;
      final txDateClean = DateTime(tx.date.year, tx.date.month, tx.date.day);
      return txDateClean.difference(startOfWeek).inDays == _selectedDayIndex;
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Review Last Week', 
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center
                ),
              const SizedBox(height: 8),
              Text(
                _selectedDayIndex == null 
                    ? 'Tap a day to filter transactions.' 
                    : 'Showing transactions for ${DateFormat('EEEE, MMM d').format(startOfWeek.add(Duration(days: _selectedDayIndex!)))}.',
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.secondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        // --- INTERACTIVE CHART WITH STACK OVERLAY ---
        SizedBox(
          height: 220, // Slightly taller to fit the highlight box
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Stack(
              children: [
                // 1. THE CHART (Underneath)
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 4),
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround, // Crucial for overlay alignment
                      minY: 0,
                      maxY: maxY * 1.2,
                      barTouchData: BarTouchData(enabled: false), // Disable fl_chart's touch logic entirely
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
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 32, // Space for labels
                            getTitlesWidget: (value, meta) {
                              final date = startOfWeek.add(Duration(days: value.toInt()));
                              final isSelected = _selectedDayIndex == value.toInt();
                              return SideTitleWidget(
                                meta: meta,
                                space: 8,
                                child: Text(
                                  DateFormat.E().format(date),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected ? theme.colorScheme.primary : theme.colorScheme.secondary,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      barGroups: List.generate(7, (index) {
                        final isSelected = _selectedDayIndex == null || _selectedDayIndex == index;
                        final opacity = isSelected ? 1.0 : 0.3;
                        
                        double currentY = 0;
                        final rodStackItems = <BarChartRodStackItem>[];
                        
                        for (final category in categories) {
                          if (dailyTotals[index].containsKey(category.id)) {
                            final amount = dailyTotals[index][category.id]!;
                            rodStackItems.add(BarChartRodStackItem(
                              currentY, 
                              currentY + amount, 
                              Color(category.colorValue).withOpacity(opacity)
                            ));
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
                              color: theme.colorScheme.surfaceContainerHighest.withOpacity(opacity),
                            )
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
                              _selectedDayIndex = _selectedDayIndex == index ? null : index;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 0),
                            decoration: isSelected
                                ? BoxDecoration(
                                    border: Border.all(color: theme.colorScheme.primary, width: 2),
                                    borderRadius: BorderRadius.circular(12),
                                    color: theme.colorScheme.primary.withOpacity(0.05),
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
                MaterialPageRoute(builder: (_) => AddPaymentScreen(initialDate: defaultDate)),
              );
              ref.read(checkInControllerProvider.notifier).refreshData();
            },
            icon: const Icon(Icons.add),
            label: Text(_selectedDayIndex == null ? 'Add Missing Payment' : 'Add Payment for ${DateFormat('EEEE').format(startOfWeek.add(Duration(days: _selectedDayIndex!)))}'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ),

        const Divider(height: 1),

        // --- TRANSACTION LIST ---
        Expanded(
          child: displayedTransactions.isEmpty
              ? Center(
                  child: Text(
                    'No spending recorded.',
                    style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.secondary),
                  ),
                )
              : ListView.separated(
                  itemCount: displayedTransactions.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final transaction = displayedTransactions[index];
                    if (transaction is! OneOffPayment) return const SizedBox.shrink();

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Color(transaction.category.colorValue),
                        child: Icon(
                          transaction.iconCodePoint != null
                              ? IconData(transaction.iconCodePoint!, fontFamily: transaction.iconFontFamily, fontPackage: transaction.iconFontPackage)
                              : Icons.category,
                          color: transaction.category.contentColor,
                        ),
                      ),
                      title: Text(transaction.itemName),
                      subtitle: Text('${DateFormat('MMM d').format(transaction.date)} • ${transaction.category.name}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '\$${transaction.amount.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.chevron_right, color: theme.colorScheme.outline),
                        ],
                      ),
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => EditPaymentScreen(transaction: transaction)),
                        );
                        ref.read(checkInControllerProvider.notifier).refreshData();
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}