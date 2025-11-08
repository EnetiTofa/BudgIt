import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:budgit/src/core/domain/models/category.dart';
import 'package:budgit/src/features/categories/presentation/controllers/manage_category_controller.dart';
// Add this import
import 'package:budgit/src/utils/palette_generator.dart';

enum GaugeSegmentType { recurring, wallet, oneOffs, center, none }

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

class _InteractiveBudgetGaugeState extends State<InteractiveBudgetGauge> with SingleTickerProviderStateMixin {
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
    _animation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
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
      final budget = widget.state.totalBudget <= 0 ? 1.0 : widget.state.totalBudget;
      final recurringAngle = (widget.state.recurringSum / budget) * totalAngle;
      final walletAngle = recurringAngle + (widget.state.walletAmount / budget) * totalAngle;
      
      final adjustedAngle = (angle + pi / 2) % (2 * pi);

      if (adjustedAngle <= recurringAngle) {
        widget.onSegmentTapped(GaugeSegmentType.recurring);
      } else if (adjustedAngle <= walletAngle) {
        widget.onSegmentTapped(GaugeSegmentType.wallet);
      }
    } else if (distance < innerBounds) {
      widget.onSegmentTapped(GaugeSegmentType.center);
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- MODIFIED CODE ---
    final palette = generateSpendingPalette(widget.category.color);
    final trackColor = Theme.of(context).colorScheme.surfaceDim;
    // --- END OF MODIFICATION ---

    return GestureDetector(
      onTapUp: (details) => _handleTap(context, details),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return CustomPaint(
              // --- MODIFIED CODE ---
              painter: _InteractiveGaugePainter(
                total: widget.state.totalBudget,
                recurring: widget.state.recurringSum,
                wallet: widget.state.monthlyWalletAmount,
                oneOffs: widget.state.oneOffsAmount,
                recurringColor: palette.recurring, // Use medium shade
                walletColor: palette.wallet,       // Use lightest shade
                oneOffsColor: palette.oneOff,      // Use darkest shade
                trackColor: trackColor,
                selectedSegment: widget.selectedSegment,
                previousSegment: _previousSegment,
                animationValue: _animation.value,
              ),
              // --- END OF MODIFICATION ---
              child: child,
            );
          },
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '\$${widget.state.totalBudget.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, fontSize: 28),
                ),
                Text(
                  'Total per Month',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500, fontSize: 12),
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
    required this.recurring,
    required this.wallet,
    required this.oneOffs,
    required this.recurringColor,
    required this.walletColor,
    required this.oneOffsColor,
    required this.trackColor,
    required this.selectedSegment,
    required this.previousSegment,
    required this.animationValue,
  });

  final double total;
  final double recurring;
  final double wallet;
  final double oneOffs;
  final Color recurringColor;
  final Color walletColor;
  final Color oneOffsColor;
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
      if (segment == selectedSegment) return lerpDouble(baseRadius, selectedRadius, animationValue)!;
      if (segment == previousSegment) return lerpDouble(selectedRadius, baseRadius, animationValue)!;
      return baseRadius;
    }
    
    final recurringRadius = getAnimatedRadius(GaugeSegmentType.recurring);
    final walletRadius = getAnimatedRadius(GaugeSegmentType.wallet);
    final oneOffsRadius = getAnimatedRadius(GaugeSegmentType.oneOffs);
    
    // 1. Draw the 'surfaceDim' track that sits behind everything.
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawArc(Rect.fromCircle(center: center, radius: baseRadius - (strokeWidth / 2)), startAngle, totalAngle, false, trackPaint);

    // 2. Draw the Recurring segment on top of the track
    final recurringSweep = (recurring / budget) * totalAngle;
    final recurringPaint = Paint()
      ..color = recurringColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawArc(Rect.fromCircle(center: center, radius: recurringRadius - (strokeWidth / 2)), startAngle, recurringSweep, false, recurringPaint);

    // 3. Draw the Wallet segment
    final walletSweep = (wallet / budget) * totalAngle;
    final walletPaint = Paint()
      ..color = walletColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawArc(Rect.fromCircle(center: center, radius: walletRadius - (strokeWidth / 2)), startAngle + recurringSweep, walletSweep, false, walletPaint);
    
    // 4. Draw the One-Offs segment
    final oneOffsSweep = (oneOffs / budget) * totalAngle;
    final oneOffsPaint = Paint()
      ..color = oneOffsColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawArc(Rect.fromCircle(center: center, radius: oneOffsRadius - (strokeWidth / 2)), startAngle + recurringSweep + walletSweep, oneOffsSweep, false, oneOffsPaint);
  }

  @override
  bool shouldRepaint(covariant _InteractiveGaugePainter oldDelegate) {
    return true;
  }
}