import 'package:flutter/material.dart';
import 'package:budgit/src/features/transactions/presentation/payment_form.dart';

class AddPaymentScreen extends StatelessWidget {
  const AddPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Payment'),
      ),
      body: const PaymentForm(),
    );
  }
}