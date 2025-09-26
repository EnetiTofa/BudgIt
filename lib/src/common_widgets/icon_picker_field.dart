import 'package:flutter/material.dart';

class IconPickerField extends StatelessWidget {
  const IconPickerField({
    super.key,
    this.selectedIcon,
    required this.onIconSelected,
    this.labelText = 'Icon',
  });

  final IconData? selectedIcon;
  final ValueChanged<IconData> onIconSelected;
  final String labelText;

  // A sample list of icons you can choose from.
  static const List<IconData> _icons = [
    Icons.business_center, Icons.work, Icons.paid, Icons.account_balance,
    Icons.card_giftcard, Icons.monetization_on, Icons.trending_up,
    Icons.receipt_long, Icons.savings, Icons.lightbulb, Icons.school,
    Icons.redeem, Icons.show_chart, Icons.attach_money, Icons.add_card,
  ];

  void _showIconPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
        ),
        itemCount: _icons.length,
        itemBuilder: (context, index) {
          final icon = _icons[index];
          return InkWell(
            borderRadius: BorderRadius.circular(50),
            onTap: () {
              onIconSelected(icon);
              Navigator.of(context).pop();
            },
            child: Icon(icon, size: 30, color: Theme.of(context).colorScheme.primary),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _showIconPicker(context),
          borderRadius: BorderRadius.circular(12.0), // Match the new radius
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow, // Set your desired background color
              borderRadius: BorderRadius.circular(12.0), // Set your desired corner radius
            ),
            child: Row(
              children: [
                if (selectedIcon != null) ...[
                  Icon(selectedIcon, color: colorScheme.onSurfaceVariant),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    selectedIcon != null ? 'Icon Selected' : 'Choose an icon...',
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}