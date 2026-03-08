// lib/src/features/categories/presentation/widgets/income_context_bar.dart

import 'package:flutter/material.dart';
import 'package:budgit/src/features/budget_hub/presentation/providers/overall_budget_summary_provider.dart';
import 'package:budgit/src/core/domain/models/category.dart';
import 'package:budgit/src/core/domain/enums/budget_enum.dart';
import 'dart:math';

class IncomeContextBar extends StatelessWidget {
  const IncomeContextBar({
    super.key,
    required this.summary,
    required this.allCategories,
    required this.thisCategory,
    required this.activePeriod,
  });

  final OverallBudgetSummary summary;
  final List<Category> allCategories;
  final Category thisCategory;
  final BudgetPeriod activePeriod;

  double _scaleValue(double monthlyValue) {
    switch (activePeriod) {
      case BudgetPeriod.weekly:
        return monthlyValue / 4.33;
      case BudgetPeriod.monthly:
        return monthlyValue;
      case BudgetPeriod.yearly:
        return monthlyValue * 12;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final List<Category> updatedCategories =
        allCategories.where((c) => c.id != thisCategory.id).toList()
          ..add(thisCategory);

    final rawTotalUsed = updatedCategories.fold<double>(
      0.0,
      (sum, c) => sum + c.budgetAmount,
    );
    final rawTotalIncome = summary.totalIncome;

    final scaledTotalUsed = _scaleValue(rawTotalUsed);
    final scaledTotalIncome = _scaleValue(rawTotalIncome);

    final scaledRemaining = scaledTotalIncome - scaledTotalUsed;
    final isOverBudget = scaledRemaining < 0;

    final barTotal = max(scaledTotalIncome, scaledTotalUsed);
    final safeBarTotal = barTotal > 0 ? barTotal : 1.0;

    final List<Widget> segments = [];

    for (final category in updatedCategories) {
      final scaledCategoryBudget = _scaleValue(category.budgetAmount);
      if (scaledCategoryBudget <= 0) continue;

      segments.add(
        Expanded(
          flex: (scaledCategoryBudget / safeBarTotal * 1000000).toInt(),
          child: Container(
            color: category.color,
            child: Tooltip(message: category.name, waitDuration: Duration.zero),
          ),
        ),
      );
    }

    if (!isOverBudget && scaledRemaining > 0) {
      segments.add(
        Expanded(
          flex: (scaledRemaining / safeBarTotal * 1000000).toInt(),
          child: Container(color: theme.colorScheme.surfaceDim),
        ),
      );
    }

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        // --- BORDER REMOVED HERE ---
      ),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Impact on Overall Budget',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
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
                if (isOverBudget && scaledTotalUsed > 0)
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final position =
                          (scaledTotalIncome / scaledTotalUsed) *
                          constraints.maxWidth;

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
                    },
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${scaledTotalUsed.toStringAsFixed(0)} of \$${scaledTotalIncome.toStringAsFixed(0)} Income Used',
                  style: theme.textTheme.bodySmall,
                ),
                Text(
                  '\$${scaledRemaining.abs().toStringAsFixed(0)} ${isOverBudget ? "Over Income" : "Remaining"}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isOverBudget
                        ? theme.colorScheme.error
                        : theme.colorScheme.primary,
                    fontWeight: isOverBudget ? FontWeight.bold : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
