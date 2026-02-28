import 'package:flutter/material.dart';
import 'dart:math' as math;

class BudgetCircularGauge extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final Color color;
  final IconData icon;
  final double size;

  const BudgetCircularGauge({
    super.key,
    required this.progress,
    required this.color,
    required this.icon,
    this.size = 95.0,
  });

  @override
  Widget build(BuildContext context) {
    final trackColor = Theme.of(context).colorScheme.surface;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        foregroundPainter: _GaugePainter(
          progress: progress,
          trackColor: trackColor,
          progressColor: color,
          strokeWidth: 12.0,
        ),
        child: Center(
          child: Icon(
            icon,
            size: size * 0.35, // Scale icon relative to gauge size
            color: color,
          ),
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  _GaugePainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.square;

    final inset = strokeWidth / 2;
    // Define the rect for the circle
    final rect = Rect.fromLTWH(
      inset,
      inset,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    // Draw Background Track
    final path = Path()..addArc(rect, -math.pi / 2, 2 * math.pi);
    paint.color = trackColor;
    canvas.drawPath(path, paint);

    // Draw Progress Arc
    if (progress > 0) {
      paint.color = progressColor;
      final pathMetrics = path.computeMetrics().first;
      final totalLength = pathMetrics.length;
      final extractPath = pathMetrics.extractPath(0.0, totalLength * progress);
      canvas.drawPath(extractPath, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.trackColor != trackColor ||
           oldDelegate.progressColor != progressColor;
  }
}