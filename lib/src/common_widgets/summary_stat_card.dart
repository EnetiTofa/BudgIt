// lib/src/common_widgets/summary_stat_card.dart
import 'package:flutter/material.dart';

/// A data class to hold all information for a single row in the summary card.
class SummaryStat {
  final String value;
  final String unit;
  final String title;
  final String description;

  SummaryStat({
    required this.value,
    required this.unit,
    required this.title,
    required this.description,
  });
}

/// A reusable card that displays a vertical list of detailed statistics.
/// It is styled to match the design of the original MonthlySummaryCard.
class SummaryStatCard extends StatelessWidget {
  const SummaryStatCard({super.key, required this.stats});

  final List<SummaryStat> stats;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            for (int i = 0; i < stats.length; i++) ...[
              _SummaryRow(
                value: stats[i].value,
                unit: stats[i].unit,
                title: stats[i].title,
                description: stats[i].description,
              ),
              // Add a divider between items, but not after the last one.
              if (i < stats.length - 1) const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }
}

// This helper widget is copied directly from your original card for consistent styling.
class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.value,
    required this.unit,
    required this.title,
    required this.description,
  });

  final String value;
  final String unit;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 120,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  unit,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}