// lib/src/features/categories/presentation/screens/manage_categories_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/features/categories/presentation/providers/category_list_provider.dart';
import 'package:budgit/src/features/categories/presentation/screens/edit_category_screen.dart';

class ManageCategoriesScreen extends ConsumerWidget {
  const ManageCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The provider name is the same, so this line doesn't change
    final categoriesAsync = ref.watch(categoryListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Categories'),
        // Optional: Add a drag handle icon to the AppBar to indicate reordering
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Icon(Icons.drag_handle),
          )
        ],
      ),
      body: switch (categoriesAsync) {
        AsyncLoading() => const Center(child: CircularProgressIndicator()),
        AsyncError(:final error) => Center(child: Text('Error: $error')),
        AsyncData(:final value) => ReorderableListView.builder( // Changed to ReorderableListView
            itemCount: value.length,
            // The onReorder callback is where the magic happens
            onReorder: (oldIndex, newIndex) {
              ref
                  .read(categoryListProvider.notifier)
                  .reorderCategories(oldIndex, newIndex);
            },
            itemBuilder: (context, index) {
              final category = value[index];
              return ListTile(
                // A Key is required for each item in a ReorderableListView
                key: ValueKey(category.id),
                leading: CircleAvatar(
                  backgroundColor: category.color,
                  child: Icon(category.icon, color: Colors.white),
                ),
                title: Text(category.name),
                // The trailing icon can now be a drag handle
                trailing: ReorderableDragStartListener(
                  index: index,
                  child: const Icon(Icons.drag_handle),
                ),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => EditCategoryScreen(category: category),
                  ));
                },
              );
            },
          ),
        _ => const SizedBox.shrink(),
      },
    );
  }
}