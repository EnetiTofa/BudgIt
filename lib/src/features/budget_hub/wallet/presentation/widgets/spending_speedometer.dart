import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:budgit/src/common_widgets/custom_toggle.dart';

class SpendingSpeedometer extends StatefulWidget {
  final double currentSpeed;      // Average Daily Spending (Past)
  final double recommendedSpeed;  // Recommended Daily Spending (Future)
  final Color color;              // This is the CATEGORY color

  const SpendingSpeedometer({
    super.key,
    required this.currentSpeed,
    required this.recommendedSpeed,
    required this.color,
  });

  @override
  State<SpendingSpeedometer> createState() => _SpendingSpeedometerState();
}

class _SpendingSpeedometerState extends State<SpendingSpeedometer> with SingleTickerProviderStateMixin {
  String _selectedMode = "Average";
  
  late AnimationController _controller;
  late Animation<double> _animation;
  
  // Track start and end for smooth transitions
  double _beginValue = 0.0;
  double _endValue = 0.0;

  @override
  void initState() {
    super.initState();
    _endValue = widget.currentSpeed;
    _beginValue = 0.0; 

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _setupAnimation();
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant SpendingSpeedometer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentSpeed != widget.currentSpeed || 
        oldWidget.recommendedSpeed != widget.recommendedSpeed) {
      _updateTarget();
    }
  }

  void _setupAnimation() {
    _animation = Tween<double>(begin: _beginValue, end: _endValue).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  void _updateTarget() {
    setState(() {
      _beginValue = _animation.value;
      _endValue = _selectedMode == "Average" ? widget.currentSpeed : widget.recommendedSpeed;
    });

    _setupAnimation();
    _controller.reset();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Scale Logic
    final maxVal = math.max(widget.currentSpeed, widget.recommendedSpeed) * 1.5;
    final safeMax = maxVal > 0 ? maxVal : 100.0;
    
    // Adjust sizeScale to fit your screen width preference
    const double sizeScale = 0.85; 

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. The Speedometer Arc & Needle
        SizedBox(
          height: 150 * sizeScale, 
          width: 260 * sizeScale,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return CustomPaint(
                painter: _SpeedometerPainter(
                  value: _animation.value,
                  maxValue: safeMax,
                  categoryColor: widget.color,
                  appPrimaryColor: theme.colorScheme.primary, // Needle Color
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                ),
              );
            },
          ),
        ),
        
        // Spacing between Needle Pivot and Text
        const SizedBox(height: 28),

        // 2. The Value Text (Now outside the paint area to avoid overlap)
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Text(
              "\$${_animation.value.toStringAsFixed(2)}",
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: theme.colorScheme.primary, // Requested: Theme Primary Color
                fontSize: 40 * sizeScale, 
              ),
            );
          },
        ),
        
        // Spacing between Text and Toggle
        const SizedBox(height: 15),

        // 3. Custom Toggle
        CustomToggle(
          options: const ["Average", "Recommended"],
          selectedValue: _selectedMode,
          onChanged: (val) {
            _selectedMode = val;
            _updateTarget();
          },
          width: 240,
          height: 35,
          fontSize: 13,
        ),
      ],
    );
  }
}

class _SpeedometerPainter extends CustomPainter {
  final double value;
  final double maxValue;
  final Color categoryColor;   
  final Color appPrimaryColor; 
  final Color backgroundColor;

  _SpeedometerPainter({
    required this.value,
    required this.maxValue,
    required this.categoryColor,
    required this.appPrimaryColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Geometry
    // We anchor the center at the bottom-ish of the container
    final center = Offset(size.width / 2, size.height * 0.90); 
    final radius = math.min(size.width / 2, center.dy - 10);
    
    const double degreesToRadians = math.pi / 180.0;
    const totalSweepDeg = 220.0;
    const startAngle = (-90 - (totalSweepDeg / 2)) * degreesToRadians; 
    const sweepAngle = totalSweepDeg * degreesToRadians;   
    
    const double strokeWidth = 20.0;

    // 2. Background Arc
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;
      
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      bgPaint,
    );

    // 3. Category Fill Arc
    final pct = (value / maxValue).clamp(0.0, 1.0);
    final fillAngle = sweepAngle * pct;
    
    final fillPaint = Paint()
      ..color = categoryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;
      
    if (pct > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        fillAngle,
        false,
        fillPaint,
      );
    }

    // 4. Measurement Notches
    final tickPaint = Paint()
      ..style = PaintingStyle.stroke;

    final int totalTicks = 30; 
    final double innerRadius = radius - strokeWidth / 2; 
    
    for (int i = 0; i <= totalTicks; i++) {
      final tickPct = i / totalTicks;
      final tickAngle = startAngle + (sweepAngle * tickPct);
      
      // LOGIC: The loop runs 0 to 30. The exact middle (15) is 12 o'clock.
      final bool isTopCenter = (i == totalTicks ~/ 2);
      final bool isMajor = i % 5 == 0;
      
      // Determine Size based on hierarchy: Top > Major > Minor
      final double tickLength = isTopCenter 
          ? 18.0   // 12 o'clock length
          : (isMajor ? 12.0 : 6.0);
          
      final double tickThickness = isTopCenter 
          ? 3.5    // 12 o'clock thickness
          : (isMajor ? 2.5 : 1.5);
      
      final double tickOffset = 4.0; 

      final p1 = Offset(
        center.dx + (innerRadius - tickOffset) * math.cos(tickAngle),
        center.dy + (innerRadius - tickOffset) * math.sin(tickAngle),
      );
      
      final p2 = Offset(
        center.dx + (innerRadius - tickOffset - tickLength) * math.cos(tickAngle),
        center.dy + (innerRadius - tickOffset - tickLength) * math.sin(tickAngle),
      );
      
      tickPaint.strokeWidth = tickThickness;
      // Make the top one slightly darker/more opaque than standard majors
      tickPaint.color = (isTopCenter || isMajor) 
          ? Colors.grey.withOpacity(0.8) 
          : Colors.grey.withOpacity(0.3);

      canvas.drawLine(p1, p2, tickPaint);
    }

    // 5. Needle
    final needleAngle = startAngle + fillAngle;
    final needleLen = radius + 5; 
    
    final needleTip = Offset(
      center.dx + needleLen * math.cos(needleAngle),
      center.dy + needleLen * math.sin(needleAngle),
    );

    const baseWidth = 8.0;
    final baseAngleLeft = needleAngle - math.pi / 2;
    final baseAngleRight = needleAngle + math.pi / 2;

    final baseLeft = Offset(
      center.dx + baseWidth * math.cos(baseAngleLeft),
      center.dy + baseWidth * math.sin(baseAngleLeft),
    );
    
    final baseRight = Offset(
      center.dx + baseWidth * math.cos(baseAngleRight),
      center.dy + baseWidth * math.sin(baseAngleRight),
    );

    final needlePath = Path()
      ..moveTo(baseLeft.dx, baseLeft.dy)
      ..lineTo(needleTip.dx, needleTip.dy)
      ..lineTo(baseRight.dx, baseRight.dy)
      ..close();

    final needlePaint = Paint()
      ..color = appPrimaryColor
      ..style = PaintingStyle.fill;

    canvas.drawPath(needlePath, needlePaint);
    
    // Center Pivot
    canvas.drawCircle(center, baseWidth, Paint()..color = appPrimaryColor);
  }

  @override
  bool shouldRepaint(covariant _SpeedometerPainter oldDelegate) {
    return oldDelegate.value != value || 
           oldDelegate.categoryColor != categoryColor ||
           oldDelegate.appPrimaryColor != appPrimaryColor;
  }
}