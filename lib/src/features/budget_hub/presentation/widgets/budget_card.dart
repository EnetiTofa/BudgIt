// lib/src/features/budget_hub/budgets/presentation/widgets/budget_card.dart

import 'package:flutter/material.dart';

class BudgetCard extends StatelessWidget {
  const BudgetCard({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.contentColor,
    required this.onTap,
    this.isSelected = false,
  });

  /// Factory constructor for the "General" card style
  factory BudgetCard.general({
    required BuildContext context,
    required VoidCallback onTap,
    required bool isSelected,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return BudgetCard(
      label: 'General',
      icon: Icons.pie_chart_outline_outlined,
      color: colorScheme.surfaceContainerHighest,
      contentColor: colorScheme.primary,
      onTap: onTap,
      isSelected: isSelected,
    );
  }

  final String label;
  final IconData icon;
  final Color color;
  final Color contentColor;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected
        ? Theme.of(context).colorScheme.primary.withAlpha(255)
        : Colors.transparent;

    // --- NEW: Wrapped in a transparent Material ---
    // This ensures text doesn't get ugly yellow underlines when detached during drag
    return Material(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeInOut,
            width: 64,
            height: 64,
            transform: isSelected
                ? Matrix4.diagonal3Values(1.1, 1.1, 1.0)
                : Matrix4.identity(),
            transformAlignment: Alignment.center,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: borderColor,
                width: 3.0,
                strokeAlign: BorderSide.strokeAlignInside,
              ),
            ),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(20),
              child: Center(child: Icon(icon, color: contentColor, size: 30)),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.secondary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
