import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SegmentedLinearGauge extends StatelessWidget {
  final double totalBudget;
  final double spent;
  final List<double> dailySpending;
  final Color backgroundColor; // Card background (Category Color)
  final Color foregroundColor; // Text/Content Color

  const SegmentedLinearGauge({
    super.key,
    required this.totalBudget,
    required this.spent,
    required this.dailySpending,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: '\$');
    
    // Logic: Warning colors if overspent
    final isOverspent = spent > totalBudget;
    final valueColor = isOverspent ? Colors.redAccent : foregroundColor;
    
    // Gauge Colors
    final trackColor = theme.colorScheme.surface.withOpacity(0.7);
    final gaugeFillColor = isOverspent 
        ? Colors.redAccent
        : backgroundColor.withOpacity(0.7);

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      color: backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.zero, 
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Spending", 
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: foregroundColor,
                    fontSize: 16,
                  ),
                ),
                RichText(
                  text: TextSpan(
                    style: theme.textTheme.bodyMedium?.copyWith(color: foregroundColor.withOpacity(0.8)),
                    children: <TextSpan>[
                      TextSpan(
                        text: currencyFormat.format(spent),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: valueColor, 
                        ),
                      ),
                      TextSpan(
                        text: ' / ${currencyFormat.format(totalBudget)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                        )
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // The Gauge Bar
            SizedBox(
              height: 16,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final maxWidth = constraints.maxWidth;
                  final safeBudget = totalBudget > 0 ? totalBudget : 1.0;

                  // Find the last index that actually has spending
                  final int lastActiveIndex = dailySpending.lastIndexWhere((amount) => amount > 0);

                  List<Widget> segmentWidgets = [];
                  double currentX = 0.0;
                  const double gapSize = 2.0;

                  for (int i = 0; i < dailySpending.length; i++) {
                    final dayAmount = dailySpending[i];
                    if (dayAmount <= 0) continue;

                    // 1. Check if visually last
                    final bool isVisuallyLast = (i == lastActiveIndex);

                    // 2. Calculate Width
                    final double rawTotalWidth = (dayAmount / safeBudget) * maxWidth;

                    // 3. Gap Logic: 0.0 if it's the last visible bar
                    final double actualGap = isVisuallyLast ? 0.0 : gapSize;

                    // 4. Color Bar Width
                    double colorBarWidth = rawTotalWidth - actualGap;
                    if (colorBarWidth < 0) colorBarWidth = 0;

                    if (currentX >= maxWidth) break;
                    
                    if (currentX + colorBarWidth > maxWidth) {
                      colorBarWidth = maxWidth - currentX;
                    }

                    // 5. Draw Segment
                    segmentWidgets.add(Positioned(
                      left: currentX,
                      width: colorBarWidth,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: gaugeFillColor,
                          borderRadius: BorderRadius.horizontal(
                            // Left is rounded only at start of gauge
                            left: (currentX == 0) ? const Radius.circular(10) : Radius.zero,
                            // Right is ALWAYS flat (Radius.zero)
                            right: Radius.zero,
                          ),
                        ),
                      ),
                    ));

                    // 6. Draw Separator (Only if NOT visually last)
                    if (!isVisuallyLast && (currentX + colorBarWidth + actualGap <= maxWidth)) {
                      segmentWidgets.add(Positioned(
                        left: currentX + colorBarWidth,
                        width: actualGap,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          color: backgroundColor, 
                        ),
                      ));
                    }

                    currentX += (colorBarWidth + actualGap);
                  }

                  // ClipRRect ensures that if the bar hits 100%, the outer edges are still rounded
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      children: [
                        // Track
                        Container(
                          color: trackColor,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                        // Segments
                        ...segmentWidgets,
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}