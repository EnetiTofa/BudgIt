import 'dart:math';
import 'package:flutter/material.dart';

enum SpeedometerSize { small, large }

class WalletSpeedometer extends StatelessWidget {
  final double targetAverage;
  final double currentAverage;
  final Color color;
  final SpeedometerSize size;

  const WalletSpeedometer({
    super.key,
    required this.targetAverage,
    required this.currentAverage,
    required this.color,
    this.size = SpeedometerSize.small,
  });

  @override
  Widget build(BuildContext context) {
    // Return the correct painter based on the size, without a SizedBox constraint for the large version.
    if (size == SpeedometerSize.small) {
      return SizedBox(
        width: 22,
        height: 11,
        child: CustomPaint(
          size: const Size(22, 22),
          painter: _SmallSpeedometerPainter(
            targetAverage: targetAverage,
            currentValue: currentAverage,
            color: color,
          ),
        ),
      );
    } else { // Large
      return SizedBox(
        width: 70, // You can change this value
        height: 35,  // You can change this value
        child: CustomPaint(
          painter: _LargeSpeedometerPainter(
            targetAverage: targetAverage,
            currentValue: currentAverage,
            categoryColor: color,
            primaryColor: Theme.of(context).colorScheme.primary,
            surfaceColor: Theme.of(context).colorScheme.surfaceContainerLow,
          ),
        ),
      );
    }
  }
}

// This is the new painter for the larger version
class _LargeSpeedometerPainter extends CustomPainter {
  final double targetAverage;
  final double currentValue;
  final Color categoryColor;
  final Color primaryColor;
  final Color surfaceColor;

  _LargeSpeedometerPainter({
    required this.targetAverage,
    required this.currentValue,
    required this.categoryColor,
    required this.primaryColor,
    required this.surfaceColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height); // Anchor at the bottom center
    final radius = size.width / 2;
    const startAngle = pi;
    const sweepAngle = pi;
    const scaleWidth = 10.0;

    // 1. Draw the background scale
    final scalePaint = Paint()
      ..color = categoryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = scaleWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle, sweepAngle, false, scalePaint,
    );

    // 2. Draw the center tick mark for the target average
    const tickAngle = -pi / 2;
    final tickPaint = Paint()
      ..color = surfaceColor // Use surface color for the notch
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;
      
    final tickStart = Offset(
      center.dx + (radius - scaleWidth / 2) * cos(tickAngle),
      center.dy + (radius - scaleWidth / 2) * sin(tickAngle),
    );
    final tickEnd = Offset(
      center.dx + (radius + scaleWidth / 2) * cos(tickAngle),
      center.dy + (radius + scaleWidth / 2) * sin(tickAngle),
    );
    canvas.drawLine(tickStart, tickEnd, tickPaint);
    
    // 3. Calculate and draw the needle
    final gaugeMax = targetAverage > 0 ? targetAverage * 2 : 1.0;
    final percentage = (currentValue / gaugeMax).clamp(0.0, 1.0);
    final angle = startAngle + (percentage * sweepAngle);

    final needlePaint = Paint()..color = primaryColor..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(center.dx + (radius - 2) * cos(angle), center.dy + (radius - 2) * sin(angle))
      ..lineTo(center.dx + 5 * cos(angle - pi / 2), center.dy + 5 * sin(angle - pi / 2))
      ..lineTo(center.dx + 5 * cos(angle + pi / 2), center.dy + 5 * sin(angle + pi / 2))
      ..close();

    canvas.drawPath(path, needlePaint);
    canvas.drawCircle(center, 5, needlePaint);
  }

  @override
  bool shouldRepaint(covariant _LargeSpeedometerPainter oldDelegate) {
    return oldDelegate.currentValue != currentValue ||
           oldDelegate.categoryColor != categoryColor ||
           oldDelegate.primaryColor != primaryColor;
  }
}

class _SmallSpeedometerPainter extends CustomPainter {
  final double targetAverage;
  final double currentValue;
  final Color color;

  _SmallSpeedometerPainter({
    required this.targetAverage,
    required this.currentValue,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // V-- Change the center's Y-coordinate to size.height
    final center = Offset(size.width / 2, size.height); 
    final radius = size.height - 1;
    final double scaleWidth = size.height * 0.35;
    final double hubSize = size.height * 0.15;
    const startAngle = pi;
    const sweepAngle = pi;

    final backgroundPaint = Paint()
      ..color = color.withAlpha(100)
      ..style = PaintingStyle.stroke
      ..strokeWidth = scaleWidth
      ..strokeCap = StrokeCap.round;

    if (radius > 0) {
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweepAngle, false, backgroundPaint);
    }
    
    final double gaugeMax = targetAverage * 2;
    final progress = (gaugeMax > 0) ? (currentValue / gaugeMax).clamp(0.0, 1.0) : 0.5;
    final angle = startAngle + (progress * sweepAngle);

    final needlePaint = Paint()..color = color..style = PaintingStyle.fill;

    if (radius > 0) {
      final path = Path();
      path.moveTo(center.dx + (radius + scaleWidth / 2) * cos(angle), center.dy + (radius + scaleWidth / 2) * sin(angle));
      path.lineTo(center.dx + hubSize * cos(angle - (pi / 2)), center.dy + hubSize * sin(angle - (pi / 2)));
      path.lineTo(center.dx + hubSize * cos(angle + (pi / 2)), center.dy + hubSize * sin(angle + (pi / 2)));
      path.close();
      canvas.drawPath(path, needlePaint);
    }
    canvas.drawCircle(center, hubSize, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _SmallSpeedometerPainter oldDelegate) {
    return oldDelegate.currentValue != currentValue || oldDelegate.color != color;
  }
}