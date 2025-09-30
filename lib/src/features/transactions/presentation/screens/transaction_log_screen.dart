import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:budgit/src/features/transactions/data/transaction_repository_provider.dart';
import 'package:budgit/src/features/transactions/domain/log_filter_state.dart';
import 'package:budgit/src/features/transactions/domain/transaction.dart';
import 'package:budgit/src/features/transactions/presentation/controllers/log_filter_controller.dart';
import 'package:budgit/src/features/transactions/presentation/providers/transaction_log_provider.dart';
import 'package:budgit/src/features/transactions/presentation/screens/edit_income_screen.dart';
import 'package:budgit/src/features/transactions/presentation/screens/edit_payment_screen.dart';
import 'package:budgit/src/features/transactions/presentation/providers/dropdown_active_provider.dart';

class TransactionLogScreen extends ConsumerWidget {
  const TransactionLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsyncValue = ref.watch(transactionLogProvider);
    final filterState = ref.watch(logFilterProvider);
    final isDropdownActive = ref.watch(dropdownActiveProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return switch (transactionsAsyncValue) {
      AsyncLoading() => Center(child: CircularProgressIndicator(color: colorScheme.surface)),
      AsyncError(:final error) => Center(child: Text('Error: $error')),
      AsyncData(:final value) => value.isEmpty
          ? const Center(child: Text('No transactions found.'))
          : GroupedListView<Transaction, String>(
              elements: value,
              groupBy: (transaction) {
                final date = transaction is OneOffPayment ? transaction.date : (transaction as OneOffIncome).date;
                switch (filterState.sortBy) {
                  case SortBy.category:
                    return transaction is OneOffPayment ? transaction.category.name : 'Income';
                  case SortBy.store:
                    return transaction is OneOffPayment ? transaction.store : 'Income';
                  case SortBy.date:
                    return DateFormat.yMMMd().format(date);
                }
              },
              groupSeparatorBuilder: (String groupByValue) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: isDropdownActive 
                    ? colorScheme.surface 
                    : colorScheme.surfaceContainerLowest,
                child: Text(
                  groupByValue,
                  style: TextStyle(fontWeight: FontWeight.w600, color: colorScheme.secondary),
                ),
              ),
              itemBuilder: (context, transaction) {
                String? parentId;
                Widget listTileContent;
                if (transaction is OneOffPayment) {
                  parentId = transaction.parentRecurringId;
                  listTileContent = ListTile(
                    leading: CircleAvatar(
                      backgroundColor: transaction.category.color,
                      // UPDATED LOGIC TO DISPLAY CUSTOM ICON
                      child: Icon(
                        transaction.iconCodePoint != null
                            ? IconData(transaction.iconCodePoint!, fontFamily: transaction.iconFontFamily)
                            : transaction.category.icon,
                        color: colorScheme.surface,
                      ),
                    ),
                    title: Text(transaction.itemName, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(transaction.store),
                    trailing: Text(
                      '-\$${transaction.amount.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  );
                } else if (transaction is OneOffIncome) {
                  parentId = transaction.parentRecurringId;
                  listTileContent = ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green,
                      child: Icon(
                        IconData(transaction.iconCodePoint, fontFamily: transaction.iconFontFamily),
                        color: colorScheme.surface,
                      ),
                    ),
                    title: Text(transaction.source, maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: Text(
                      '+\$${transaction.amount.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  );
                } else {
                  listTileContent = const ListTile(title: Text('Unknown transaction type'));
                }

                final dismissDirection = parentId != null
                    ? DismissDirection.none
                    : DismissDirection.endToStart;

                final VoidCallback onTapAction = parentId != null
                    ? () async {
                        final repo = ref.read(transactionRepositoryProvider);
                        final parentTx = await repo.getTransactionById(parentId!); 
                        if (parentTx != null && context.mounted) {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => parentTx is RecurringPayment
                                ? EditPaymentScreen(transaction: parentTx)
                                : EditIncomeScreen(transaction: parentTx),
                          ));
                        }
                      }
                    : () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => transaction is OneOffPayment
                              ? EditPaymentScreen(transaction: transaction)
                              : EditIncomeScreen(transaction: transaction),
                        ));
                      };

                if (listTileContent is ListTile) {
                  listTileContent = ListTile(
                    leading: listTileContent.leading,
                    title: listTileContent.title,
                    subtitle: listTileContent.subtitle,
                    trailing: listTileContent.trailing,
                    onTap: onTapAction,
                  );
                }

                return Dismissible(
                  key: Key(transaction.id),
                  direction: dismissDirection,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    ref.read(allTransactionOccurrencesProvider.notifier).removeTransaction(transaction.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Transaction deleted')),
                    );
                  },
                  child: listTileContent,
                );
              },
              order: GroupedListOrder.DESC,
            ),
      _ => const SizedBox.shrink(),
    };
  }
}