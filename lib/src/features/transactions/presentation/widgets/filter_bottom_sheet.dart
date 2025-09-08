import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/features/transactions/presentation/controllers/log_filter_controller.dart';
import 'package:budgit/src/features/categories/presentation/category_list_provider.dart';

class FilterBottomSheet extends ConsumerWidget {
  const FilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoryListProvider);
    final filterState = ref.watch(logFilterProvider);
    final filterController = ref.read(logFilterProvider.notifier);

    return categoriesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e,s) => const Center(child: Text('Could not load categories.')),
      data: (categories) {
        return ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Filter by Category',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            ...categories.map((category) {
              final isSelected = filterState.selectedCategoryIds.contains(category.id);
              return CheckboxListTile(
                title: Text(category.name),
                value: isSelected,
                onChanged: (_) => filterController.toggleCategoryFilter(category.id),
              );
            }).toList(),
          ],
        );
      },
    );
  }
}