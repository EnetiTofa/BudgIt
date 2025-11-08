import 'package:flutter/material.dart';
import 'package:budgit/src/features/budget_hub/budgets/domain/budget_progress.dart';
import 'package:budgit/src/core/domain/models/category.dart';
import 'package:budgit/src/features/budget_hub/budgets/presentation/widgets/budget_card.dart';

class BudgetList extends StatelessWidget {
  const BudgetList({
    super.key,
    required this.progressList,
    required this.onCategoryTap, // Added callback
  });

  final List<BudgetProgress> progressList;
  final ValueChanged<Category> onCategoryTap; // Added callback

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: progressList.length,
        itemBuilder: (context, index) {
          final progress = progressList[index];
          return Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                BudgetCard(
                  progress: progress,
                  // Pass the tap event up with the selected category
                  onTap: () => onCategoryTap(progress.category),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 72,
                  child: Text(
                    progress.category.name,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}