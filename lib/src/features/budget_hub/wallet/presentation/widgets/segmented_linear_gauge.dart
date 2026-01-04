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
    
    // Text Color: Yellow if overspent, else Foreground
    final valueColor = isOverspent ? Colors.yellow.shade200 : foregroundColor;
    
    // Gauge Colors (Matching WalletCategoryCard)
    // Track: Surface with 0.7 opacity
    final trackColor = theme.colorScheme.surface.withOpacity(0.7);
    
    // Fill: Category Color (backgroundColor) with 0.7 opacity OR Yellow if overspent
    final gaugeFillColor = isOverspent 
        ? Colors.yellow.shade200 
        : backgroundColor.withOpacity(0.7);

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      color: backgroundColor, // Card is Category Color
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.zero, 
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Title & RichText Amount
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
                  
                  // Build Segments
                  List<Widget> segmentWidgets = [];
                  double currentX = 0.0;
                  const double gap = 2.0;

                  for (final dayAmount in dailySpending) {
                    if (dayAmount <= 0) continue;
                    
                    final double rawWidth = (dayAmount / safeBudget) * maxWidth;
                    if (currentX >= maxWidth) break;
                    
                    double drawWidth = rawWidth;
                    if (currentX + drawWidth > maxWidth) {
                      drawWidth = maxWidth - currentX;
                    }
                    
                    final double visibleWidth = (drawWidth - gap).clamp(0.0, maxWidth);
                    
                    if (visibleWidth > 0) {
                      segmentWidgets.add(
                        Positioned(
                          left: currentX,
                          width: visibleWidth,
                          top: 0, 
                          bottom: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: gaugeFillColor, // The requested fill color
                              // Only round the very first segment's left side
                              borderRadius: BorderRadius.horizontal(
                                left: (currentX == 0) ? const Radius.circular(10) : Radius.zero,
                              ),
                            ),
                          ),
                        )
                      );
                    }
                    currentX += drawWidth;
                  }

                  return ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      children: [
                        // 1. Unfilled Track (Requested: Surface with 0.7 opacity)
                        Container(
                          color: trackColor, 
                          width: double.infinity,
                          height: double.infinity,
                        ),
                        
                        // 2. Spending Segments
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