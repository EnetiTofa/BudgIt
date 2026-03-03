// lib/src/features/budget_hub/presentation/widgets/weekly_category_summary_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:budgit/src/features/budget_hub/domain/weekly_category_data.dart';

class WeeklyCategorySummaryCard extends StatefulWidget {
  final WeeklyCategoryData data;

  const WeeklyCategorySummaryCard({super.key, required this.data});

  @override
  State<WeeklyCategorySummaryCard> createState() =>
      _WeeklyCategorySummaryCardState();
}

class _WeeklyCategorySummaryCardState extends State<WeeklyCategorySummaryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: widget.data.weeklyProgress,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant WeeklyCategorySummaryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data.weeklyProgress != oldWidget.data.weeklyProgress) {
      _animation = Tween<double>(
        begin: oldWidget.data.weeklyProgress,
        end: widget.data.weeklyProgress,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
      _controller
        ..value = 0.0
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: '\$');
    final theme = Theme.of(context);
    final data = widget.data;
    final isOverspent = data.totalSpentThisWeek > data.effectiveWeeklyBudget;

    final contentColor = data.category.contentColor;

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      color: data.category.color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin:
          EdgeInsets.zero, // Removed margin so it sits flush in the detail view
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(data.category.icon, color: contentColor, size: 26),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    data.category.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: contentColor,
                      fontSize: 20,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                RichText(
                  text: TextSpan(
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: contentColor.withOpacity(0.8),
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: currencyFormat.format(data.totalSpentThisWeek),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isOverspent ? Colors.redAccent : contentColor,
                        ),
                      ),
                      TextSpan(
                        text:
                            ' / ${currencyFormat.format(data.effectiveWeeklyBudget)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 12,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: _animation.value,
                      backgroundColor: theme.colorScheme.surface.withOpacity(
                        0.7,
                      ),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isOverspent
                            ? Colors.redAccent
                            // Used the category color but darker to pop against the background
                            : data.category.color.withAlpha(180),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
