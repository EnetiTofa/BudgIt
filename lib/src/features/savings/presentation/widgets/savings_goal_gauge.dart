// lib/src/features/savings/presentation/widgets/savings_goal_gauge.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:budgit/src/features/savings/presentation/savings_providers.dart';

class SavingsGoalGauge extends StatelessWidget {
  const SavingsGoalGauge({super.key, required this.data});

  final SavingsGaugeData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AspectRatio(
      aspectRatio: 1.0,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: CustomPaint(
          painter: SavingsGaugePainter(
            amountProgress: data.amountProgress,
            completedCheckIns: data.completedCheckIns,
            totalCheckIns: data.totalCheckIns,
            primaryColor: theme.colorScheme.primary,
            trackColor: theme.colorScheme.surfaceContainerLowest,
            progressColor: theme.colorScheme.primary,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '\$${data.currentAmount.toStringAsFixed(2)}',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w900,
                    fontSize: 28
                  ),
                ),
                Text(
                  'of \$${data.targetAmount.toStringAsFixed(0)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SavingsGaugePainter extends CustomPainter {
  SavingsGaugePainter({
    required this.amountProgress,
    required this.completedCheckIns,
    required this.totalCheckIns,
    required this.primaryColor,
    required this.trackColor,
    required this.progressColor,
  });

  final double amountProgress;
  final int completedCheckIns;
  final int totalCheckIns;
  final Color primaryColor;
  final Color trackColor;
  final Color progressColor;
  
  @override
  void paint(Canvas canvas, Size size) {
    const startAngle = -pi / 2;
    final center = Offset(size.width / 2, size.height / 2);

    // --- Draw Inner Ring (Amount Progress) ---
    // This part remains unchanged
    const innerRingStroke = 14.0;
    final innerRadius = (size.width / 2) - innerRingStroke - 30.0;
    
    final innerTrackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = innerRingStroke;
      
    final innerProgressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = innerRingStroke
      ..strokeCap = StrokeCap.butt;

    canvas.drawCircle(center, innerRadius, innerTrackPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: innerRadius),
      startAngle,
      2 * pi * amountProgress,
      false,
      innerProgressPaint,
    );
    
    // --- Draw Outer Ring (Check-in Progress) ---
    const outerRingStroke = 14.0;
    final outerRadius = (size.width / 2) - (outerRingStroke / 2) - 5;
    
    final totalAngleForOneItem = (2 * pi) / totalCheckIns;
    final gapAngle = max(0.07, totalAngleForOneItem * 0.15);
    final segmentAngle = totalAngleForOneItem - gapAngle;

    for (int i = 0; i < totalCheckIns; i++) {
      final bool isCompleted = i < completedCheckIns;
      final segmentPaint = Paint()
        ..color = isCompleted ? Colors.greenAccent : trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = outerRingStroke
        ..strokeCap = StrokeCap.butt; 
      
      // --- THE FIX ---
      // We add (gapAngle / 2) to the start angle.
      // This shifts the entire ring of segments forward by half a gap,
      // perfectly centering the initial gap at the 12 o'clock position.
      final segmentStartAngle = startAngle + (gapAngle / 2) + (i * (segmentAngle + gapAngle));
      // --- END OF FIX ---
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: outerRadius),
        segmentStartAngle,
        segmentAngle,
        false,
        segmentPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant SavingsGaugePainter oldDelegate) {
    return oldDelegate.amountProgress != amountProgress ||
        oldDelegate.completedCheckIns != completedCheckIns ||
        oldDelegate.totalCheckIns != totalCheckIns;
  }
}