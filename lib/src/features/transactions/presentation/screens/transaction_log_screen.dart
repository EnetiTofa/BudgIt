import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:budgit/src/features/transactions/domain/log_filter_state.dart';
import 'package:budgit/src/features/transactions/domain/transaction.dart';
import 'package:budgit/src/features/transactions/presentation/controllers/log_filter_controller.dart';
import 'package:budgit/src/features/transactions/presentation/providers/transaction_log_provider.dart';
import 'package:budgit/src/features/transactions/presentation/screens/edit_income_screen.dart';
import 'package:budgit/src/features/transactions/presentation/screens/edit_payment_screen.dart';
import 'package:budgit/src/features/transactions/presentation/widgets/filter_bottom_sheet.dart';
import 'package:budgit/src/features/transactions/data/transaction_repository_provider.dart';

class TransactionLogScreen extends ConsumerStatefulWidget {
  const TransactionLogScreen({super.key});

  @override
  ConsumerState<TransactionLogScreen> createState() => _TransactionLogScreenState();
}

class _TransactionLogScreenState extends ConsumerState<TransactionLogScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize the search bar with the current filter state
    _searchController.text = ref.read(logFilterProvider).searchQuery;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showSortOptions(BuildContext context) {
    // Note: We use ref.read here because we are outside the build method
    final filterController = ref.read(logFilterProvider.notifier);
    
    showDialog(
      context: context,
      builder: (context) {
        // We use a Consumer here so the dialog can rebuild when the filter state changes
        return Consumer(
          builder: (context, ref, child) {
            final filterState = ref.watch(logFilterProvider);
            return AlertDialog(
              title: const Text('Sort By'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<SortBy>(
                    title: const Text('Date'),
                    value: SortBy.date,
                    groupValue: filterState.sortBy,
                    onChanged: (val) => filterController.setSortBy(val!),
                  ),
                  RadioListTile<SortBy>(
                    title: const Text('Category'),
                    value: SortBy.category,
                    groupValue: filterState.sortBy,
                    onChanged: (val) => filterController.setSortBy(val!),
                  ),
                  RadioListTile<SortBy>(
                    title: const Text('Store / Payee'),
                    value: SortBy.store,
                    groupValue: filterState.sortBy,
                    onChanged: (val) => filterController.setSortBy(val!),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Done'),
                )
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsyncValue = ref.watch(transactionLogProvider);
    final filterController = ref.read(logFilterProvider.notifier);
    final filterState = ref.watch(logFilterProvider);

    return Column(
      children: [
        // --- Search and Filter Bar ---
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search...',
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(),
                  isDense: true,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      filterController.setSearchQuery('');
                    },
                  ),
                ),
                onChanged: filterController.setSearchQuery,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton.icon(
                    onPressed: () => _showSortOptions(context),
                    icon: const Icon(Icons.sort),
                    label: const Text('Sort'),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (_) => const FilterBottomSheet(),
                      );
                    },
                    icon: const Icon(Icons.filter_list),
                    label: const Text('Filter'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // --- Grouped Transaction List ---
        Expanded(
          child: switch (transactionsAsyncValue) {
            AsyncLoading() => const Center(child: CircularProgressIndicator()),
            AsyncError(:final error) => Center(child: Text('Error: $error')),
            AsyncData(:final value) => value.isEmpty
                ? const Center(child: Text('No transactions found.'))
                : GroupedListView<Transaction, String>(
                    elements: value,
                    groupBy: (transaction) {
                      switch (filterState.sortBy) {
                        case SortBy.category:
                          return transaction is OneOffPayment ? transaction.category.name : 'Income';
                        case SortBy.store:
                          return transaction is OneOffPayment ? transaction.store : 'Income';
                        case SortBy.date:
                          final date = transaction is OneOffPayment ? transaction.date : (transaction as OneOffIncome).date;
                          return DateFormat.yMMMd().format(date);
                      }
                    },
                    groupSeparatorBuilder: (String groupByValue) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      color: Theme.of(context).colorScheme.surfaceContainerLow,
                      child: Text(
                        groupByValue,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    itemBuilder: (context, transaction) {
                      Widget listTile;
                      String itemName = "Transaction";

                      if (transaction is OneOffPayment) {
                        itemName = transaction.itemName;
                        listTile = ListTile(
                          leading: CircleAvatar(
                            backgroundColor: transaction.category.color,
                            child: Icon(transaction.category.icon, color: Colors.white),
                          ),
                          title: Text(transaction.itemName),
                          subtitle: Text(transaction.store),
                          trailing: Text(
                            '-\$${transaction.amount.toStringAsFixed(2)}',
                            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => EditPaymentScreen(transaction: transaction),
                            ));
                          },
                        );
                      } else if (transaction is OneOffIncome) {
                        itemName = transaction.source;
                        listTile = ListTile(
                          leading: const CircleAvatar(child: Icon(Icons.attach_money)),
                          title: Text(transaction.source),
                          trailing: Text(
                            '+\$${transaction.amount.toStringAsFixed(2)}',
                            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                          ),
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => EditIncomeScreen(transaction: transaction),
                            ));
                          },
                        );
                      } else {
                        listTile = const ListTile(title: Text('Unknown transaction type'));
                      }

                      return Dismissible(
                        key: Key(transaction.id),
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) {
                          ref.read(transactionRepositoryProvider).deleteTransaction(transaction.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('$itemName deleted')),
                          );
                        },
                        child: listTile,
                      );
                    },
                    order: GroupedListOrder.DESC,
                  ),
            _ => const SizedBox.shrink(),
          },
        ),
      ],
    );
  }
}