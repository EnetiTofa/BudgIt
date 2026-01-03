import 'dart:math';
import 'package:flutter/material.dart';

class CategoryRingPainter extends CustomPainter {
  final double progressRatio;
  final Color categoryColor;
  final double strokeWidth;
  final Color backgroundColor;

  CategoryRingPainter({
    required this.progressRatio,
    required this.categoryColor,
    required this.strokeWidth,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (min(size.width, size.height) / 2) - (strokeWidth / 2);

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final progressPaint = Paint()
      ..color = categoryColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt;
      
    // Draw the background ring
    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw the progress arc
    final sweepAngle = 2 * pi * min(progressRatio, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2, // Start from the top
      sweepAngle,
      false,
      progressPaint,
    );
    
    // Draw an outer ring if over budget
    if (progressRatio > 1.0) {
      final overagePaint = Paint()
        ..color = Colors.redAccent
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.butt;
      
      // The outer ring should not overlap the inner one
      final outerRadius = radius + strokeWidth; 
      final overageRatio = progressRatio - 1.0;
      final overageSweepAngle = 2 * pi * min(overageRatio, 1.0);
      
      // Draw the background for the outer ring first
      canvas.drawCircle(center, outerRadius, backgroundPaint);
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: outerRadius),
        -pi / 2,
        overageSweepAngle,
        false,
        overagePaint
      );
    }
  }

  @override
  bool shouldRepaint(covariant CategoryRingPainter oldDelegate) {
    return oldDelegate.progressRatio != progressRatio ||
           oldDelegate.backgroundColor != backgroundColor;
  }
}