import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:budgit/src/core/domain/models/transaction.dart';
import 'package:budgit/src/features/transaction_hub/transactions/presentation/providers/transaction_log_provider.dart';

class RecentTransactionsList extends ConsumerStatefulWidget {
  final String? categoryId; // If null, shows all variable transactions
  final DateTime weekStartDate;
  final DateTime weekEndDate;

  const RecentTransactionsList({
    super.key,
    this.categoryId,
    required this.weekStartDate,
    required this.weekEndDate,
  });

  @override
  ConsumerState<RecentTransactionsList> createState() =>
      _RecentTransactionsListState();
}

class _RecentTransactionsListState
    extends ConsumerState<RecentTransactionsList> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allOccurrencesAsync = ref.watch(allTransactionOccurrencesProvider);

    return allOccurrencesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const SizedBox.shrink(),
      data: (occurrences) {
        // Filter for variable transactions in the current week
        var variableTxs = occurrences.whereType<OneOffPayment>().where((tx) {
          final isVariable = tx.parentRecurringId == null;
          final isInWeek =
              !tx.date.isBefore(widget.weekStartDate) &&
              tx.date.isBefore(widget.weekEndDate);

          if (widget.categoryId != null) {
            return isVariable &&
                isInWeek &&
                tx.category.id == widget.categoryId;
          }
          return isVariable && isInWeek;
        }).toList();

        // Sort newest first
        variableTxs.sort((a, b) => b.date.compareTo(a.date));

        // Determine how many to show
        final displayCount = _isExpanded ? variableTxs.length.clamp(0, 5) : 1;
        final displayedTxs = variableTxs.take(displayCount).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.categoryId == null
                  ? "Recent Activity"
                  : "Recent in Category",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // --- The Card Background is now ALWAYS rendered ---
            Container(
              decoration: BoxDecoration(
                color: theme
                    .colorScheme
                    .surfaceContainerLowest, // or surfaceContainerLow depending on your preference
                borderRadius: BorderRadius.circular(16),
              ),
              child: variableTxs.isEmpty
                  // A: What to show when there are NO transactions
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: Center(
                        child: Text(
                          'No recent transactions.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    )
                  // B: What to show when there ARE transactions
                  : Column(
                      children: [
                        ...displayedTxs.map((tx) {
                          final isLast = tx == displayedTxs.last;
                          return Column(
                            children: [
                              ListTile(
                                dense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 4,
                                ),
                                leading: CircleAvatar(
                                  backgroundColor: Color(
                                    tx.category.colorValue,
                                  ),
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
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  DateFormat('EEE, MMM d').format(tx.date),
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                trailing: Text(
                                  "-\$${tx.amount.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              if (!isLast)
                                Divider(
                                  height: 1,
                                  indent: 16,
                                  endIndent: 16,
                                  color:
                                      theme.colorScheme.surfaceContainerHighest,
                                ),
                            ],
                          );
                        }),
                        if (variableTxs.length > 1)
                          InkWell(
                            onTap: () {
                              setState(() {
                                _isExpanded = !_isExpanded;
                              });
                            },
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(16),
                            ),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color: theme
                                        .colorScheme
                                        .surfaceContainerHighest,
                                  ),
                                ),
                              ),
                              child: Text(
                                _isExpanded ? "Show Less" : "Show More",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }
}
