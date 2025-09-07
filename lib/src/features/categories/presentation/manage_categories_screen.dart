import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/features/categories/presentation/category_list_provider.dart';
import 'package:budgit/src/features/categories/presentation/edit_category_screen.dart';

class ManageCategoriesScreen extends ConsumerWidget {
  const ManageCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoryListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Categories'),
      ),
      body: switch (categoriesAsync) {
        AsyncLoading() => const Center(child: CircularProgressIndicator()),
        AsyncError(:final error) => Center(child: Text('Error: $error')),
        AsyncData(:final value) => ListView.builder(
            itemCount: value.length,
            itemBuilder: (context, index) {
              final category = value[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: category.color,
                  child: Icon(category.icon, color: Colors.white),
                ),
                title: Text(category.name),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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