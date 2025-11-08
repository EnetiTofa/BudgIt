import 'package:flutter/material.dart';

class MonthlySummaryCard extends StatelessWidget {
  const MonthlySummaryCard({super.key});

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
            _SummaryRow(
              value: '\$1,234.56',
              unit: 'NZD',
              title: 'Total Spending',
              description: 'The total amount spent in the selected month.',
            ),
            // THE FIX: Increased the gap between rows.
            const SizedBox(height: 16),
            _SummaryRow(
              value: '\$41.15',
              unit: 'NZD / day',
              title: 'Daily Average',
              description: 'Your average spending per day for this month.',
            ),
            const SizedBox(height: 16),
            _SummaryRow(
              value: '12',
              unit: 'Months',
              title: 'Months Counted',
              description: 'The total number of months with transaction data.',
            ),
            const SizedBox(height: 16),
            _SummaryRow(
              value: 'Oct 2025',
              unit: 'Month',
              title: 'Highest Month',
              description: 'The month where you spent the most amount.',
            ),
          ],
        ),
      ),
    );
  }
}

// A helper widget to build each row consistently.
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
            // THE FIX: Increased vertical padding to make the box taller.
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