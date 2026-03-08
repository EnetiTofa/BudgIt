// lib/src/features/transaction_hub/transactions/presentation/screens/edit_payment_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/core/domain/models/transaction.dart';
import 'package:budgit/src/features/transaction_hub/transactions/presentation/widgets/payment_form.dart';
import 'package:budgit/src/features/transaction_hub/transactions/presentation/providers/transaction_log_provider.dart';

class EditPaymentScreen extends ConsumerWidget {
  final Transaction transaction;
  final DateTime? minDate;
  final DateTime? maxDate;

  const EditPaymentScreen({
    super.key,
    required this.transaction,
    this.minDate,
    this.maxDate,
  });

  Future<void> _deleteTransaction(BuildContext context, WidgetRef ref) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Payment?'),
        content: const Text(
          'Are you sure you want to delete this payment? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      ref
          .read(allTransactionOccurrencesProvider.notifier)
          .removeTransaction(transaction.id);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Payment'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            color: Theme.of(context).colorScheme.error,
            onPressed: () => _deleteTransaction(context, ref),
          ),
        ],
      ),
      body: PaymentForm(
        initialTransaction: transaction,
        minDate: minDate,
        maxDate: maxDate,
      ),
    );
  }
}
