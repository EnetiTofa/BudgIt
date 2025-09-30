import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:budgit/src/features/wallet/domain/wallet_category_data.dart';
import 'package:budgit/src/features/wallet/presentation/widgets/category_ring_painter.dart';
import 'package:budgit/src/features/wallet/presentation/providers/wallet_category_data_provider.dart';

class DailySpendingGauges extends ConsumerWidget {
  const DailySpendingGauges({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletCategoryDataAsync = ref.watch(walletCategoryDataProvider);
    final theme = Theme.of(context);

    return walletCategoryDataAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => const Center(child: Text('Error loading gauges')),
      data: (data) {
        if (data.isEmpty) {
          return const Center(child: Text('Add a category with a wallet to see your daily gauges.'));
        }
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  "Today's Spending",
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 24),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    return _SpendingGauge(data: data[index]);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SpendingGauge extends ConsumerStatefulWidget {
  final WalletCategoryData data;
  const _SpendingGauge({required this.data});

  @override
  ConsumerState<_SpendingGauge> createState() => _SpendingGaugeState();
}

class _SpendingGaugeState extends ConsumerState<_SpendingGauge> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _updateAnimation();
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant _SpendingGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data != oldWidget.data) {
      // It's important to update the animation tween itself with the new end value
      _animation = Tween<double>(begin: _animation.value, end: _calculateProgress())
          .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
      _controller.forward(from: 0.0);
    }
  }

  // Helper method to calculate progress
  double _calculateProgress() {
    final recommendedSpend = widget.data.recommendedDailySpending;
    return recommendedSpend > 0 ? widget.data.spendingToday / recommendedSpend : 0.0;
  }

  void _updateAnimation() {
    _animation = Tween<double>(begin: 0.0, end: _calculateProgress())
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.compactCurrency(locale: 'en_US', symbol: '\$');
    final recommendedSpend = widget.data.recommendedDailySpending;

    
    return Column(
      children: [
        Expanded(
          child: AspectRatio(
            aspectRatio: 1.0,
            child: SizedBox(
              width: 120, height: 120,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return CustomPaint(
                    painter: CategoryRingPainter(
                      progressRatio: _animation.value,
                      categoryColor: widget.data.category.color,
                      strokeWidth: 9.0,
                      backgroundColor: Theme.of(context).colorScheme.surfaceDim
                    ),
                    child: child,
                  );
                },
                child: Center(
                  child: Icon(widget.data.category.icon, color: widget.data.category.color, size: 36),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.data.category.name,
          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          '${currencyFormat.format(widget.data.spendingToday)} / ${currencyFormat.format(recommendedSpend)}',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}