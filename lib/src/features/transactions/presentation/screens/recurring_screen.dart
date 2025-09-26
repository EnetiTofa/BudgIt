import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/features/transactions/domain/log_filter_state.dart';
import 'package:budgit/src/features/transactions/domain/transaction.dart';
import 'package:budgit/src/features/transactions/presentation/controllers/log_filter_controller.dart';
import 'package:budgit/src/features/transactions/presentation/providers/recurring_transactions_provider.dart';
// The transactionLogProvider is no longer needed here for invalidation
// import 'package:budgit/src/features/transactions/presentation/providers/transaction_log_provider.dart';
import 'package:budgit/src/features/transactions/presentation/widgets/recurring_transaction_card.dart';

class RecurringScreen extends ConsumerWidget {
  const RecurringScreen({super.key});

  /// Shows a confirmation dialog before deleting a recurring transaction.
  /// This will be called by the `confirmDismiss` property of the Dismissible widget.
  /// It returns `true` if the user confirms the deletion, and `false` otherwise.
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

    // If shouldDelete is null (e.g., dialog dismissed by tapping outside),
    // treat it as a cancellation. Return true only if the user explicitly tapped "Delete".
    return shouldDelete ?? false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recurringAsyncValue = ref.watch(recurringTransactionsProvider);

    return switch (recurringAsyncValue) {
      AsyncLoading() => const Center(child: CircularProgressIndicator()),
      AsyncError(:final error) => Center(child: Text('Error: $error')),
      AsyncData(:final value) =>
        _buildTransactionList(context, ref, transactions: value),
      _ => const SizedBox.shrink(),
    };
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
          // --- NEW: Use confirmDismiss to show the dialog ---
          confirmDismiss: (direction) async {
            final bool confirmed = await _showDeleteConfirmationDialog(
              context: context,
              transaction: item,
            );
            
            // If the user confirmed, we proceed with the deletion.
            if (confirmed) {
              await ref
                  .read(recurringTransactionsProvider.notifier)
                  .removeTransaction(item.id);
            }
            
            // Return the result to the Dismissible widget.
            // If true, it will proceed with the dismiss animation.
            // If false, it will animate back to its original position.
            return confirmed;
          },
          // --- UPDATED: onDismissed now only shows the SnackBar ---
          // This code only runs IF confirmDismiss returns true.
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