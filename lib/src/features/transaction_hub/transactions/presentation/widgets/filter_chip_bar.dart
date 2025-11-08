// lib/src/features/transactions/presentation/widgets/filter_chip_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// --- CHANGE START ---
// Import your new, more advanced category provider
import 'package:budgit/src/core/data/providers/category_list_provider.dart';
// --- CHANGE END ---
import 'package:budgit/src/features/transaction_hub/transactions/domain/log_filter_state.dart';
import 'package:budgit/src/features/transaction_hub/transactions/presentation/controllers/log_filter_controller.dart';

/// A widget that displays the current active filters as a row of dismissible chips.
class FilterChipBar extends ConsumerWidget {
  const FilterChipBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(logFilterProvider);
    final filterController = ref.read(logFilterProvider.notifier);
    // --- CHANGE START ---
    // Watch your new provider instead of the old one
    final allCategoriesAsync = ref.watch(categoryListProvider);
    // --- CHANGE END ---

    // Don't build anything if categories are not yet loaded.
    if (!allCategoriesAsync.hasValue) {
      return const SizedBox.shrink();
    }

    final allCategories = allCategoriesAsync.value!;
    final categoryMap = {for (var cat in allCategories) cat.id: cat.name};

    final List<Widget> chips = [];

    // 1. Chip for Transaction Type Filter (Payment/Income)
    if (filterState.transactionTypeFilter != TransactionTypeFilter.all) {
      final label = filterState.transactionTypeFilter == TransactionTypeFilter.payment
          ? 'Payments'
          : 'Income';
      chips.add(InputChip(
        label: Text(label),
        onDeleted: () => filterController.setTransactionType(TransactionTypeFilter.all),
      ));
    }

    // 2. Chips for Selected Category Filters
    for (final categoryId in filterState.selectedCategoryIds) {
      final categoryName = categoryMap[categoryId] ?? 'Unknown';
      chips.add(InputChip(
        label: Text(categoryName),
        onDeleted: () => filterController.toggleCategoryFilter(categoryId),
      ));
    }
    
    // 3. Chip for Search Query
    if (filterState.searchQuery.isNotEmpty) {
      chips.add(InputChip(
        label: Text('Search: "${filterState.searchQuery}"'),
        onDeleted: () => filterController.setSearchQuery(''),
      ));
    }

    // If no filters are active, don't show the bar.
    if (chips.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 4.0,
        children: chips,
      ),
    );
  }
}