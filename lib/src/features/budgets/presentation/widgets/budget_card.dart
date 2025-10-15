import 'package:flutter/material.dart';
import 'package:budgit/src/features/budgets/domain/budget_progress.dart';

class BudgetCard extends StatelessWidget {
  const BudgetCard({
    super.key,
    required this.progress,
    required this.onTap,
  });

  final BudgetProgress progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final contentColor = progress.category.contentColor;

    return SizedBox(
      width: 68,
      height: 68,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Card(
          color: progress.category.color,
          elevation: 0.0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(progress.category.icon, color: contentColor, size: 36),
              ],
            ),
          ),
        ),
      ),
    );
  }
}