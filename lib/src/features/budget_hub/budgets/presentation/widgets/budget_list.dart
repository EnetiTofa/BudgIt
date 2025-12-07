// lib/src/features/budget_hub/budgets/presentation/widgets/budget_list.dart

import 'package:flutter/material.dart';
import 'package:budgit/src/features/budget_hub/budgets/domain/budget_progress.dart';
import 'package:budgit/src/core/domain/models/category.dart';
import 'package:budgit/src/features/budget_hub/budgets/presentation/widgets/budget_card.dart';

class BudgetList extends StatelessWidget {
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
  Widget build(BuildContext context) {
    // Calculate total items: Categories + 1 (General button)
    final totalItems = progressList.length + 1;

    return SizedBox(
      height: 120, // Increased height to allow for top padding
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        // Added 'top: 16' to give headspace above the cards themselves
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        itemCount: totalItems,
        itemBuilder: (context, index) {
          // Case 1: The General Button (First Item)
          if (index == 0) {
            final isGeneralSelected = selectedCategory == null;
            return Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: BudgetCard.general(
                context: context,
                isSelected: isGeneralSelected,
                onTap: () => onCategoryTap(null),
              ),
            );
          }

          // Case 2: Category Buttons
          final progress = progressList[index - 1];
          final isSelected = selectedCategory?.id == progress.category.id;

          return Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: BudgetCard(
              label: progress.category.name,
              icon: progress.category.icon,
              color: progress.category.color,
              contentColor: progress.category.contentColor,
              isSelected: isSelected,
              onTap: () => onCategoryTap(progress.category),
            ),
          );
        },
      ),
    );
  }
}