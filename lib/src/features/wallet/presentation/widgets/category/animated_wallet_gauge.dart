import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AnimatedWalletGauge extends ConsumerStatefulWidget {
  final double remainingAmount;
  final double totalAmount;
  final Color categoryColor;
  final Duration animationDuration;
  final bool isBoostMode;
  final double boostAmount;

  const AnimatedWalletGauge({
    super.key,
    required this.remainingAmount,
    required this.totalAmount,
    required this.categoryColor,
    this.animationDuration = const Duration(milliseconds: 1200),
    this.isBoostMode = false,
    this.boostAmount = 0.0,
  });

  @override
  ConsumerState<AnimatedWalletGauge> createState() => _AnimatedWalletGaugeState();
}

class _AnimatedWalletGaugeState extends ConsumerState<AnimatedWalletGauge>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _percentageAnimation;
  late Animation<double> _remainingAmountAnimation;
  late Animation<double> _totalAmountAnimation;
  late Animation<double> _rocketOpacityAnimation;

  double _savedBoostOnEntry = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    final initialSpent = widget.totalAmount - widget.remainingAmount;
    final initialPercentage = widget.totalAmount > 0 ? (initialSpent / widget.totalAmount) : 0.0;

    _percentageAnimation = Tween<double>(begin: 0.0, end: initialPercentage).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic));
    
    _remainingAmountAnimation = Tween<double>(begin: widget.remainingAmount, end: widget.remainingAmount)
        .animate(_controller);
    _totalAmountAnimation = Tween<double>(begin: widget.totalAmount, end: widget.totalAmount)
        .animate(_controller);
    
    _rocketOpacityAnimation =
        Tween<double>(begin: 0.0, end: 0.0).animate(_controller);

    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedWalletGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    final isEnteringBoostMode = !oldWidget.isBoostMode && widget.isBoostMode;
    if (isEnteringBoostMode) {
      _savedBoostOnEntry = widget.boostAmount;
    }

    final baseTotal = widget.totalAmount - _savedBoostOnEntry;
    final baseRemaining = widget.remainingAmount - _savedBoostOnEntry;

    double targetTotal;
    double targetRemaining;

    if (widget.isBoostMode) {
      targetTotal = baseTotal + widget.boostAmount;
      targetRemaining = baseRemaining + widget.boostAmount;
    } else {
      targetTotal = widget.totalAmount;
      targetRemaining = widget.remainingAmount;
    }
    
    final potentialTotalDenominator = widget.isBoostMode ? (baseTotal + widget.boostAmount) : widget.totalAmount;
    final spentAmount = widget.totalAmount - widget.remainingAmount;
    final targetPercentage = potentialTotalDenominator > 0 ? (spentAmount / potentialTotalDenominator).clamp(0.0, 1.0) : 0.0;
    final targetRocketOpacity = widget.isBoostMode ? 1.0 : 0.0;

    if (targetTotal != _totalAmountAnimation.value ||
        targetRemaining != _remainingAmountAnimation.value ||
        targetPercentage != _percentageAnimation.value ||
        targetRocketOpacity != _rocketOpacityAnimation.value) {
          
      final bool isLeavingBoostMode = oldWidget.isBoostMode && !widget.isBoostMode;
      final bool isAdjustingBoost = widget.isBoostMode && widget.boostAmount != oldWidget.boostAmount;
      final bool shouldAnimateNumbers = isLeavingBoostMode || isAdjustingBoost;

      _percentageAnimation =
          Tween<double>(begin: _percentageAnimation.value, end: targetPercentage)
              .animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
      _rocketOpacityAnimation =
          Tween<double>(begin: _rocketOpacityAnimation.value, end: targetRocketOpacity)
              .animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

      if (shouldAnimateNumbers) {
        _remainingAmountAnimation =
            Tween<double>(begin: _remainingAmountAnimation.value, end: targetRemaining)
                .animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
        _totalAmountAnimation =
            Tween<double>(begin: _totalAmountAnimation.value, end: targetTotal)
                .animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
      } else {
        _remainingAmountAnimation = Tween<double>(begin: targetRemaining, end: targetRemaining).animate(_controller);
        _totalAmountAnimation = Tween<double>(begin: targetTotal, end: targetTotal).animate(_controller);
      }
      
      _controller
        ..duration = const Duration(milliseconds: 500)
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const String centerText = 'Remaining';
    final primaryColor = Theme.of(context).colorScheme.primary;
    
    return SizedBox(
      height: 205,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(280, 280),
                painter: _GaugePainter(
                  progress: _percentageAnimation.value,
                  color: widget.categoryColor,
                  trackColor: Theme.of(context).colorScheme.surfaceDim,
                ),
              ),
              CustomPaint(
                size: const Size(280, 280),
                painter: _RocketPainter(
                  progress: _percentageAnimation.value,
                  rocketOpacity: _rocketOpacityAnimation.value,
                  rocketColor: primaryColor,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '\$${_remainingAmountAnimation.value.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            fontSize: 46,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    Text(
                      centerText,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 185.0),
                  child: Text(
                    'Out of a total \$${_totalAmountAnimation.value.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.secondary,
                          fontSize: 17,
                        ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color trackColor;

  _GaugePainter({
    required this.progress,
    required this.color,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 30.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    const startAngle = (150 * math.pi) / 180;
    const sweepAngle = (240 * math.pi) / 180;

    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
        startAngle, sweepAngle, false, trackPaint);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
        startAngle, sweepAngle * progress, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _RocketPainter extends CustomPainter {
  final double progress;
  final double rocketOpacity;
  final Color rocketColor;

  _RocketPainter({
    required this.progress,
    required this.rocketOpacity,
    required this.rocketColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (rocketOpacity <= 0.0) return;

    const strokeWidth = 30.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    const startAngle = (150 * math.pi) / 180;
    const sweepAngle = (240 * math.pi) / 180;

    const double rocketRadiusBoost = 0; 
    final rocketPathRadius = radius + rocketRadiusBoost;
    final rocketAngle = startAngle + (sweepAngle * progress);
    final anchorPointOnArc = Offset(
      center.dx + rocketPathRadius * math.cos(rocketAngle),
      center.dy + rocketPathRadius * math.sin(rocketAngle),
    );
      
    final rocketRotation = rocketAngle + (math.pi / 2) + (math.pi / 4) + math.pi;
      
    final icon = FontAwesomeIcons.rocket;
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          color: rocketColor.withOpacity(rocketOpacity),
          fontSize: 46,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
        ),
      ),
    );
    textPainter.layout();

    const double anchorX = 0.6;
    const double anchorY = 0.405;

    final paintOffset = Offset(
      -textPainter.width * anchorX,
      -textPainter.height * anchorY,
    );

    canvas.save();
    canvas.translate(
      anchorPointOnArc.dx,
      anchorPointOnArc.dy,
    );
    canvas.rotate(rocketRotation);
    textPainter.paint(canvas, paintOffset);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _RocketPainter oldDelegate) {
    return oldDelegate.progress != progress || 
           oldDelegate.rocketOpacity != rocketOpacity ||
           oldDelegate.rocketColor != rocketColor;
  }
}