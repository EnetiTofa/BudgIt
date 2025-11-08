import 'package:flutter/material.dart';

class WalletToggle extends StatelessWidget {
  const WalletToggle({
    super.key,
    required this.isWalleted,
    required this.onChanged,
  });

  final bool isWalleted;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Determine the appearance based on the selected state
    final Color containerColor = isWalleted ? colorScheme.primary : colorScheme.surfaceContainerLowest;
    final Color contentColor = isWalleted ? colorScheme.onPrimary : colorScheme.secondary;
    final Border? border = isWalleted
        ? null
        : Border.all(color: colorScheme.outline, width: 1.0);

    // The icon is now permanently a checkmark when selected
    final IconData iconData = isWalleted
        ? Icons.check_circle
        : Icons.wallet_outlined;

    return GestureDetector(
      onTap: () => onChanged(!isWalleted),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: 100,
        height: 75,
        decoration: BoxDecoration(
          color: containerColor,
          border: border,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              iconData,
              color: contentColor,
              size: 28,
              semanticLabel: 'Wallet transaction status',
            ),
            const SizedBox(height: 4),
            Text(
              'Wallet',
              style: theme.textTheme.bodySmall?.copyWith(
                color: contentColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}