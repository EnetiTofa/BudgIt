// lib/src/features/budget_hub/budgets/presentation/widgets/unified_budget_gauge.dart

import 'dart:math';
import 'package:flutter/material.dart';

/// A generic data class for any segment on the gauge
class GaugeSegment {
  final String label;
  final double amount;
  final Color color;

  const GaugeSegment({
    required this.label,
    required this.amount,
    required this.color,
  });
}

class UnifiedBudgetGauge extends StatefulWidget {
  const UnifiedBudgetGauge({
    super.key,
    required this.segments,
    required this.totalBudget,
    required this.totalSpent,
    this.labelSuffix = "Spent",
    this.showLegend = false, // Toggle to show keys underneath
  });

  final List<GaugeSegment> segments;
  final double totalBudget;
  final double totalSpent;
  final String labelSuffix;
  final bool showLegend;

  @override
  State<UnifiedBudgetGauge> createState() => _UnifiedBudgetGaugeState();
}

class _UnifiedBudgetGaugeState extends State<UnifiedBudgetGauge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant UnifiedBudgetGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the data structure changes significantly, re-animate
    if (oldWidget.totalSpent != widget.totalSpent || 
        oldWidget.totalBudget != widget.totalBudget) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isOverBudget = widget.totalSpent > widget.totalBudget;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. The Gauge
        SizedBox(
          height: 250, // Fixed height for the gauge area
          child: AspectRatio(
            aspectRatio: 1.0,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return CustomPaint(
                      size: Size.infinite,
                      painter: _GaugePainter(
                        segments: widget.segments,
                        totalBudget: widget.totalBudget,
                        totalSpent: widget.totalSpent,
                        isOverBudget: isOverBudget,
                        animationValue: _animation.value,
                        backgroundColor: Theme.of(context).colorScheme.surfaceDim,
                      ),
                    );
                  },
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '\$${widget.totalSpent.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 32, // Increased slightly for impact
                        fontWeight: FontWeight.w900,
                        color: isOverBudget
                            ? Theme.of(context).colorScheme.error
                            : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.labelSuffix,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        // 2. The Legend (Optional)
        if (widget.showLegend && widget.segments.isNotEmpty) ...[
          const SizedBox(height: 24),
          Wrap(
            spacing: 16.0,
            runSpacing: 8.0,
            alignment: WrapAlignment.center,
            children: widget.segments.map((segment) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: segment.color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    segment.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ]
      ],
    );
  }
}

class _GaugePainter extends CustomPainter {
  const _GaugePainter({
    required this.segments,
    required this.totalBudget,
    required this.totalSpent,
    required this.isOverBudget,
    required this.animationValue,
    required this.backgroundColor,
  });

  final List<GaugeSegment> segments;
  final double totalBudget;
  final double totalSpent;
  final bool isOverBudget;
  final double animationValue;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 30.0; // Original thickness maintained
    const startAngle = -pi / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - (strokeWidth / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Draw Background Ring
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawArc(rect, 0, 2 * pi, false, backgroundPaint);

    // Draw Segments
    double currentAngle = 0.0;
    
    // Determine the denominator (Total Budget, or Total Spent if over budget)
    final denominator = isOverBudget ? totalSpent : totalBudget;
    if (denominator == 0) return;

    for (final segment in segments) {
      if (segment.amount <= 0) continue;

      final sweepAngle = (segment.amount / denominator) * (2 * pi) * animationValue;
      
      final segmentPaint = Paint()
        ..color = segment.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt; // Butt cap for clean segment joins

      canvas.drawArc(rect, startAngle + currentAngle, sweepAngle, false, segmentPaint);
      currentAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.segments != segments ||
        oldDelegate.totalBudget != totalBudget ||
        oldDelegate.totalSpent != totalSpent ||
        oldDelegate.animationValue != animationValue;
  }
}