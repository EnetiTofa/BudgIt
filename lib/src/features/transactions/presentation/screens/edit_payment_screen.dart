import 'package:flutter/material.dart';
import 'package:budgit/src/features/transactions/domain/transaction.dart';
import 'package:budgit/src/features/transactions/presentation/widgets/payment_form.dart';

class EditPaymentScreen extends StatelessWidget {
  final Transaction transaction;
  const EditPaymentScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Payment'),
        // We can add a delete button here later
      ),
      body: PaymentForm(initialTransaction: transaction),
    );
  }
}