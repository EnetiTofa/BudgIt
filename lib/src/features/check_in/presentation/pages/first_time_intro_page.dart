import 'package:flutter/material.dart';

class FirstTimeIntroPage extends StatelessWidget {
  const FirstTimeIntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.waving_hand_outlined,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              "Welcome to BudgIt!",
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              "Most budgeting apps fail because they expect you to be perfect. BudgIt is different. We break your budget down into manageable chunks using Check-Ins.",
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // --- The Two Types of Check-Ins ---
            Text(
              "How it Works",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            _buildInfoCard(
              context,
              icon: Icons.track_changes_outlined,
              title: "1. The Weekly Check-In",
              description:
                  "Happens every week on your chosen day. You'll clear out new transactions, balance categories that went over budget, and shift leftover money into savings.",
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              context,
              icon: Icons.calendar_month,
              title: "2. The Monthly Check-In",
              description:
                  "Happens on the FIRST check-in day of a new month. You do your standard weekly review, PLUS you fund your categories for the brand new month ahead.",
              color: theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(description, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
