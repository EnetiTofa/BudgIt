import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:budgit/src/features/categories/presentation/category_form.dart';
import 'package:budgit/src/features/categories/domain/category.dart';
import 'package:budgit/src/features/transactions/presentation/controllers/add_transaction_controller.dart';
import 'package:budgit/src/features/categories/presentation/category_list_provider.dart';
import 'package:budgit/src/features/transactions/presentation/providers/transaction_log_provider.dart';
import 'package:budgit/src/features/budgets/presentation/budget_progress_provider.dart';

// Change this to a ConsumerWidget to get access to ref
class EditCategoryScreen extends ConsumerWidget {
  final Category category;
  const EditCategoryScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit ${category.name}'),
        // Add the actions list for the delete button
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              // We'll use the same confirmation dialog
              _showDeleteConfirmationDialog(context, ref, category);
            },
          ),
        ],
      ),
      body: CategoryForm(initialCategory: category),
    );
  }
}

// We can move the dialog function here to keep it with the screen that uses it.
Future<void> _showDeleteConfirmationDialog(BuildContext context, WidgetRef ref, Category category) async {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Delete Category?'),
        content: Text(
          'Are you sure you want to delete the "${category.name}" category? All associated transactions will also be permanently deleted.',
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
            onPressed: () {
              ref.read(addTransactionControllerProvider.notifier).deleteCategory(category.id);
              // Invalidate all providers that depend on categories or transactions
              ref.invalidate(categoryListProvider);
              ref.invalidate(transactionLogProvider);
              ref.invalidate(budgetProgressProvider);
              // Pop twice to close the dialog and the edit screen
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}