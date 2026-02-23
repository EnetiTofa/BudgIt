// lib/src/features/transaction_hub/transactions/presentation/screens/add_payment_screen.dart
import 'package:flutter/material.dart';
import 'package:budgit/src/features/transaction_hub/transactions/presentation/widgets/payment_form.dart';

class AddPaymentScreen extends StatelessWidget {
  final DateTime? initialDate; // ADDED

  const AddPaymentScreen({super.key, this.initialDate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Payment'),
      ),
      body: PaymentForm(initialDate: initialDate), // PASSED DOWN
    );
  }
}