import 'package:flutter/material.dart';
import 'package:budgit/src/features/transactions/presentation/income_form.dart';

class AddIncomeScreen extends StatelessWidget {
  const AddIncomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Income'),
      ),
      body: const IncomeForm(),
    );
  }
}