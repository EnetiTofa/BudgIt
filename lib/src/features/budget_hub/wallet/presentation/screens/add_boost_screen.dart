import 'package:flutter/material.dart';
import 'package:budgit/src/core/domain/models/category.dart';
import 'package:budgit/src/features/budget_hub/wallet/presentation/widgets/boost_form.dart';

class AddBoostScreen extends StatelessWidget {
  final Category targetCategory;

  const AddBoostScreen({super.key, required this.targetCategory});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Boost'),
      ),
      body: BoostForm(targetCategory: targetCategory),
    );
  }
}