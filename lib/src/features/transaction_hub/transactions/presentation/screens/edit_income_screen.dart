import 'package:flutter/material.dart';
import 'package:budgit/src/core/domain/models/transaction.dart';
import 'package:budgit/src/features/transaction_hub/transactions/presentation/widgets/income_form.dart'; // We'll create this next

class EditIncomeScreen extends StatelessWidget {
  final Transaction transaction;
  const EditIncomeScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Income'),
      ),
      body: IncomeForm(initialTransaction: transaction),
    );
  }
}