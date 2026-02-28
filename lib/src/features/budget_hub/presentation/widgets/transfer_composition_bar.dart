import 'package:flutter/material.dart';
import 'package:budgit/src/core/domain/models/category.dart';

class TransferCompositionBar extends StatelessWidget {
  final Category targetCategory;
  final double baseBudget;
  final double spent;
  final double otherTransfersTotal;
  final double currentTransferAmount;
  final Color? currentTransferColor;

  const TransferCompositionBar({
    super.key,
    required this.targetCategory,
    required this.baseBudget,
    required this.spent,
    required this.otherTransfersTotal,
    required this.currentTransferAmount,
    this.currentTransferColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Total width of the bar represents the New Total Capacity
    final double totalCapacity =
        baseBudget + otherTransfersTotal + currentTransferAmount;

    // Avoid division by zero
    final double safeTotal = totalCapacity > 0 ? totalCapacity : 1.0;

    // Percentages
    final double basePct = (baseBudget / safeTotal).clamp(0.0, 1.0);
    final double otherPct = (otherTransfersTotal / safeTotal).clamp(0.0, 1.0);
    final double currentPct = (currentTransferAmount / safeTotal).clamp(
      0.0,
      1.0,
    );

    // Spent is an overlay, not a segment
    final double spentPct = (spent / safeTotal).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total Capacity",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              Text(
                "\$${totalCapacity.toStringAsFixed(2)}",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 32,
            child: Stack(
              children: [
                // 1. The Composition Bar (Backgrounds)
                Row(
                  children: [
                    // Base Budget
                    if (basePct > 0)
                      Flexible(
                        flex: (basePct * 1000).toInt(),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(targetCategory.colorValue),
                            borderRadius: BorderRadius.horizontal(
                              left: const Radius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    // Other Transfers
                    if (otherPct > 0)
                      Flexible(
                        flex: (otherPct * 1000).toInt(),
                        child: Container(color: Colors.grey.withOpacity(0.3)),
                      ),
                    // Current Transfer (Active editing)
                    if (currentPct > 0)
                      Flexible(
                        flex: (currentPct * 1000).toInt(),
                        child: Container(
                          decoration: BoxDecoration(
                            color:
                                currentTransferColor ??
                                theme.colorScheme.primary,
                            borderRadius: BorderRadius.horizontal(
                              right: const Radius.circular(4),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                // 2. Spent Overlay (Hashed or Darkened)
                if (spentPct > 0)
                  FractionallySizedBox(
                    widthFactor: spentPct,
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurface.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: theme.colorScheme.onSurface.withOpacity(0.2),
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.lock_outline,
                          size: 12,
                          color: Colors.black45,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendItem(
                color: Color(targetCategory.colorValue),
                label: "Base",
              ),
              const SizedBox(width: 12),
              if (otherTransfersTotal > 0) ...[
                _LegendItem(
                  color: Colors.grey.withOpacity(0.3),
                  label: "Others",
                ),
                const SizedBox(width: 12),
              ],
              _LegendItem(
                color: currentTransferColor ?? theme.colorScheme.primary,
                label: "This Transfer",
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(radius: 4, backgroundColor: color),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
