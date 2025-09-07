import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/features/transactions/domain/transaction.dart';
import 'package:budgit/src/features/transactions/presentation/providers/transaction_log_provider.dart';
import 'package:budgit/src/features/transactions/presentation/screens/edit_payment_screen.dart';
import 'package:budgit/src/features/transactions/data/transaction_repository_provider.dart';
import 'package:budgit/src/features/transactions/presentation/screens/edit_income_screen.dart';

class TransactionLogScreen extends ConsumerWidget {
  const TransactionLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsyncValue = ref.watch(transactionLogProvider);
    return switch (transactionsAsyncValue) {
      AsyncLoading() => const Center(child: CircularProgressIndicator()),
      AsyncError(:final error) => Center(child: Text('Error: $error')),
      AsyncData(:final value) => value.isEmpty
          ? const Center(child: Text('No transactions yet.'))
          : ListView.builder(
              itemCount: value.length,
              itemBuilder: (context, index) {
                final transaction = value[index];

                // We'll build the ListTile separately to keep the code clean
                Widget listTile;
                String itemName = 'Transaction'; // Default name for the snackbar

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

                // Wrap the final ListTile in a Dismissible for swipe-to-delete
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
                    ref.invalidate(transactionLogProvider);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$itemName deleted')),
                    );
                  },
                  child: listTile,
                );
              },
            ),
      _ => const Center(child: Text('Something went wrong'))
    };
  }
}
