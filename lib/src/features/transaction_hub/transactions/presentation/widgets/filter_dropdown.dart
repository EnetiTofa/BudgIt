import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/core/domain/models/category.dart';
import 'package:budgit/src/core/data/providers/category_list_provider.dart';
import 'package:budgit/src/features/transaction_hub/transactions/domain/log_filter_state.dart';
import 'package:budgit/src/features/transaction_hub/transactions/presentation/controllers/log_filter_controller.dart';
import 'package:budgit/src/common_widgets/date_selector_field.dart';

import 'package:budgit/src/features/transaction_hub/transactions/presentation/providers/dropdown_active_provider.dart';

class FilterDropdown extends ConsumerWidget {
  const FilterDropdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(logFilterProvider);
    final filterController = ref.read(logFilterProvider.notifier);
    final allCategoriesAsync = ref.watch(categoryListProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Helper method to close the dropdown menu
    // Helper method to close the dropdown menu
    void _closeDropdown() {
      // Try popping the dropdown route natively
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // Keep the provider update just in case your parent widget is listening to it
      ref.read(dropdownActiveProvider.notifier).state = false;
    }

    Widget buildTypeOption(TransactionTypeFilter value, String title) {
      final bool isSelected = filterState.transactionTypeFilter == value;
      final Color textColor = isSelected
          ? colorScheme.primary
          : colorScheme.secondary;

      return ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
        title: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          style: TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w500,
            color: textColor,
            fontSize: 15,
          ),
          child: Text(title),
        ),
        trailing: Radio<TransactionTypeFilter>(
          value: value,
          groupValue: filterState.transactionTypeFilter,
          onChanged: (newValue) =>
              filterController.setTransactionType(newValue!),
          activeColor: colorScheme.primary,
        ),
        onTap: () => filterController.setTransactionType(value),
      );
    }

    Widget buildCategoryOption(Category category) {
      final bool isSelected = filterState.selectedCategoryIds.contains(
        category.id,
      );
      final Color itemColor = isSelected
          ? colorScheme.primary
          : colorScheme.secondary;
      final Color iconColor = category.color;

      return ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
        title: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          style: TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w500,
            color: itemColor,
            fontSize: 15,
          ),
          child: Text(category.name),
        ),
        leading: TweenAnimationBuilder<Color?>(
          tween: ColorTween(end: iconColor),
          duration: const Duration(milliseconds: 200),
          builder: (context, animatedColor, child) {
            return Icon(category.icon, color: animatedColor, size: 20);
          },
        ),
        trailing: Checkbox(
          value: isSelected,
          onChanged: (_) => filterController.toggleCategoryFilter(category.id),
          activeColor: colorScheme.primary,
        ),
        onTap: () => filterController.toggleCategoryFilter(category.id),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Date Range',
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (filterState.startDate != null ||
                    filterState.endDate != null)
                  TextButton(
                    onPressed: () => filterController.setDateRange(null, null),
                    child: const Text('Clear'),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: DateSelectorField(
                    labelText: 'From',
                    icon: Icons.calendar_today,
                    layout: DateSelectorLayout.vertical,
                    selectedDate: filterState.startDate,
                    allowFutureDates: true,
                    maxDate: filterState.endDate,
                    onOpenPicker:
                        _closeDropdown, // <-- Closes menu before opening!
                    onDateSelected: (date) {
                      filterController.setDateRange(date, filterState.endDate);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DateSelectorField(
                    labelText: 'To',
                    icon: Icons.event,
                    layout: DateSelectorLayout.vertical,
                    selectedDate: filterState.endDate,
                    allowFutureDates: true,
                    minDate: filterState.startDate,
                    onOpenPicker:
                        _closeDropdown, // <-- Closes menu before opening!
                    onDateSelected: (date) {
                      filterController.setDateRange(
                        filterState.startDate,
                        date,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 32, indent: 16, endIndent: 16),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              'Type',
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          buildTypeOption(TransactionTypeFilter.all, 'All'),
          buildTypeOption(TransactionTypeFilter.payment, 'Payments'),
          buildTypeOption(TransactionTypeFilter.income, 'Income'),

          const Divider(height: 24, indent: 16, endIndent: 16),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              'Category',
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          switch (allCategoriesAsync) {
            AsyncLoading() => Center(
              child: CircularProgressIndicator(color: colorScheme.surface),
            ),
            AsyncError() => const Center(
              child: Text('Could not load categories.'),
            ),
            AsyncData(:final value) =>
              value.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: Text('No categories found.')),
                    )
                  : Builder(
                      builder: (context) {
                        const double itemHeight = 48.0;
                        const double maxHeight = 200.0;
                        final double totalContentHeight =
                            value.length * itemHeight;
                        final bool needsScrolling =
                            totalContentHeight > maxHeight;

                        if (needsScrolling) {
                          return SizedBox(
                            height: maxHeight,
                            child: ListView(
                              shrinkWrap: true,
                              children: value.map(buildCategoryOption).toList(),
                            ),
                          );
                        } else {
                          return Column(
                            children: value.map(buildCategoryOption).toList(),
                          );
                        }
                      },
                    ),
            _ => const SizedBox.shrink(),
          },
        ],
      ),
    );
  }
}
