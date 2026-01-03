import 'package:flutter/material.dart';
import 'dart:math' as math;

class WeeklyPatternChart extends StatelessWidget {
  final List<double> currentPattern;
  final List<double> averagePattern;
  final Color color;

  const WeeklyPatternChart({
    super.key,
    required this.currentPattern,
    required this.averagePattern,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Weekly Pattern", style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          width: double.infinity,
          child: CustomPaint(
            painter: _PatternPainter(
              current: currentPattern,
              average: averagePattern,
              color: color,
              ghostColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
          ),
        ),
      ],
    );
  }
}

class _PatternPainter extends CustomPainter {
  final List<double> current;
  final List<double> average;
  final Color color;
  final Color ghostColor;

  _PatternPainter({required this.current, required this.average, required this.color, required this.ghostColor});

  @override
  void paint(Canvas canvas, Size size) {
    double maxVal = 1.0;
    for (var v in current) maxVal = math.max(maxVal, v);
    for (var v in average) maxVal = math.max(maxVal, v);
    maxVal *= 1.1;

    final slotWidth = size.width / 7;
    final barWidth = slotWidth * 0.5;

    for (int i = 0; i < 7; i++) {
      final x = slotWidth * i + slotWidth / 2;
      
      // Draw Ghost
      final hAvg = (average[i] / maxVal) * size.height;
      if (hAvg > 0) {
        canvas.drawRect(
          Rect.fromCenter(center: Offset(x, size.height - hAvg/2), width: barWidth, height: hAvg),
          Paint()..color = ghostColor,
        );
      }

      // Draw Current
      final hCur = (current[i] / maxVal) * size.height;
      if (hCur > 0) {
        canvas.drawRect(
          Rect.fromCenter(center: Offset(x, size.height - hCur/2), width: barWidth * 0.6, height: hCur),
          Paint()..color = color,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}