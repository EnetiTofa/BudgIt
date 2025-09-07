import 'package:flutter/material.dart';
import 'package:budgit/src/features/categories/presentation/category_form.dart';

class AddCategoryScreen extends StatelessWidget {
  const AddCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Category'),
      ),
      body: const CategoryForm(),
    );
  }
}