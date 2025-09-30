// lib/src/features/budgets/presentation/widgets/historical_category_chart.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

// Placeholder data models (unchanged)
class MonthlySpendingBreakdown {
  final DateTime date;
  final double recurring;
  final double wallet;
  final double oneOff;
  double get total => recurring + wallet + oneOff;
  MonthlySpendingBreakdown(this.date, this.recurring, this.wallet, this.oneOff);
}

class HistoricalCategoryChart extends StatefulWidget {
  const HistoricalCategoryChart({
    super.key,
    required this.data,
    required this.selectedMonth,
    required this.onMonthSelected,
    required this.colorPalette,
  });

  final List<MonthlySpendingBreakdown> data;
  final DateTime selectedMonth;
  final ValueChanged<DateTime> onMonthSelected;
  final List<Color> colorPalette;

  @override
  State<HistoricalCategoryChart> createState() =>
      _HistoricalCategoryChartState();
}

class _HistoricalCategoryChartState extends State<HistoricalCategoryChart> {
  late final ScrollController _scrollController;
  static const double _itemWidth = 65.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    // Scroll to the end when the widget is first built.
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());
  }

  @override
  void didUpdateWidget(covariant HistoricalCategoryChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the data changes, scroll to the end again.
    if (widget.data.length != oldWidget.data.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());
    }
  }

  void _scrollToEnd() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _handleTap(Offset localPosition) {
    final int tappedIndex =
        ((localPosition.dx + _scrollController.offset) / _itemWidth).floor();

    if (tappedIndex >= 0 && tappedIndex < widget.data.length) {
      widget.onMonthSelected(widget.data[tappedIndex].date);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return SizedBox(
        height: 160,
        child: Center(
          child: Text(
            'No spending data for this category yet.',
            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: SizedBox(
        height: 160,
        child: GestureDetector(
          onTapDown: (details) => _handleTap(details.localPosition),
          child: SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            child: Container(
              width: _itemWidth * widget.data.length,
              color: Theme.of(context).colorScheme.surface,
              child: CustomPaint(
                painter: ChartPainter(
                  spendingData: widget.data,
                  selectedMonth: widget.selectedMonth,
                  colorPalette: widget.colorPalette,
                  itemWidth: _itemWidth,
                  textTheme: Theme.of(context).textTheme,
                  primaryColor: Theme.of(context).colorScheme.primary,
                  secondaryColor: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ChartPainter class remains unchanged
class ChartPainter extends CustomPainter {
  const ChartPainter({
    required this.spendingData,
    required this.selectedMonth,
    required this.colorPalette,
    required this.itemWidth,
    required this.textTheme,
    required this.primaryColor,
    required this.secondaryColor,
  });

  final List<MonthlySpendingBreakdown> spendingData;
  final DateTime selectedMonth;
  final List<Color> colorPalette;
  final double itemWidth;
  final TextTheme textTheme;
  final Color primaryColor;
  final Color secondaryColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (spendingData.isEmpty) return;

    const double barWidth = 22.0;
    const double topPadding = 16.0;
    const double bottomPadding = 30.0;
    final double chartHeight = size.height - topPadding - bottomPadding;
    
    final maxAmount = spendingData.map((d) => d.total).reduce((a, b) => a > b ? a : b);
    final effectiveMaxAmount = maxAmount > 0 ? maxAmount : 1.0;

    for (int i = 0; i < spendingData.length; i++) {
      final item = spendingData[i];
      final bool isSelected = item.date.year == selectedMonth.year && item.date.month == selectedMonth.month;
      
      final barX = (itemWidth * i) + (itemWidth - barWidth) / 2;
      double currentY = size.height - bottomPadding;

      final segments = [item.oneOff, item.wallet, item.recurring];
      for (int j = 0; j < segments.length; j++) {
        final segmentHeight = (segments[j] / effectiveMaxAmount) * chartHeight;
        final segmentPaint = Paint()..color = isSelected ? colorPalette[j] : colorPalette[j].withOpacity(0.5);
        
        final rect = Rect.fromLTWH(barX, currentY - segmentHeight, barWidth, segmentHeight);
        canvas.drawRect(rect, segmentPaint);
        currentY -= segmentHeight;
      }
      
      final textStyle = textTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: isSelected ? primaryColor : secondaryColor,
      );
      final textSpan = TextSpan(text: DateFormat.MMM().format(item.date), style: textStyle);
      final textPainter = TextPainter(text: textSpan, textAlign: TextAlign.center, textDirection: TextDirection.ltr);
      textPainter.layout();
      final textOffset = Offset((itemWidth * i) + (itemWidth / 2) - (textPainter.width / 2), size.height - 15);
      textPainter.paint(canvas, textOffset);
    }
  }

  @override
  bool shouldRepaint(covariant ChartPainter oldDelegate) {
    return oldDelegate.spendingData != spendingData || oldDelegate.selectedMonth != selectedMonth;
  }
}