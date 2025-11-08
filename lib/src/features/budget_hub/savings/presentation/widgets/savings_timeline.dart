// lib/src/features/savings/presentation/widgets/savings_timeline.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:budgit/src/features/budget_hub/savings/presentation/savings_providers.dart'; // Changed import

class SavingsTimeline extends StatefulWidget {
  const SavingsTimeline({
    super.key,
    required this.savingsData, // Renamed from spendingData
    required this.selectedMonth,
    required this.onMonthSelected,
  });

  final List<MonthlySavings> savingsData; // Changed type
  final DateTime selectedMonth;
  final ValueChanged<DateTime> onMonthSelected;

  @override
  State<SavingsTimeline> createState() => _SavingsTimelineState();
}

class _SavingsTimelineState extends State<SavingsTimeline> {
  final ScrollController _scrollController = ScrollController();
  bool _isInitialScrollComplete = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        if (mounted) {
          setState(() {
            _isInitialScrollComplete = true;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isInitialScrollComplete = true;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _handleTap(Offset localPosition) {
    const double itemWidth = 80.0;
    final double scrollOffset = _scrollController.offset;
    final int tappedIndex = ((localPosition.dx + scrollOffset) / itemWidth).floor();

    if (tappedIndex >= 0 && tappedIndex < widget.savingsData.length) {
      widget.onMonthSelected(widget.savingsData[tappedIndex].date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<MonthlySavings> sortedData = List.from(widget.savingsData)
      ..sort((a, b) => a.date.compareTo(b.date));

    return AnimatedOpacity(
      opacity: _isInitialScrollComplete ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 150),
      child: GestureDetector(
        onTapDown: (details) => _handleTap(details.localPosition),
        child: SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          child: Container(
            height: 180,
            width: 80.0 * sortedData.length,
            color: Theme.of(context).colorScheme.surface,
            child: CustomPaint(
              painter: SavingsTimelinePainter( // Renamed painter
                savingsData: sortedData,
                selectedMonth: widget.selectedMonth,
                primaryColor: Theme.of(context).colorScheme.primary,
                secondaryColor: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SavingsTimelinePainter extends CustomPainter {
  SavingsTimelinePainter({
    required this.savingsData, // Renamed
    required this.selectedMonth,
    required this.primaryColor,
    required this.secondaryColor,
  });

  final List<MonthlySavings> savingsData; // Changed type
  final DateTime selectedMonth;
  final Color primaryColor;
  final Color secondaryColor;

  // Method _calculateGradients remains the same
  List<double> _calculateGradients(List<Offset> points) {
    if (points.length <= 1) return List.filled(points.length, 0.0);
    List<double> gradients = [];
    gradients.add((points[1].dy - points[0].dy) / (points[1].dx - points[0].dx));
    for (int i = 1; i < points.length - 1; i++) {
      final slope1 = (points[i].dy - points[i - 1].dy) / (points[i].dx - points[i - 1].dx);
      final slope2 = (points[i + 1].dy - points[i].dy) / (points[i + 1].dx - points[i].dx);
      gradients.add((slope1 + slope2) / 2);
    }
    final lastIndex = points.length - 1;
    gradients.add((points[lastIndex].dy - points[lastIndex - 1].dy) / (points[lastIndex].dx - points[lastIndex - 1].dx));
    return gradients;
  }

  // Method _createSmoothedPath remains the same
  Path _createSmoothedPath(List<Offset> points) {
    final path = Path();
    if (points.isEmpty) return path;
    path.moveTo(points.first.dx, points.first.dy);
    if (points.length == 1) return path;
    final gradients = _calculateGradients(points);
    const double tension = 0.3;
    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final dx = p1.dx - p0.dx;
      final controlPoint1 = Offset(p0.dx + dx * tension, p0.dy + dx * tension * gradients[i]);
      final controlPoint2 = Offset(p1.dx - dx * tension, p1.dy - dx * tension * gradients[i + 1]);
      path.cubicTo(controlPoint1.dx, controlPoint1.dy, controlPoint2.dx, controlPoint2.dy, p1.dx, p1.dy);
    }
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (savingsData.isEmpty) return;

    const double itemWidth = 80.0;
    const double topPadding = 40.0;
    const double bottomPadding = 40.0;
    final double chartHeight = size.height - topPadding - bottomPadding;

    // Handle positive and negative savings for correct scaling
    double maxAmount = 0;
    double minAmount = 0;
    for (final item in savingsData) {
      if (item.amount > maxAmount) maxAmount = item.amount;
      if (item.amount < minAmount) minAmount = item.amount;
    }
    final double range = (maxAmount - minAmount).abs() < 1 ? 1.0 : (maxAmount - minAmount);

    final linePaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final trendPaint = Paint()
      // --- MODIFICATION START ---
      ..color = Colors.greenAccent.withOpacity(0.8) // Changed trend line color
      // --- MODIFICATION END ---
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
      
    // ... rest of paint method is the same, just using savingsData ...
    final dotPaint = Paint()..color = primaryColor;
    final selectedDotPaint = Paint()..color = primaryColor..style = PaintingStyle.stroke..strokeWidth = 2.0;
    final linePath = Path();
    final List<Offset> points = [];
    final List<Offset> trendPoints = [];
    final List<double> movingAverage = _calculateMovingAverage(savingsData);
    for (int i = 0; i < savingsData.length; i++) {
      final item = savingsData[i];
      final x = itemWidth * i + (itemWidth / 2);
      final y = topPadding + chartHeight - ((item.amount - minAmount) / range * chartHeight);
      points.add(Offset(x, y));
      final trendY = topPadding + chartHeight - ((movingAverage[i] - minAmount) / range * chartHeight);
      trendPoints.add(Offset(x, trendY));
    }
    for (int i = 0; i < points.length; i++) {
      if (i == 0) { linePath.moveTo(points[i].dx, points[i].dy); } 
      else { linePath.lineTo(points[i].dx, points[i].dy); }
    }
    final trendPath = _createSmoothedPath(trendPoints);
    canvas.drawPath(trendPath, trendPaint);
    canvas.drawPath(linePath, linePaint);
    for (int i = 0; i < points.length; i++) {
      final point = points[i];
      final item = savingsData[i];
      final bool isSelected = item.date.year == selectedMonth.year && item.date.month == selectedMonth.month;
      double verticalOffset = -20.0;
      final currentAmount = item.amount;
      if (savingsData.length > 1) {
        if (i == 0) {
          if (currentAmount < savingsData[i + 1].amount) verticalOffset = 20.0;
        } else if (i == savingsData.length - 1) {
          if (currentAmount < savingsData[i - 1].amount) verticalOffset = 20.0;
        } else {
          final prevAmount = savingsData[i - 1].amount;
          final nextAmount = savingsData[i + 1].amount;
          if (currentAmount > prevAmount && currentAmount > nextAmount) {
            verticalOffset = -20.0;
          } else if (currentAmount < prevAmount && currentAmount < nextAmount) {
            verticalOffset = 20.0;
          }
        }
      }
      canvas.drawCircle(point, 6.0, dotPaint);
      if (isSelected) { canvas.drawCircle(point, 10.0, selectedDotPaint); }
      _drawText(canvas, '\$${item.amount.toStringAsFixed(0)}', point + Offset(0, verticalOffset), isSelected: isSelected);
      _drawText(canvas, DateFormat.MMM().format(item.date), Offset(point.dx, size.height - 15), isSelected: isSelected);
    }
  }

  // Method _calculateMovingAverage remains the same but takes List<MonthlySavings>
  List<double> _calculateMovingAverage(List<MonthlySavings> data) {
    if (data.isEmpty) return [];
    final amounts = data.map((d) => d.amount).toList();
    if (amounts.length == 1) return amounts;
    List<double> smoothedValues = [];
    smoothedValues.add(amounts[0]);
    for (int i = 1; i < amounts.length - 1; i++) {
      final double weightedAverage = ((amounts[i - 1] * 2) + (amounts[i] * 4) + amounts[i + 1]) / 7.0;
      smoothedValues.add(weightedAverage);
    }
    final double lastAverage = (amounts[amounts.length - 2] + amounts[amounts.length - 1]) / 2.0;
    smoothedValues.add(lastAverage);
    return smoothedValues;
  }
  
  // Method _drawText remains the same
  void _drawText(Canvas canvas, String text, Offset position, {bool isSelected = false}) {
    final textStyle = TextStyle(color: isSelected ? primaryColor : secondaryColor, fontSize: 12, fontWeight: FontWeight.w600);
    final textSpan = TextSpan(text: text, style: textStyle);
    final textPainter = TextPainter(text: textSpan, textAlign: TextAlign.center, textDirection: TextDirection.ltr);
    textPainter.layout();
    final offset = Offset(position.dx - (textPainter.width / 2), position.dy - (textPainter.height / 2));
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant SavingsTimelinePainter oldDelegate) {
    return oldDelegate.savingsData != savingsData || oldDelegate.selectedMonth != selectedMonth;
  }
}