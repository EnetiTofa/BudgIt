import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:budgit/src/core/domain/models/category.dart';
import 'package:budgit/src/features/categories/presentation/controllers/manage_category_controller.dart';
import 'package:budgit/src/utils/palette_generator.dart';

// REFACTORED: Unified to the new binary paradigm
enum GaugeSegmentType { fixed, variable, center, none }

class InteractiveBudgetGauge extends StatefulWidget {
  const InteractiveBudgetGauge({
    super.key,
    required this.category,
    required this.state,
    required this.selectedSegment,
    required this.onSegmentTapped,
  });

  final Category category;
  final ManageCategoryState state;
  final GaugeSegmentType selectedSegment;
  final ValueChanged<GaugeSegmentType> onSegmentTapped;

  @override
  State<InteractiveBudgetGauge> createState() => _InteractiveBudgetGaugeState();
}

class _InteractiveBudgetGaugeState extends State<InteractiveBudgetGauge>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  GaugeSegmentType _previousSegment = GaugeSegmentType.center;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void didUpdateWidget(covariant InteractiveBudgetGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedSegment != oldWidget.selectedSegment) {
      _previousSegment = oldWidget.selectedSegment;
      _animationController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap(BuildContext context, TapUpDetails details) {
    final box = context.findRenderObject() as RenderBox;
    final size = box.size;
    final center = Offset(size.width / 2, size.height / 2);
    final tapPosition = details.localPosition;

    final strokeWidth = size.width * 0.16;
    final baseRadius = (size.width / 2) * 0.80;

    final outerBounds = baseRadius * 1.1;
    final innerBounds = outerBounds - strokeWidth * 1.5;

    final dx = tapPosition.dx - center.dx;
    final dy = tapPosition.dy - center.dy;
    final distance = sqrt(dx * dx + dy * dy);

    if (distance > innerBounds && distance < outerBounds) {
      double angle = atan2(dy, dx);
      if (angle < 0) angle += 2 * pi;

      final totalAngle = 2 * pi;
      final budget = widget.state.totalBudget <= 0
          ? 1.0
          : widget.state.totalBudget;

      // We only need to find the boundary of the fixed (recurring) expenses
      final fixedAngle = (widget.state.recurringSum / budget) * totalAngle;

      final adjustedAngle = (angle + pi / 2) % (2 * pi);

      // Binary tap detection
      if (adjustedAngle <= fixedAngle) {
        widget.onSegmentTapped(GaugeSegmentType.fixed);
      } else {
        widget.onSegmentTapped(GaugeSegmentType.variable);
      }
    } else if (distance < innerBounds) {
      widget.onSegmentTapped(GaugeSegmentType.center);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = generateSpendingPalette(widget.category.color);
    final trackColor = Theme.of(context).colorScheme.surfaceDim;

    return GestureDetector(
      onTapUp: (details) => _handleTap(context, details),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return CustomPaint(
              painter: _InteractiveGaugePainter(
                total: widget.state.totalBudget,
                fixed: widget.state.recurringSum,
                variable: widget.state.variableBudget,
                fixedColor: palette.recurring,
                variableColor: palette.wallet,
                trackColor: trackColor,
                selectedSegment: widget.selectedSegment,
                previousSegment: _previousSegment,
                animationValue: _animation.value,
              ),
              child: child,
            );
          },
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '\$${widget.state.totalBudget.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 28,
                  ),
                ),
                Text(
                  'Total per Month',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
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

class _InteractiveGaugePainter extends CustomPainter {
  const _InteractiveGaugePainter({
    required this.total,
    required this.fixed,
    required this.variable,
    required this.fixedColor,
    required this.variableColor,
    required this.trackColor,
    required this.selectedSegment,
    required this.previousSegment,
    required this.animationValue,
  });

  final double total;
  final double fixed;
  final double variable;
  final Color fixedColor;
  final Color variableColor;
  final Color trackColor;
  final GaugeSegmentType selectedSegment;
  final GaugeSegmentType previousSegment;
  final double animationValue;

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.width * 0.16;
    final center = Offset(size.width / 2, size.height / 2);
    const startAngle = -pi / 2;
    final totalAngle = 2 * pi;

    final budget = total <= 0 ? 1.0 : total;

    final baseRadius = (size.width / 2) * 0.80;
    final selectedRadius = baseRadius * 1.08;

    double getAnimatedRadius(GaugeSegmentType segment) {
      if (segment == selectedSegment)
        return lerpDouble(baseRadius, selectedRadius, animationValue)!;
      if (segment == previousSegment)
        return lerpDouble(selectedRadius, baseRadius, animationValue)!;
      return baseRadius;
    }

    final fixedRadius = getAnimatedRadius(GaugeSegmentType.fixed);
    final variableRadius = getAnimatedRadius(GaugeSegmentType.variable);

    // 1. Draw the 'surfaceDim' track that sits behind everything.
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: baseRadius - (strokeWidth / 2)),
      startAngle,
      totalAngle,
      false,
      trackPaint,
    );

    // 2. Draw the Fixed segment
    final fixedSweep = (fixed / budget) * totalAngle;
    final fixedPaint = Paint()
      ..color = fixedColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: fixedRadius - (strokeWidth / 2)),
      startAngle,
      fixedSweep,
      false,
      fixedPaint,
    );

    // 3. Draw the Variable segment
    final variableSweep = (variable / budget) * totalAngle;
    final variablePaint = Paint()
      ..color = variableColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawArc(
      Rect.fromCircle(
        center: center,
        radius: variableRadius - (strokeWidth / 2),
      ),
      startAngle + fixedSweep,
      variableSweep,
      false,
      variablePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _InteractiveGaugePainter oldDelegate) {
    return true;
  }
}
