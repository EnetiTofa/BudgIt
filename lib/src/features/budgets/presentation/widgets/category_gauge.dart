// lib/src/features/budgets/presentation/widgets/category_gauge.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/features/budgets/presentation/providers/category_gauge_data_provider.dart';

class GaugeSegment {
  final String label;
  final double amount;
  final Color color;
  GaugeSegment(this.label, this.amount, this.color);
}

class CategoryGauge extends StatefulWidget {
  const CategoryGauge({
    super.key,
    required this.gaugeDataAsync,
    required this.backgroundColor,
    required this.legendColors, // MODIFIED: Accept legend colors
  });

  final AsyncValue<CategoryGaugeData> gaugeDataAsync;
  final Color backgroundColor;
  final List<Color> legendColors; // e.g., [recurringColor, walletColor, oneOffColor]

  @override
  State<CategoryGauge> createState() => _CategoryGaugeState();
}

class _CategoryGaugeState extends State<CategoryGauge>
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
    if (widget.gaugeDataAsync.hasValue) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant CategoryGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.gaugeDataAsync.hasValue && widget.gaugeDataAsync.hasValue ||
        widget.gaugeDataAsync.value != oldWidget.gaugeDataAsync.value) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // REMOVED: _buildRealLegendItem is no longer needed.

  @override
  Widget build(BuildContext context) {
    final gaugeData = widget.gaugeDataAsync.value;
    final segments = gaugeData?.segments ?? [];
    final totalBudget = gaugeData?.totalBudget ?? 1.0;
    final totalSpent = gaugeData?.totalSpent ?? 0.0;
    
    // --- THE FIX IS HERE ---
    // The legend is now built from static data, not the changing `segments`.
    const legendLabels = ["Recurring", "Wallet", "One-Off"];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 1,
          child: SizedBox(
            height: 85,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: widget.legendColors[index],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          legendLabels[index],
                          style: const TextStyle(fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
        // --- END OF FIX ---
        const SizedBox(width: 24),
        Expanded(
          flex: 2,
          child: AspectRatio(
            aspectRatio: 1.0,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: gaugeData != null
                  ? Container(
                      key: ValueKey(gaugeData.totalSpent),
                      color: Theme.of(context).colorScheme.surface,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          AnimatedBuilder(
                            animation: _animation,
                            builder: (context, child) {
                              return CustomPaint(
                                size: Size.infinite,
                                painter: CategoryGaugePainter(
                                  segments: segments,
                                  totalBudget:
                                      totalBudget > 0 ? totalBudget : 1,
                                  animationValue: _animation.value,
                                  backgroundColor: widget.backgroundColor,
                                ),
                              );
                            },
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '\$${totalSpent.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              Text(
                                'of \$${totalBudget.toStringAsFixed(0)} spent',
                                style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  : Container(
                      key: const ValueKey('gauge_placeholder'),
                      decoration: BoxDecoration(
                        color: widget.backgroundColor,
                        shape: BoxShape.circle,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class CategoryGaugePainter extends CustomPainter {
  const CategoryGaugePainter({
    required this.segments,
    required this.totalBudget,
    required this.animationValue,
    required this.backgroundColor,
  });

  final List<GaugeSegment> segments;
  final double totalBudget;
  final double animationValue;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 30.0;
    const startAngle = -pi / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - (strokeWidth / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawArc(rect, 0, 2 * pi, false, backgroundPaint);

    double currentAngle = 0.0;
    double totalSweepAngle = 0;

    for (final segment in segments) {
      final sweepAngle = (segment.amount / totalBudget) * (2 * pi) * animationValue;
      if (sweepAngle <= 0) continue;

      totalSweepAngle += sweepAngle;
      final segmentPaint = Paint()
        ..color = segment.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        rect,
        startAngle + currentAngle,
        sweepAngle,
        false,
        segmentPaint,
      );
      currentAngle += sweepAngle;
    }

    final drawnSegments = segments.where((s) => s.amount > 0).toList();

    if (totalSweepAngle > 0 && drawnSegments.isNotEmpty) {
      final startCapOffset = Offset(
        center.dx + radius * cos(startAngle),
        center.dy + radius * sin(startAngle),
      );
      final startCapPaint = Paint()..color = drawnSegments.first.color;
      canvas.drawCircle(startCapOffset, strokeWidth / 2, startCapPaint);

      final endAngle = startAngle + totalSweepAngle;
      final endCapOffset = Offset(
        center.dx + radius * cos(endAngle),
        center.dy + radius * sin(endAngle),
      );
      final endCapPaint = Paint()..color = drawnSegments.last.color;
      canvas.drawCircle(endCapOffset, strokeWidth / 2, endCapPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CategoryGaugePainter oldDelegate) {
    return oldDelegate.segments != segments ||
        oldDelegate.totalBudget != totalBudget ||
        oldDelegate.animationValue != animationValue;
  }
}