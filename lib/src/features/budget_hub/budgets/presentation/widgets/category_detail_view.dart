// lib/src/features/budgets/presentation/widgets/category_detail_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import 'package:budgit/src/core/domain/models/category.dart';
import 'package:budgit/src/core/data/providers/category_list_provider.dart';
// This import now includes our new provider
import 'package:budgit/src/features/budget_hub/budgets/presentation/providers/historical_category_spending_provider.dart';
import 'package:budgit/src/utils/palette_generator.dart';
import 'package:budgit/src/features/budget_hub/budgets/presentation/screens/budgets_screen.dart';
import 'package:budgit/src/features/transaction_hub/transactions/presentation/providers/next_recurring_payment_provider.dart';
// Add this import for the UI card
import 'package:budgit/src/common_widgets/summary_stat_card.dart';

class CategoryDetailView extends ConsumerStatefulWidget {
  const CategoryDetailView({
    super.key,
    required this.categoryId,
    required this.selectedMonth,
  });

  final String categoryId;
  final DateTime selectedMonth;

  @override
  ConsumerState<CategoryDetailView> createState() => _CategoryDetailViewState();
}

class _CategoryDetailViewState extends ConsumerState<CategoryDetailView> {
  late final ScrollController _chartScrollController;
  static const double _itemWidth = 65.0;
  bool _hasScrolledToEnd = false;

  @override
  void initState() {
    super.initState();
    _chartScrollController = ScrollController();
  }

  @override
  void dispose() {
    _chartScrollController.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    if (_chartScrollController.hasClients) {
      _chartScrollController.jumpTo(_chartScrollController.position.maxScrollExtent);
    }
  }

  void _handleChartTap(Offset localPosition, List<MonthlySpendingBreakdown> data) {
    final int tappedIndex =
        ((localPosition.dx + _chartScrollController.offset) / _itemWidth).floor();

    if (tappedIndex >= 0 && tappedIndex < data.length) {
      ref.read(selectedMonthProvider.notifier).state = data[tappedIndex].date;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryListAsync = ref.watch(categoryListProvider);

    return categoryListAsync.when(
      data: (categories) {
        final category = categories.firstWhere(
          (cat) => cat.id == widget.categoryId,
          orElse: () => Category(id: '', name: '', iconCodePoint: 0, colorValue: 0, budgetAmount: 0),
        );

        if (category.id.isEmpty) {
          return const SizedBox.shrink(); 
        }

        // --- FETCH DATA ---
        // 1. Full history for the chart
        final historicalData = ref.watch(historicalCategorySpendingProvider(
          categoryId: category.id,
        ));
        
        // 2. Specific breakdown for the summary card (Using our NEW provider)
        final breakdown = ref.watch(categoryMonthlyBreakdownProvider(
          categoryId: category.id,
          month: widget.selectedMonth,
        ));

        final nextPayment = ref.watch(nextRecurringPaymentProvider(categoryId: category.id));
        // ---------------------------------

        final palette = generateSpendingPalette(category.color);
        final colorScheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 8),
              
              // 1. Upcoming Transactions Card
              _DetailCard(
                child: InkWell(
                  borderRadius: BorderRadius.circular(16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Upcoming Transactions',
                          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Builder(
                          builder: (context) {
                            if (nextPayment == null) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Text(
                                    'No upcoming recurring payments.',
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurfaceVariant
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            }
                            return Row(
                              children: [
                                if (nextPayment.iconCodePoint != null)
                                  Icon(
                                    IconData(
                                      nextPayment.iconCodePoint!,
                                      fontFamily: nextPayment.iconFontFamily,
                                      fontPackage: 'material_design_icons_flutter',
                                    ), 
                                    size: 32, 
                                    color: colorScheme.secondary
                                  )
                                else
                                  Icon(
                                    Icons.refresh_rounded, 
                                    size: 32, 
                                    color: colorScheme.secondary
                                  ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        nextPayment.itemName, 
                                        style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)
                                      ),
                                      Text(
                                        DateFormat.yMMMd().format(nextPayment.date), 
                                        style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '-\$${nextPayment.amount.toStringAsFixed(2)}',
                                  style: textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.bold, 
                                    color: colorScheme.onSurface
                                  ),
                                )
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 3. History Card
              _DetailCard(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'History',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 140, 
                        child: Builder(
                          builder: (context) {
                            if (historicalData.isEmpty) {
                              return Center(
                                child: Text(
                                  'No spending data yet.',
                                  style: TextStyle(color: colorScheme.secondary),
                                ),
                              );
                            }

                            if (!_hasScrolledToEnd) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _scrollToEnd();
                                if (mounted) setState(() => _hasScrolledToEnd = true);
                              });
                            }

                            return LayoutBuilder(
                              builder: (context, constraints) {
                                return GestureDetector(
                                  onTapDown: (details) => _handleChartTap(details.localPosition, historicalData),
                                  child: SingleChildScrollView(
                                    controller: _chartScrollController,
                                    scrollDirection: Axis.horizontal,
                                    child: Container(
                                      width: _itemWidth * historicalData.length,
                                      height: constraints.maxHeight,
                                      color: Colors.transparent,
                                      child: CustomPaint(
                                        painter: ChartPainter(
                                          spendingData: historicalData,
                                          selectedMonth: widget.selectedMonth,
                                          recurringColor: palette.historicalChartList.isNotEmpty 
                                              ? palette.historicalChartList[2] 
                                              : colorScheme.primary,
                                          oneOffColor: palette.historicalChartList.length > 1 
                                              ? palette.historicalChartList[1] 
                                              : colorScheme.secondary,
                                          walletColor: palette.historicalChartList.length > 2 
                                              ? palette.historicalChartList[0] 
                                              : colorScheme.tertiary,
                                          itemWidth: _itemWidth,
                                          textTheme: textTheme,
                                          primaryColor: colorScheme.primary,
                                          secondaryColor: colorScheme.secondary,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // 2. New Summary Card
              SummaryStatCard(
                stats: [
                  SummaryStat(
                    value: '\$${breakdown.recurring.toStringAsFixed(2)}',
                    unit: 'Recurring',
                    title: 'Recurring',
                    description: 'Spent on fixed subscriptions.',
                  ),
                  SummaryStat(
                    value: '\$${breakdown.oneOff.toStringAsFixed(2)}',
                    unit: 'One-off',
                    title: 'One-Off',
                    description: 'Spent on single purchases.',
                  ),
                  SummaryStat(
                    value: '\$${breakdown.wallet.toStringAsFixed(2)}',
                    unit: 'Wallet',
                    title: 'Wallet',
                    description: 'Spent using physical wallet/cash.',
                  ),
                  // --- NEW STATS ---
                  SummaryStat(
                    value: '\$${breakdown.dailyAverage.toStringAsFixed(2)}',
                    unit: '/ day',
                    title: 'Daily Average',
                    description: 'Average spending per day this month.',
                  ),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final Widget child;

  const _DetailCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: child,
    );
  }
}

class ChartPainter extends CustomPainter {
  const ChartPainter({
    required this.spendingData,
    required this.selectedMonth,
    required this.recurringColor,
    required this.oneOffColor,
    required this.walletColor,
    required this.itemWidth,
    required this.textTheme,
    required this.primaryColor,
    required this.secondaryColor,
  });

  final List<MonthlySpendingBreakdown> spendingData;
  final DateTime selectedMonth;
  final Color recurringColor;
  final Color oneOffColor;
  final Color walletColor;
  final double itemWidth;
  final TextTheme textTheme;
  final Color primaryColor;
  final Color secondaryColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (spendingData.isEmpty) return;

    const double barWidth = 22.0;
    const double bottomPadding = 20.0;
    final double chartHeight = size.height - bottomPadding;
    
    final maxAmount = spendingData.map((d) => d.total).reduce((a, b) => a > b ? a : b);
    final effectiveMaxAmount = maxAmount > 0 ? maxAmount : 1.0;

    for (int i = 0; i < spendingData.length; i++) {
      final item = spendingData[i];
      final bool isSelected = item.date.year == selectedMonth.year && item.date.month == selectedMonth.month;
      
      final barX = (itemWidth * i) + (itemWidth - barWidth) / 2;
      double currentY = size.height - bottomPadding;

      final segments = [
        _ChartSegment(value: item.recurring, color: recurringColor),
        _ChartSegment(value: item.oneOff, color: oneOffColor),
        _ChartSegment(value: item.wallet, color: walletColor),
      ];

      for (final segment in segments) {
        if (segment.value <= 0) continue;
        
        final segmentHeight = (segment.value / effectiveMaxAmount) * chartHeight;
        final segmentPaint = Paint()
          ..color = isSelected ? segment.color : segment.color.withOpacity(0.5);
          
        final rect = Rect.fromLTWH(barX, currentY - segmentHeight, barWidth, segmentHeight);
        canvas.drawRect(rect, segmentPaint);
        currentY -= segmentHeight;
      }
      
      final textStyle = textTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: isSelected ? primaryColor : secondaryColor,
        fontSize: 11,
      );
      final textSpan = TextSpan(text: DateFormat.MMM().format(item.date), style: textStyle);
      final textPainter = TextPainter(text: textSpan, textAlign: TextAlign.center, textDirection: ui.TextDirection.ltr);
      textPainter.layout();
      final textOffset = Offset((itemWidth * i) + (itemWidth / 2) - (textPainter.width / 2), size.height - 14);
      textPainter.paint(canvas, textOffset);
    }
  }

  @override
  bool shouldRepaint(covariant ChartPainter oldDelegate) {
    return oldDelegate.spendingData != spendingData || 
           oldDelegate.selectedMonth != selectedMonth ||
           oldDelegate.recurringColor != recurringColor;
  }
}

class _ChartSegment {
  final double value;
  final Color color;

  _ChartSegment({required this.value, required this.color});
}