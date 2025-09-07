import 'package:flutter/material.dart';
import 'package:budgit/src/features/budgets/domain/budget_progress.dart';

class BudgetCard extends StatelessWidget {
  const BudgetCard({
    super.key,
    required this.progress,
  });

  final BudgetProgress progress;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // TODO: Navigate to category detail screen
      },
      borderRadius: BorderRadius.circular(12),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: progress.category.color,
                    child: Icon(progress.category.icon, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    progress.category.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '\$${progress.amountSpent.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'of \$${progress.projectedBudget.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress.progress,
                minHeight: 10,
                borderRadius: BorderRadius.circular(5),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '\$${progress.amountRemaining.toStringAsFixed(2)} remaining',
                  style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}