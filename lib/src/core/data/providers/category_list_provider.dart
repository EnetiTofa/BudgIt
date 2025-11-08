// lib/src/features/categories/presentation/providers/category_list_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:budgit/src/core/data/providers/transaction_repository_provider.dart';
import 'package:budgit/src/core/domain/models/category.dart';

part 'category_list_provider.g.dart';

@riverpod
class CategoryList extends _$CategoryList {
  @override
  Future<List<Category>> build() async {
    final repository = ref.watch(transactionRepositoryProvider);
    
    // Fetch both the categories and their custom order
    final categories = await repository.getAllCategories();
    final categoryOrder = await repository.getCategoryOrder();

    if (categoryOrder != null) {
      // If a custom order exists, sort the categories based on it
      final categoryMap = {for (var cat in categories) cat.id: cat};
      final sortedCategories = categoryOrder
          .map((id) => categoryMap[id])
          .where((cat) => cat != null)
          .cast<Category>()
          .toList();
      
      // Add any new categories that weren't in the saved order list
      final presentIds = sortedCategories.map((c) => c.id).toSet();
      sortedCategories.addAll(categories.where((c) => !presentIds.contains(c.id)));
      
      return sortedCategories;
    }

    // Otherwise, return the default order
    return categories;
  }

  Future<void> reorderCategories(int oldIndex, int newIndex) async {
    // Make sure we have data to work with
    if (!state.hasValue) return;

    // Adjust index for items moved down the list
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    final list = state.value!;
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    
    // Update the state to immediately reflect the change in UI
    state = AsyncValue.data(list);

    // Persist the new order in storage
    final repository = ref.read(transactionRepositoryProvider);
    final categoryIds = list.map((category) => category.id).toList();
    await repository.saveCategoryOrder(categoryIds);
  }

  Future<void> updateCategory(Category updatedCategory) async {
    final previousState = state.valueOrNull ?? [];
    
    // Optimistically update the UI so it feels instantaneous
    final updatedList = [
      for (final category in previousState)
        if (category.id == updatedCategory.id) updatedCategory else category,
    ];
    state = AsyncValue.data(updatedList);

    // Persist the change to the repository in the background
    final repository = ref.read(transactionRepositoryProvider);
    try {
      await repository.updateCategory(updatedCategory);
    } catch (e) {
      // If the update fails, revert to the previous state to maintain consistency
      state = AsyncValue.data(previousState);
      // Optionally, rethrow the error to be handled by the UI
      rethrow;
    }
  }
}