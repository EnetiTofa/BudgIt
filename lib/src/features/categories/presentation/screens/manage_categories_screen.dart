// lib/src/features/categories/presentation/screens/manage_categories_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/core/data/providers/category_list_provider.dart';
import 'package:budgit/src/features/categories/presentation/screens/edit_basic_category_screen.dart';

class ManageCategoriesScreen extends ConsumerWidget {
  const ManageCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoryListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Categories'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: Icon(Icons.drag_handle),
          )
        ],
      ),
      body: switch (categoriesAsync) {
        AsyncLoading() => const Center(child: CircularProgressIndicator()),
        AsyncError(:final error) => Center(child: Text('Error: $error')),
        AsyncData(:final value) => ReorderableListView.builder(
            itemCount: value.length,
            onReorder: (oldIndex, newIndex) {
              ref
                  .read(categoryListProvider.notifier)
                  .reorderCategories(oldIndex, newIndex);
            },
            itemBuilder: (context, index) {
              final category = value[index];
              return ListTile(
                key: ValueKey(category.id),
                leading: Icon(category.icon, color: category.color),
                title: Text(category.name),
                trailing: ReorderableDragStartListener(
                  index: index,
                  child: const Icon(Icons.drag_handle),
                ),
                // --- CHANGED ---
                // Navigate directly to EditBasicCategoryScreen
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => EditBasicCategoryScreen(
                        category: category,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        _ => const SizedBox.shrink(),
      },
    );
  }
}