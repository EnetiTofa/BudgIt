import 'package:flutter/material.dart';
import 'package:budgit/src/core/domain/models/category.dart';
import 'package:budgit/src/features/budget_hub/presentation/widgets/transfer_form.dart';

class AddTransferScreen extends StatelessWidget {
  final Category targetCategory;

  const AddTransferScreen({super.key, required this.targetCategory});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Transfer')),
      body: TransferForm(targetCategory: targetCategory),
    );
  }
}
