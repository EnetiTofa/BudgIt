// lib/src/features/transaction_hub/transactions/presentation/screens/add_payment_screen.dart
import 'package:flutter/material.dart';
import 'package:budgit/src/features/transaction_hub/transactions/presentation/widgets/payment_form.dart';

class AddPaymentScreen extends StatelessWidget {
  final DateTime? initialDate;
  final DateTime? minDate;
  final DateTime? maxDate;

  const AddPaymentScreen({
    super.key,
    this.initialDate,
    this.minDate,
    this.maxDate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Payment')),
      body: PaymentForm(
        initialDate: initialDate,
        minDate: minDate,
        maxDate: maxDate,
      ),
    );
  }
}
