import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/features/transaction_hub/transactions/domain/log_filter_state.dart';
import 'package:budgit/src/features/transaction_hub/transactions/presentation/controllers/log_filter_controller.dart';

class SortDropdown extends ConsumerWidget {
  const SortDropdown({super.key});

  void _handleSelection(SortBy value, WidgetRef ref) {
    ref.read(logFilterProvider.notifier).setSortBy(value);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(logFilterProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    Widget buildSortOption(SortBy value, String title, IconData icon) {
      final bool isSelected = filterState.sortBy == value;
      final Color itemColor = isSelected ? colorScheme.primary : colorScheme.secondary;
      
      return ListTile(
        title: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          style: TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w500,
            color: itemColor,
            fontSize: 15,
          ),
          child: Text(title),
        ),
        // --- MODIFIED: The Icon is now wrapped in a TweenAnimationBuilder ---
        leading: TweenAnimationBuilder<Color?>(
          // 1. The value to animate to. It animates whenever this value changes.
          tween: ColorTween(end: itemColor),
          // 2. The duration of the animation.
          duration: const Duration(milliseconds: 200),
          // 3. The builder function provides the intermediate color during the animation.
          builder: (BuildContext context, Color? animatedColor, Widget? child) {
            // We return the Icon, using the animated color.
            return Icon(icon, color: animatedColor, size: 20);
          },
        ),
        trailing: Radio<SortBy>(
          value: value,
          groupValue: filterState.sortBy,
          onChanged: (newValue) {
            if (newValue != null) {
              _handleSelection(newValue, ref);
            }
          },
          activeColor: colorScheme.primary,
        ),
        onTap: () => _handleSelection(value, ref),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
            child: Text(
              'Sort By',
              style: textTheme.titleMedium?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.w700, fontSize: 16),
            ),
          ),
          buildSortOption(SortBy.date, 'Date', Icons.calendar_today),
          buildSortOption(SortBy.category, 'Category', Icons.category),
          buildSortOption(SortBy.store, 'Store / Payee', Icons.store),
        ],
      ),
    );
  }
}