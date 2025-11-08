// lib/src/features/transactions/presentation/screens/recurring_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/features/transaction_hub/transactions/domain/log_filter_state.dart';
import 'package:budgit/src/core/domain/models/transaction.dart';
import 'package:budgit/src/features/transaction_hub/transactions/presentation/controllers/log_filter_controller.dart';
import 'package:budgit/src/features/transaction_hub/transactions/presentation/providers/recurring_transactions_provider.dart';
import 'package:budgit/src/features/transaction_hub/transactions/presentation/widgets/recurring_transaction_card.dart';
import 'package:budgit/src/features/transaction_hub/transactions/presentation/widgets/filter_chip_bar.dart'; // Import the new widget

class RecurringScreen extends ConsumerWidget {
  const RecurringScreen({super.key});

  Future<bool> _showDeleteConfirmationDialog({
    required BuildContext context,
    required Transaction transaction,
  }) async {
    final name = transaction is RecurringPayment
        ? transaction.paymentName
        : (transaction as RecurringIncome).source;

    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Recurring Transaction?'),
          content: Text(
            "Are you sure you want to delete '$name'?\n\nThis will remove the recurring rule and all of its occurrences from the log. This action cannot be undone.",
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        );
      },
    );
    return shouldDelete ?? false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recurringAsyncValue = ref.watch(recurringTransactionsProvider);

    // --- MODIFICATION START ---
    return Column(
      children: [
        const FilterChipBar(),
        Expanded(
          child: switch (recurringAsyncValue) {
            // We now handle loading and data states together.
            AsyncData(:final value) || AsyncLoading(:final value?) =>
              _buildTransactionList(context, ref, transactions: value),
            AsyncError(:final error) => Center(child: Text('Error: $error')),
            // This handles the initial load.
            _ => const SizedBox.shrink(),
          },
        ),
      ],
    );
    // --- MODIFICATION END ---
  }

  Widget _buildTransactionList(BuildContext context, WidgetRef ref,
      {required List<Transaction> transactions}) {
    if (transactions.isEmpty) {
      final filterType = ref.read(logFilterProvider).transactionTypeFilter;
      final typeString = switch (filterType) {
        TransactionTypeFilter.all => 'items',
        TransactionTypeFilter.payment => 'payments',
        TransactionTypeFilter.income => 'income',
      };
      return Center(child: Text('No recurring $typeString found.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8.0, bottom: 80.0),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final item = transactions[index];
        return Dismissible(
          key: Key(item.id),
          background: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          direction: DismissDirection.endToStart,
          confirmDismiss: (direction) async {
            final bool confirmed = await _showDeleteConfirmationDialog(
              context: context,
              transaction: item,
            );
            
            if (confirmed) {
              await ref
                  .read(recurringTransactionsProvider.notifier)
                  .removeTransaction(item.id);
            }
            
            return confirmed;
          },
          onDismissed: (direction) {
            final name = item is RecurringPayment
                ? item.paymentName
                : (item as RecurringIncome).source;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$name rule deleted')),
            );
          },
          child: RecurringTransactionCard(transaction: item),
        );
      },
    );
  }
}