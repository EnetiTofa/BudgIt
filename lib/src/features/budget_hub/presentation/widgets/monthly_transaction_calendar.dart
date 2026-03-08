// lib/src/features/budget_hub/presentation/widgets/monthly_transaction_calendar.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:budgit/src/core/domain/models/transaction.dart';
import 'package:budgit/src/features/transaction_hub/transactions/presentation/providers/transaction_log_provider.dart';
import 'package:budgit/src/utils/clock_provider.dart';

class MonthlyTransactionCalendar extends ConsumerWidget {
  final DateTime selectedMonth;
  final String? categoryId;

  const MonthlyTransactionCalendar({
    super.key,
    required this.selectedMonth,
    this.categoryId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final allOccurrencesAsync = ref.watch(allTransactionOccurrencesProvider);

    return allOccurrencesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('Error loading calendar')),
      data: (occurrences) {
        final allPayments = occurrences.whereType<OneOffPayment>();

        final monthTxs = allPayments.where((tx) {
          final isSameMonth =
              tx.date.year == selectedMonth.year &&
              tx.date.month == selectedMonth.month;
          if (!isSameMonth) return false;
          if (categoryId != null) return tx.category.id == categoryId;
          return true;
        }).toList();

        final txsByDay = <int, List<OneOffPayment>>{};
        for (var tx in monthTxs) {
          txsByDay.putIfAbsent(tx.date.day, () => []).add(tx);
        }

        final firstDayOfMonth = DateTime(
          selectedMonth.year,
          selectedMonth.month,
          1,
        );
        final daysInMonth = DateUtils.getDaysInMonth(
          selectedMonth.year,
          selectedMonth.month,
        );

        final prevMonth = DateTime(selectedMonth.year, selectedMonth.month - 1);
        final nextMonth = DateTime(selectedMonth.year, selectedMonth.month + 1);
        final daysInPrevMonth = DateUtils.getDaysInMonth(
          prevMonth.year,
          prevMonth.month,
        );

        // --- SHIFTED TO SUNDAY START ---
        // Dart's DateTime.weekday is 1 for Mon, 7 for Sun.
        // Modulo 7 converts Sunday to 0, Monday to 1, etc.
        final leadingSpaces = firstDayOfMonth.weekday % 7;
        final totalCells = leadingSpaces + daysInMonth;
        final trailingSpaces = (7 - (totalCells % 7)) % 7;
        final totalGridCells = totalCells + trailingSpaces;

        // Labels shifted to Sunday first
        final labels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16.0),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Activity Calendar',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: labels
                    .map(
                      (label) => Expanded(
                        child: Center(
                          child: Text(
                            label,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 8),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  childAspectRatio: 0.95,
                ),
                itemCount: totalGridCells,
                itemBuilder: (context, index) {
                  int day;
                  bool isCurrentMonth = true;

                  if (index < leadingSpaces) {
                    day = daysInPrevMonth - leadingSpaces + index + 1;
                    isCurrentMonth = false;
                  } else if (index >= leadingSpaces + daysInMonth) {
                    day = index - (leadingSpaces + daysInMonth) + 1;
                    isCurrentMonth = false;
                  } else {
                    day = index - leadingSpaces + 1;
                  }

                  final date = isCurrentMonth
                      ? DateTime(selectedMonth.year, selectedMonth.month, day)
                      : (index < leadingSpaces
                            ? DateTime(prevMonth.year, prevMonth.month, day)
                            : DateTime(nextMonth.year, nextMonth.month, day));

                  final List<OneOffPayment> dayTxs = isCurrentMonth
                      ? (txsByDay[day] ?? <OneOffPayment>[])
                      : <OneOffPayment>[];

                  final uniqueColors = dayTxs
                      .map((t) => Color(t.category.colorValue))
                      .toSet()
                      .take(3)
                      .toList();

                  final now = ref.watch(clockNotifierProvider).now();
                  final isToday = DateUtils.isSameDay(date, now);

                  return InkWell(
                    onTap: !isCurrentMonth || dayTxs.isEmpty
                        ? null
                        : () => _showDayTransactions(context, date, dayTxs),
                    borderRadius: BorderRadius.circular(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: isToday
                              ? BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  shape: BoxShape.circle,
                                )
                              : null,
                          alignment: Alignment.center,
                          child: Text(
                            '$day',
                            style: TextStyle(
                              fontWeight: isToday || dayTxs.isNotEmpty
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              // --- COLOR FIX FOR NUMBERS ---
                              color: isToday
                                  ? theme
                                        .colorScheme
                                        .onPrimary // Keep today's text white/onPrimary to contrast circle
                                  : (isCurrentMonth
                                        ? theme
                                              .colorScheme
                                              .primary // Primary color for active month days
                                        : theme.colorScheme.onSurfaceVariant
                                              .withOpacity(
                                                0.3,
                                              )), // Faded color for ghost days
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        if (dayTxs.isNotEmpty && isCurrentMonth)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: uniqueColors
                                .map(
                                  (c) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 1.0,
                                    ),
                                    child: Container(
                                      width: 4,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: c,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          )
                        else
                          const SizedBox(height: 4),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDayTransactions(
    BuildContext context,
    DateTime date,
    List<OneOffPayment> transactions,
  ) {
    showModalBottomSheet(
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
                      final isVariable = tx.parentRecurringId == null;

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
                          isVariable ? 'Variable' : 'Fixed',
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
  }
}
