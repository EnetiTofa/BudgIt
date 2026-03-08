// lib/src/features/budget_hub/budgets/presentation/widgets/budget_list.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/features/budget_hub/domain/budget_progress.dart';
import 'package:budgit/src/core/domain/models/category.dart';
import 'package:budgit/src/features/budget_hub/presentation/widgets/budget_card.dart';
import 'package:budgit/src/core/data/providers/category_list_provider.dart';

class BudgetList extends ConsumerStatefulWidget {
  const BudgetList({
    super.key,
    required this.progressList,
    required this.onCategoryTap,
    required this.selectedCategory,
  });

  final List<BudgetProgress> progressList;
  final ValueChanged<Category?> onCategoryTap; // Null implies "General"
  final Category? selectedCategory;

  @override
  ConsumerState<BudgetList> createState() => _BudgetListState();
}

class _BudgetListState extends ConsumerState<BudgetList> {
  // Track the ID of the category being dragged to fade out the rest
  String? _draggedCategoryId;

  @override
  Widget build(BuildContext context) {
    final isGeneralSelected = widget.selectedCategory == null;
    final isDraggingAnything = _draggedCategoryId != null;

    return SizedBox(
      height: 120,
      child: ReorderableListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),

        // --- NEW: Custom Drag Visuals ---
        proxyDecorator: (Widget child, int index, Animation<double> animation) {
          return Material(
            color: Colors.transparent, // Fixes the ugly white background block
            elevation: 0, // Fixes the harsh rectangular shadow
            child: Transform.scale(
              scale: 1.05, // Adds a clean "picked up" pop effect
              child: child,
            ),
          );
        },

        // --- NEW: Track Drag State ---
        onReorderStart: (index) {
          setState(() {
            _draggedCategoryId = widget.progressList[index].category.id;
          });
        },
        onReorderEnd: (index) {
          setState(() {
            _draggedCategoryId = null;
          });
        },
        onReorder: (oldIndex, newIndex) {
          setState(() {
            _draggedCategoryId = null; // Safety catch
          });
          ref
              .read(categoryListProvider.notifier)
              .reorderCategories(oldIndex, newIndex);
        },

        header: AnimatedOpacity(
          key: const ValueKey('general_header'),
          duration: const Duration(milliseconds: 200),
          // Fade out the General button if we are dragging a category
          opacity: isDraggingAnything ? 0.4 : 1.0,
          child: Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: BudgetCard.general(
              context: context,
              isSelected: isGeneralSelected,
              onTap: () => widget.onCategoryTap(null),
            ),
          ),
        ),

        itemCount: widget.progressList.length,
        itemBuilder: (context, index) {
          final progress = widget.progressList[index];
          final isSelected =
              widget.selectedCategory?.id == progress.category.id;
          final isBeingDragged = _draggedCategoryId == progress.category.id;

          return AnimatedOpacity(
            key: ValueKey(progress.category.id),
            duration: const Duration(milliseconds: 200),
            // Fade out this item if SOMETHING is dragging, but it is NOT this item
            opacity: (isDraggingAnything && !isBeingDragged) ? 0.4 : 1.0,
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: BudgetCard(
                label: progress.category.name,
                icon: progress.category.icon,
                color: progress.category.color,
                contentColor: progress.category.contentColor,
                isSelected: isSelected,
                onTap: () => widget.onCategoryTap(progress.category),
              ),
            ),
          );
        },
      ),
    );
  }
}
