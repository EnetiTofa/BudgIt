import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/common_widgets/custom_toggle.dart';
import 'package:budgit/src/features/transactions/data/transaction_repository_provider.dart';
import 'package:budgit/src/features/transactions/domain/transaction.dart';
import 'package:budgit/src/features/transactions/presentation/recurring_transactions_provider.dart';
import 'package:budgit/src/features/transactions/presentation/transaction_log_provider.dart';
import 'package:budgit/src/features/transactions/presentation/edit_payment_screen.dart';
import 'package:budgit/src/features/transactions/presentation/edit_income_screen.dart';



class RecurringScreen extends ConsumerStatefulWidget {
  const RecurringScreen({super.key});

  @override
  ConsumerState<RecurringScreen> createState() => _RecurringScreenState();
}

class _RecurringScreenState extends ConsumerState<RecurringScreen> {
  String _selectedView = 'Payments';

  @override
  Widget build(BuildContext context) {
    final recurringAsyncValue = ref.watch(recurringTransactionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recurring'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          CustomToggle(
            options: const ['Payments', 'Income'],
            selectedValue: _selectedView,
            onChanged: (value) => setState(() => _selectedView = value),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: switch (recurringAsyncValue) {
              AsyncLoading() => const Center(child: CircularProgressIndicator()),
              AsyncError(:final error) => Center(child: Text('Error: $error')),
              AsyncData(:final value) => _buildTransactionList(
                  transactions: value,
                  showPayments: _selectedView == 'Payments',
                ),
              _ => const SizedBox.shrink(),
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList({required List<Transaction> transactions, required bool showPayments}) {
    final items = transactions.where((t) {
      return showPayments ? t is RecurringPayment : t is RecurringIncome;
    }).toList();

    if (items.isEmpty) {
      return Center(child: Text('No recurring ${showPayments ? 'payments' : 'income'}.'));
    }

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        Widget listTile;
        String name = "Item";

        if (item is RecurringPayment) {
          name = item.paymentName;
          listTile = ListTile(
            title: Text(item.paymentName),
            subtitle: Text(item.payee),
            trailing: Text('-\$${item.amount.toStringAsFixed(2)} / ${item.recurrence.name}'),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => EditPaymentScreen(transaction: item),
              ));
            },
          );
        } else if (item is RecurringIncome) {
          name = item.source;
          listTile = ListTile(
            title: Text(item.source),
            trailing: Text('+\$${item.amount.toStringAsFixed(2)} / ${item.recurrence.name}'),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => EditIncomeScreen(transaction: item),
              ));
            },
          );
        } else {
          listTile = const SizedBox.shrink();
        }

        // --- Wrap the ListTile in a Dismissible ---
        return Dismissible(
          key: Key(item.id),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) {
            ref.read(transactionRepositoryProvider).deleteTransaction(item.id);
            // Invalidate both providers to update the rule list and the main log
            ref.invalidate(recurringTransactionsProvider);
            ref.invalidate(transactionLogProvider);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$name rule deleted')),
            );
          },
          child: listTile,
        );
      },
    );
  }
}