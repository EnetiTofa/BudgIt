// lib/src/features/categories/presentation/widgets/income_context_bar.dart

import 'package:flutter/material.dart';
import 'package:budgit/src/features/budget_hub/budgets/presentation/providers/overall_budget_summary_provider.dart';
import 'package:budgit/src/core/domain/models/category.dart';
import 'dart:math';

class IncomeContextBar extends StatelessWidget {
  const IncomeContextBar({
    super.key,
    required this.summary,
    required this.allCategories,
    required this.thisCategory,
  });

  final OverallBudgetSummary summary;
  final List<Category> allCategories;
  final Category thisCategory;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final List<Category> updatedCategories = allCategories
        .where((c) => c.id != thisCategory.id)
        .toList()
      ..add(thisCategory);

    final totalUsed = updatedCategories.fold<double>(0.0, (sum, c) => sum + c.budgetAmount);
    
    final remaining = summary.totalIncome - totalUsed;
    final isOverBudget = remaining < 0;

    final barTotal = max(summary.totalIncome, totalUsed);
    final safeBarTotal = barTotal > 0 ? barTotal : 1.0;

    final List<Widget> segments = [];
    
    for (final category in updatedCategories) {
      if (category.budgetAmount <= 0) continue;
      
      segments.add(Expanded(
        flex: (category.budgetAmount / safeBarTotal * 1000000).toInt(),
        child: Container(
          color: category.color,
          child: Tooltip(message: category.name, waitDuration: Duration.zero),
        ),
      ));
    }

    if (!isOverBudget && remaining > 0) {
      segments.add(Expanded(
        flex: (remaining / safeBarTotal * 1000000).toInt(),
        child: Container(color: theme.colorScheme.surfaceDim), 
      ));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Impact on Overall Budget',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Stack(
            alignment: Alignment.centerLeft,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: 24,
                  child: segments.isNotEmpty
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: segments,
                        )
                      : Container(color: theme.colorScheme.surfaceDim),
                ),
              ),
              if (isOverBudget && totalUsed > 0)
                LayoutBuilder(
                  builder: (context, constraints) {
                    final position = (summary.totalIncome / totalUsed) * constraints.maxWidth;
                    
                    // --- FIX APPLIED HERE ---
                    // Ensure the padding value is never negative by taking the max of 0 or the calculated value.
                    final leftPadding = max(0.0, position - 1);

                    return Padding(
                      padding: EdgeInsets.only(left: leftPadding),
                      child: Container(
                        width: 2,
                        height: 24,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$${totalUsed.toStringAsFixed(0)} of \$${summary.totalIncome.toStringAsFixed(0)} Income Used',
                style: theme.textTheme.bodySmall,
              ),
              Text(
                '\$${remaining.abs().toStringAsFixed(0)} ${isOverBudget ? "Over Income" : "Remaining"}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isOverBudget ? theme.colorScheme.error : theme.colorScheme.primary,
                  fontWeight: isOverBudget ? FontWeight.bold : null,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}