import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/features/check_in/presentation/controllers/check_in_controller.dart';
import 'package:budgit/src/core/data/providers/category_list_provider.dart';

// --- IMPORTANT: Update this import path to match where you saved the calendar widget ---
import 'package:budgit/src/features/budget_hub/presentation/widgets/monthly_transaction_calendar.dart';

class MonthlyReviewPage extends ConsumerWidget {
  const MonthlyReviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(checkInControllerProvider);
    final categoriesAsync = ref.watch(categoryListProvider);

    final totalSaved = state.unspentFundsByCategory.values.fold(
      0.0,
      (a, b) => a + b,
    );
    final totalOver = state.overspentFundsByCategory.values.fold(
      0.0,
      (a, b) => a + b,
    );

    String biggestWinName = "None";
    double biggestWinAmount = 0.0;
    String biggestOopsName = "None";
    double biggestOopsAmount = 0.0;
    Color biggestWinColor = Colors.green;
    Color biggestOopsColor = Colors.redAccent;

    if (categoriesAsync.hasValue) {
      final categories = categoriesAsync.value!;
      for (var entry in state.unspentFundsByCategory.entries) {
        if (entry.value > biggestWinAmount) {
          biggestWinAmount = entry.value;
          final cat = categories.firstWhere(
            (c) => c.id == entry.key,
            orElse: () => categories.first,
          );
          biggestWinName = cat.name;
          biggestWinColor = Color(cat.colorValue);
        }
      }
      for (var entry in state.overspentFundsByCategory.entries) {
        if (entry.value > biggestOopsAmount) {
          biggestOopsAmount = entry.value;
          final cat = categories.firstWhere(
            (c) => c.id == entry.key,
            orElse: () => categories.first,
          );
          biggestOopsName = cat.name;
          biggestOopsColor = Color(cat.colorValue);
        }
      }
    }

    final targetMonth = state.checkInWeekDate ?? DateTime.now();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --- REPORT HEADER ---
          Text(
            "MONTH IN REVIEW",
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 2.0,
              color: theme.colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            "Your Cycle Report",
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // --- MINIMALIST STATS (No Card) ---
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: _buildReportStat(
                    context,
                    title: "Total Saved",
                    amount: "+\$${totalSaved.toStringAsFixed(0)}",
                    color: Colors.green,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: theme.colorScheme.outlineVariant.withOpacity(0.5),
                ),
                Expanded(
                  child: _buildReportStat(
                    context,
                    title: "Over Budget",
                    amount: "-\$${totalOver.toStringAsFixed(0)}",
                    color: Colors.redAccent,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // --- MINIMALIST HIGHLIGHTS LEDGER ---
          Text(
            "KEY INSIGHTS",
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: theme.colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 16),

          if (biggestWinAmount > 0)
            _buildReportHighlightRow(
              context,
              title: "Biggest Win",
              subtitle: "You crushed it in $biggestWinName!",
              amountText: "+\$${biggestWinAmount.toStringAsFixed(0)}",
              icon: Icons.emoji_events_rounded,
              color: biggestWinColor,
            )
          else
            _buildReportHighlightRow(
              context,
              title: "Perfectly Balanced",
              subtitle: "You spent exactly what you budgeted.",
              amountText: "Spot on!",
              icon: Icons.balance_rounded,
              color: theme.colorScheme.primary,
            ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Divider(
              color: theme.colorScheme.outlineVariant.withOpacity(0.5),
            ),
          ),

          if (biggestOopsAmount > 0)
            _buildReportHighlightRow(
              context,
              title: "Room to Grow",
              subtitle: "$biggestOopsName hit you harder than expected.",
              amountText: "-\$${biggestOopsAmount.toStringAsFixed(0)}",
              icon: Icons.trending_down_rounded,
              color: biggestOopsColor,
            )
          else
            _buildReportHighlightRow(
              context,
              title: "Flawless Cycle!",
              subtitle: "0 categories in the red this month.",
              amountText: "Perfect",
              icon: Icons.star_rounded,
              color: Colors.amber.shade600,
            ),

          const SizedBox(height: 48),

          // --- CALENDAR INTEGRATION ---
          Text(
            "ACTIVITY HEATMAP",
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: theme.colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 16),
          MonthlyTransactionCalendar(selectedMonth: targetMonth),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // Pure typography layout for the main numbers (Now smaller and cardless)
  Widget _buildReportStat(
    BuildContext context, {
    required String title,
    required String amount,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            amount,
            style: theme.textTheme.headlineMedium?.copyWith(
              // Reduced from displaySmall to headlineMedium
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  // A flat, text-driven row that feels like a clean list
  Widget _buildReportHighlightRow(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String amountText,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.secondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          amountText,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
      ],
    );
  }
}
