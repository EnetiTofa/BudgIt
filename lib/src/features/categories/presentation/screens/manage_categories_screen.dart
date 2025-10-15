// lib/src/features/categories/presentation/screens/manage_categories_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/features/categories/presentation/providers/category_list_provider.dart';
// --- NEW IMPORT ---
import 'package:budgit/src/features/budgets/presentation/screens/category_drilldown_screen.dart';

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
                // --- MODIFIED ---
                // Replaced the CircleAvatar with a colored Icon.
                leading: Icon(category.icon, color: category.color),
                title: Text(category.name),
                trailing: ReorderableDragStartListener(
                  index: index,
                  child: const Icon(Icons.drag_handle),
                ),
                // --- MODIFIED ---
                // Implemented onTap to navigate to the drilldown screen.
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CategoryDrilldownScreen(
                        categories: value,
                        initialIndex: index,
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