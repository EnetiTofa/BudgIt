import 'package:flutter/material.dart';

class CustomToggle extends StatelessWidget {
  final List<String> options;
  final String selectedValue;
  final ValueChanged<String> onChanged;
  final double width;
  final double height;
  final double? fontSize;
  final FontWeight? fontWeight;

  const CustomToggle({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
    this.width = 260,
    this.height = 38,
    this.fontSize,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    final int selectedIndex = options.indexOf(selectedValue);

    return GestureDetector(
      onTapDown: (details) {
        final touchDx = details.localPosition.dx;
        final segmentWidth = width / options.length;
        final index = (touchDx / segmentWidth).floor();
        if (index >= 0 && index < options.length) {
          onChanged(options[index]);
        }
      },
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(height / 2),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              left: selectedIndex * (width / options.length),
              child: Container(
                width: width / options.length,
                height: height,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(height / 2),
                ),
              ),
            ),
            Row(
              children: options.map((option) {
                final isSelected = selectedValue == option;
                return Expanded(
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        fontWeight: fontWeight ?? FontWeight.w500,
                        fontSize: fontSize ?? 13,
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                      child: Text(option),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}