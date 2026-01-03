import 'package:flutter/material.dart';

class SegmentedLinearGauge extends StatelessWidget {
  final double totalBudget;
  final double spent;
  final Color color;
  final int daysInPeriod;

  const SegmentedLinearGauge({
    super.key,
    required this.totalBudget,
    required this.spent,
    required this.color,
    this.daysInPeriod = 7,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final remaining = (totalBudget - spent).clamp(0.0, totalBudget);
    final percentRemaining = (totalBudget > 0) ? remaining / totalBudget : 0.0;
    final effectiveColor = remaining <= 0 ? theme.colorScheme.error : color;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Remaining", style: theme.textTheme.labelMedium),
            Text("\$${remaining.toStringAsFixed(0)}", 
              style: theme.textTheme.titleMedium?.copyWith(
                color: effectiveColor, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 20,
          child: Stack(
            children: [
              // Background
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              // Fill
              FractionallySizedBox(
                widthFactor: percentRemaining,
                child: Container(
                  decoration: BoxDecoration(
                    color: effectiveColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              // Ticks
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(daysInPeriod - 1, (index) {
                  return Container(
                    width: 2,
                    color: theme.colorScheme.surface,
                  );
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }
}