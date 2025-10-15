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
    required this.legendColors,
  });

  final AsyncValue<CategoryGaugeData> gaugeDataAsync;
  final Color backgroundColor;
  final List<Color> legendColors;

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

  @override
  Widget build(BuildContext context) {
    final gaugeData = widget.gaugeDataAsync.value;
    final segments = gaugeData?.segments ?? [];
    final totalBudget = gaugeData?.totalBudget ?? 1.0;
    final totalSpent = gaugeData?.totalSpent ?? 0.0;
    
    final isOverBudget = totalSpent > totalBudget;
    const legendLabels = ["Wallet", "Recurring", "One-Off"];

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
                                  totalBudget: totalBudget,
                                  totalSpent: totalSpent,
                                  isOverBudget: isOverBudget,
                                  animationValue: _animation.value,
                                  backgroundColor: widget.backgroundColor,
                                  // markerColor is no longer used, but kept for consistency if needed elsewhere
                                  markerColor: Theme.of(context).colorScheme.surface,
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
                                  color: isOverBudget
                                      ? Theme.of(context).colorScheme.error
                                      : Theme.of(context).colorScheme.primary,
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
                  : Container(/* ... placeholder ... */),
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
    required this.totalSpent,
    required this.isOverBudget,
    required this.animationValue,
    required this.backgroundColor,
    required this.markerColor, // Still passed, but not used for drawing the line
  });

  final List<GaugeSegment> segments;
  final double totalBudget;
  final double totalSpent;
  final bool isOverBudget;
  final double animationValue;
  final Color backgroundColor;
  final Color markerColor;

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
    
    final denominator = isOverBudget ? totalSpent : totalBudget;
    if (denominator == 0) return;

    for (final segment in segments) {
      final sweepAngle = (segment.amount / denominator) * (2 * pi) * animationValue;
      if (sweepAngle <= 0) continue;

      totalSweepAngle += sweepAngle;
      final segmentPaint = Paint()
        ..color = segment.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(rect, startAngle + currentAngle, sweepAngle, false, segmentPaint);
      currentAngle += sweepAngle;
    }

    final drawnSegments = segments.where((s) => s.amount > 0).toList();

    if (totalSweepAngle > 0 && drawnSegments.isNotEmpty) {
      // Logic for drawing the cap of the first segment (if needed)
      // This part remains unchanged as it's not related to the budget marker.
    }
    
    // --- MODIFICATION START ---
    // Removed the budget marker drawing logic
    // if (isOverBudget) {
    //   final markerAngle = startAngle + (totalBudget / totalSpent) * (2 * pi) * animationValue;
    //   final markerPaint = Paint()
    //     ..color = markerColor
    //     ..style = PaintingStyle.stroke
    //     ..strokeWidth = 2.0;

    //   final p1 = center + Offset(cos(markerAngle) * (radius - strokeWidth / 2), sin(markerAngle) * (radius - strokeWidth / 2));
    //   final p2 = center + Offset(cos(markerAngle) * (radius + strokeWidth / 2), sin(markerAngle) * (radius + strokeWidth / 2));
    //   canvas.drawLine(p1, p2, markerPaint);
    // }
    // --- MODIFICATION END ---
  }

  @override
  bool shouldRepaint(covariant CategoryGaugePainter oldDelegate) {
    return oldDelegate.segments != segments ||
        oldDelegate.totalBudget != totalBudget ||
        oldDelegate.totalSpent != totalSpent ||
        oldDelegate.animationValue != animationValue;
  }
}