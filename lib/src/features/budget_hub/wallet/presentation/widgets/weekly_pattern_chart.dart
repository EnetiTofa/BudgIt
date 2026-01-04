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
    
    // 1. Prepare the TextStyle here
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
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Weekly Pattern", 
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
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
    // 1. Increase gap: Reserve 30px at bottom for labels (was 20)
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
      
      // 2. Draw Ghost Bars (Top Corners Rounded Only)
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

      // 3. Draw Current Bars (Top Corners Rounded Only)
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