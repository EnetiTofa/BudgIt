import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/features/check_in/presentation/controllers/check_in_controller.dart';
import 'package:budgit/src/core/data/providers/category_list_provider.dart';
import 'package:budgit/src/core/domain/models/category.dart';
import 'package:budgit/src/features/categories/presentation/screens/manage_category_screen.dart'; // Make sure this path matches!
import 'package:budgit/src/features/check_in/domain/check_in_state.dart';

class SmartProposalsPage extends ConsumerWidget {
  const SmartProposalsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(checkInControllerProvider);
    final categoriesAsync = ref.watch(categoryListProvider);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          Icon(
            Icons.auto_awesome_rounded,
            size: 52,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            "Smart Proposals",
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            "Accept these tweaks to auto-update your budgets, or edit them manually to dive into the details.",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.secondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          Expanded(
            child: categoriesAsync.when(
              data: (categories) {
                final proposals = <Widget>[];

                // 1. Evaluate Overspending
                for (var entry in state.overspentFundsByCategory.entries) {
                  final cat = categories.firstWhere(
                    (c) => c.id == entry.key,
                    orElse: () => _fallbackCat(),
                  );
                  if (cat.id == 'unknown' || cat.budgetAmount <= 0) continue;
                  _evaluateAndAddProposal(
                    diff: entry.value,
                    cat: cat,
                    isOverspent: true,
                    proposals: proposals,
                    state: state,
                    ref: ref,
                  );
                }

                // 2. Evaluate Underspending
                for (var entry in state.unspentFundsByCategory.entries) {
                  final cat = categories.firstWhere(
                    (c) => c.id == entry.key,
                    orElse: () => _fallbackCat(),
                  );
                  if (cat.id == 'unknown' || cat.budgetAmount <= 0) continue;
                  _evaluateAndAddProposal(
                    diff: entry.value,
                    cat: cat,
                    isOverspent: false,
                    proposals: proposals,
                    state: state,
                    ref: ref,
                  );
                }

                if (proposals.isEmpty) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 80,
                        color: Colors.green.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "No Tweaks Needed",
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Your budgets look perfectly dialed in right now!",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.secondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  );
                }

                return ListView(children: proposals);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  void _evaluateAndAddProposal({
    required double diff,
    required Category cat,
    required bool isOverspent,
    required List<Widget> proposals,
    required CheckInState state,
    required WidgetRef ref,
  }) {
    // 1. Calculate percentage based directly on the MONTHLY budget
    final percentDiff = diff / cat.budgetAmount;

    // CONDITION 1: Relative difference must be > 5%
    if (percentDiff <= 0.05) return;

    // 2. Round the adjustment to the nearest $5 increment
    final proposedMonthlyAdjustment = (diff / 5).round() * 5.0;

    // CONDITION 2: Absolute adjustment must be at least $5/month
    if (proposedMonthlyAdjustment < 5.0) return;

    // 3. Calculate the new proposed base budget
    double proposedNewBudget = isOverspent
        ? cat.budgetAmount + proposedMonthlyAdjustment
        : cat.budgetAmount - proposedMonthlyAdjustment;

    if (proposedNewBudget < 0) {
      proposedNewBudget = 0.0;
    }

    final activeProposedBudget =
        state.proposedCategoryTweaks[cat.id] ?? proposedNewBudget;
    final isAccepted = state.proposedCategoryTweaks.containsKey(cat.id);
    final actualAdjustment = (activeProposedBudget - cat.budgetAmount).abs();

    proposals.add(
      _ProposalCard(
        category: cat,
        isOverspent: activeProposedBudget > cat.budgetAmount,
        adjustment: actualAdjustment,
        newBudget: activeProposedBudget,
        systemProposedBudget: proposedNewBudget,
        isAccepted: isAccepted,
        onToggle: () => ref
            .read(checkInControllerProvider.notifier)
            .toggleProposal(cat.id, activeProposedBudget),
      ),
    );
  }

  Category _fallbackCat() => Category(
    id: 'unknown',
    name: 'Unknown',
    iconCodePoint: 0,
    colorValue: 0,
    budgetAmount: 0,
  );
}

class _ProposalCard extends StatelessWidget {
  final Category category;
  final bool isOverspent;
  final double adjustment;
  final double newBudget;
  final double systemProposedBudget;
  final bool isAccepted;
  final VoidCallback onToggle;

  const _ProposalCard({
    required this.category,
    required this.isOverspent,
    required this.adjustment,
    required this.newBudget,
    required this.systemProposedBudget,
    required this.isAccepted,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Use the actual category colors just like the summary card
    final bgColor = category.color;
    final contentColor = category.contentColor;

    final weeklyAdj = adjustment / 4.33;
    final yearlyAdj = adjustment * 12;

    final titlePrefix = isOverspent ? "Increase" : "Decrease";
    final symbol = isOverspent ? "+" : "-";

    final noChange = adjustment == 0;

    // Determine the active tint. If accepted, we give it a subtle green overlay.
    // If not accepted, we keep the pure category color.
    final cardColor = isAccepted
        ? Color.alphaBlend(Colors.green.withOpacity(0.15), bgColor)
        : bgColor;

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 16),
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: isAccepted
            ? const BorderSide(color: Colors.green, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER ROW (Icon, Title, Edit Button) ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  IconData(category.iconCodePoint, fontFamily: 'MaterialIcons'),
                  color: contentColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    noChange
                        ? "Keep ${category.name} Same"
                        : "$titlePrefix ${category.name}",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: contentColor,
                      fontSize: 20,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: contentColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.edit_rounded,
                      color: contentColor,
                      size: 20,
                    ),
                    tooltip: "Manage Category details",
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              ManageCategoryScreen(category: category),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // --- UNIT STATS BAR ---
            if (!noChange) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 8,
                ),
                decoration: BoxDecoration(
                  color: contentColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _UnitStat(
                      label: "Weekly",
                      amount: "$symbol\$${weeklyAdj.toStringAsFixed(2)}",
                      contentColor: contentColor,
                      isOverspent: isOverspent,
                    ),
                    Container(
                      width: 1,
                      height: 24,
                      color: contentColor.withOpacity(0.2),
                    ),
                    _UnitStat(
                      label: "Monthly",
                      amount: "$symbol\$${adjustment.toStringAsFixed(0)}",
                      contentColor: contentColor,
                      isOverspent: isOverspent,
                    ),
                    Container(
                      width: 1,
                      height: 24,
                      color: contentColor.withOpacity(0.2),
                    ),
                    _UnitStat(
                      label: "Yearly",
                      amount: "$symbol\$${yearlyAdj.toStringAsFixed(0)}",
                      contentColor: contentColor,
                      isOverspent: isOverspent,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // --- BOTTOM ACTION ROW ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "New Base Budget:",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: contentColor.withOpacity(0.8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "\$${newBudget.toStringAsFixed(0)}",
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: contentColor,
                      ),
                    ),
                  ],
                ),
                FilledButton.icon(
                  onPressed: onToggle,
                  style: FilledButton.styleFrom(
                    backgroundColor: isAccepted ? Colors.green : contentColor,
                    foregroundColor: isAccepted ? Colors.white : bgColor,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  icon: Icon(isAccepted ? Icons.check : Icons.add, size: 20),
                  label: Text(
                    isAccepted ? "Accepted" : "Accept",
                    style: const TextStyle(fontWeight: FontWeight.bold),
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

class _UnitStat extends StatelessWidget {
  final String label;
  final String amount;
  final Color contentColor;
  final bool isOverspent;

  const _UnitStat({
    required this.label,
    required this.amount,
    required this.contentColor,
    required this.isOverspent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: contentColor.withOpacity(0.7),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            // If they are increasing the budget (overspent), show the red/orange warning tint
            // Otherwise, keep it the pure, clean content color
            color: isOverspent ? Colors.redAccent.shade100 : contentColor,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
