import 'package:flutter/material.dart';
import 'package:budgit/src/features/budgets/domain/budget_progress.dart';

class BudgetCard extends StatelessWidget {
  const BudgetCard({
    super.key,
    required this.progress,
    required this.onTap, // Added onTap callback
  });

  final BudgetProgress progress;
  final VoidCallback onTap; // Added onTap callback

  @override
  Widget build(BuildContext context) {
    final brightness = ThemeData.estimateBrightnessForColor(progress.category.color);
    final contentColor = brightness == Brightness.dark
        ? Colors.white
        : const Color(0xFF121212).withAlpha(200);

    return SizedBox(
      width: 68,
      height: 68,
      child: InkWell(
        onTap: onTap, // Use the callback here
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