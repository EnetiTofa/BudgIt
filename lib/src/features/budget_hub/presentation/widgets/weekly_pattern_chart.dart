import 'package:flutter/material.dart';
import 'dart:math' as math;

class WeeklyPatternChart extends StatelessWidget {
  final List<double> currentPattern;
  final List<double> averagePattern;
  final Color color;
  final int startDayOfWeek; // 1 = Monday, 7 = Sunday

  const WeeklyPatternChart({
    super.key,
    required this.currentPattern,
    required this.averagePattern,
    required this.color,
    this.startDayOfWeek = 1,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final labelStyle = theme.textTheme.titleMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ) ?? TextStyle(
      color: theme.colorScheme.onSurfaceVariant,
      fontSize: 12,
      fontWeight: FontWeight.w600,
    );

    return Container(
      // 1. Reduced vertical padding (16 -> 12) to tighten the top/bottom
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Weekly Pattern", 
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(Icons.info_outline, size: 20, color: theme.colorScheme.onSurfaceVariant),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(), // Keeps the button footprint minimal
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Weekly Pattern"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("This chart compares your spending this week against your historical habits."),
                          const SizedBox(height: 16),
                          _buildLegendItem(context, "Historical Average", theme.colorScheme.surfaceContainerHighest),
                          const SizedBox(height: 8),
                          _buildLegendItem(context, "This Week", color),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Got it"),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          
          // 2. Reduced spacing between Header and Chart (16 -> 10)
          const SizedBox(height: 10),
          
          SizedBox(
            height: 140,
            width: double.infinity,
            child: CustomPaint(
              painter: _PatternPainter(
                current: currentPattern,
                average: averagePattern,
                color: color,
                ghostColor: theme.colorScheme.surfaceContainerHighest,
                startDayOfWeek: startDayOfWeek,
                labelStyle: labelStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 12),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _PatternPainter extends CustomPainter {
  final List<double> current;
  final List<double> average;
  final Color color;
  final Color ghostColor;
  final int startDayOfWeek;
  final TextStyle labelStyle;

  _PatternPainter({
    required this.current, 
    required this.average, 
    required this.color, 
    required this.ghostColor,
    required this.startDayOfWeek,
    required this.labelStyle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double chartHeight = size.height - 30;
    final double labelY = size.height - 10; 

    double maxVal = 1.0;
    for (var v in current) maxVal = math.max(maxVal, v);
    for (var v in average) maxVal = math.max(maxVal, v);
    maxVal = maxVal > 0 ? maxVal * 1.1 : 1.0; 

    final slotWidth = size.width / 7;
    final barWidth = slotWidth * 0.5;
    
    const dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    for (int i = 0; i < 7; i++) {
      final x = slotWidth * i + slotWidth / 2;
      
      // Draw Ghost Bars
      final hAvg = (average[i] / maxVal) * chartHeight;
      if (hAvg > 0) {
        canvas.drawRRect(
          RRect.fromRectAndCorners(
            Rect.fromCenter(center: Offset(x, chartHeight - hAvg/2), width: barWidth, height: hAvg),
            topLeft: const Radius.circular(2),
            topRight: const Radius.circular(2),
          ),
          Paint()..color = ghostColor,
        );
      }

      // Draw Current Bars
      final hCur = (current[i] / maxVal) * chartHeight;
      if (hCur > 0) {
        canvas.drawRRect(
          RRect.fromRectAndCorners(
            Rect.fromCenter(center: Offset(x, chartHeight - hCur/2), width: barWidth * 0.6, height: hCur),
            topLeft: const Radius.circular(2),
            topRight: const Radius.circular(2),
          ),
          Paint()..color = color,
        );
      }
      
      // Draw Labels
      final labelIndex = (startDayOfWeek - 1 + i) % 7;
      final labelText = dayLabels[labelIndex];

      final textSpan = TextSpan(
        text: labelText,
        style: labelStyle, 
      );
      
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, labelY - textPainter.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _PatternPainter oldDelegate) {
    return oldDelegate.current != current || 
           oldDelegate.average != average ||
           oldDelegate.startDayOfWeek != startDayOfWeek ||
           oldDelegate.color != color ||
           oldDelegate.labelStyle != labelStyle;
  }
}