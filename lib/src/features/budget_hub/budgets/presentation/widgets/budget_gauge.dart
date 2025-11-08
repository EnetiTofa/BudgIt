// lib/src/features/budgets/presentation/widgets/budget_gauge.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:budgit/src/features/budget_hub/budgets/domain/budget_progress.dart';


class BudgetGauge extends StatefulWidget {
  const BudgetGauge({
    super.key,
    required this.progressList,
    required this.selectedDate,
  });

  final List<BudgetProgress> progressList;
  final DateTime selectedDate;

  @override
  State<BudgetGauge> createState() => _BudgetGaugeState();
}

class _BudgetGaugeState extends State<BudgetGauge>
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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant BudgetGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progressList != widget.progressList) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double totalSpent = widget.progressList
        .fold(0.0, (sum, item) => sum + item.amountSpent);
    final double totalBudget = widget.progressList
        .fold(0.0, (sum, item) => sum + item.projectedBudget);
    
    final isOverBudget = totalSpent > totalBudget;

    final now = DateTime.now();
    final bool isThisMonth =
        widget.selectedDate.year == now.year && widget.selectedDate.month == now.month;
    final String monthLabel = isThisMonth
        ? "this Month"
        : "in ${DateFormat.MMM().format(widget.selectedDate)}";

    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 0.0),
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
                  painter: GaugePainter(
                    progressList: widget.progressList,
                    totalBudget: totalBudget,
                    totalSpent: totalSpent,
                    isOverBudget: isOverBudget,
                    animationValue: _animation.value,
                    backgroundColor: Theme.of(context).colorScheme.surfaceDim,
                    // markerColor is no longer used, but kept for consistency
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
                  'Spent $monthLabel',
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
    );
  }
}

class GaugePainter extends CustomPainter {
  const GaugePainter({
    required this.progressList,
    required this.totalBudget,
    required this.totalSpent,
    required this.isOverBudget,
    required this.animationValue,
    required this.backgroundColor,
    required this.markerColor, // Still passed, but not used for drawing the line
  });

  final List<BudgetProgress> progressList;
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

    for (final progress in progressList) {
      final sweepAngle = (progress.amountSpent / denominator) * (2 * pi) * animationValue;
      totalSweepAngle += sweepAngle;
      final segmentPaint = Paint()
        ..color = progress.category.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(rect, startAngle + currentAngle, sweepAngle, false, segmentPaint);
      currentAngle += sweepAngle;
    }

    final spendingProgress = progressList.where((p) => p.amountSpent > 0).toList();

    if (totalSweepAngle > 0 && spendingProgress.isNotEmpty) {
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
  bool shouldRepaint(covariant GaugePainter oldDelegate) {
    return oldDelegate.progressList != progressList ||
        oldDelegate.totalBudget != totalBudget ||
        oldDelegate.totalSpent != totalSpent ||
        oldDelegate.animationValue != animationValue;
  }
}