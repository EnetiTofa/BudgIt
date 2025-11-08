import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:budgit/src/common_widgets/custom_toggle.dart';
import 'package:budgit/src/features/budget_hub/wallet/domain/wallet_category_data.dart';
import 'package:budgit/src/features/budget_hub/wallet/presentation/providers/wallet_category_data_provider.dart';
import 'package:budgit/src/features/budget_hub/wallet/presentation/widgets/wallet_speedometer.dart';

class AverageSpendingSpeedometers extends ConsumerStatefulWidget {
  const AverageSpendingSpeedometers({super.key});

  @override
  ConsumerState<AverageSpendingSpeedometers> createState() => _AverageSpendingSpeedometersState();
}

class _AverageSpendingSpeedometersState extends ConsumerState<AverageSpendingSpeedometers> {
  String _selectedMode = 'Average';

  @override
  Widget build(BuildContext context) {
    final walletCategoryDataAsync = ref.watch(walletCategoryDataProvider);
    final theme = Theme.of(context);

    return walletCategoryDataAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => const Center(child: Text('Error loading data')),
      data: (data) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          // Use a SingleChildScrollView to prevent overflow issues
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  "$_selectedMode Daily Spending",
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 36), // V-- Reduced from 16 to 8
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 2, // V-- Reduced from 12 to 8
                    childAspectRatio: 1,
                  ),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    return _SpeedometerGauge(data: data[index], mode: _selectedMode);
                  },
                ),
                const SizedBox(height: 16),
                CustomToggle(
                  options: const ['Average', 'Recommended'],
                  selectedValue: _selectedMode,
                  onChanged: (value) {
                    setState(() {
                      _selectedMode = value;
                    });
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

class _SpeedometerGauge extends ConsumerStatefulWidget {
  final WalletCategoryData data;
  final String mode;
  const _SpeedometerGauge({required this.data, required this.mode});

  @override
  ConsumerState<_SpeedometerGauge> createState() => _SpeedometerGaugeState();
}

class _SpeedometerGaugeState extends ConsumerState<_SpeedometerGauge> with SingleTickerProviderStateMixin {
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
  void didUpdateWidget(covariant _SpeedometerGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data != oldWidget.data || widget.mode != oldWidget.mode) {
      // Get the previous value for the animation's "begin"
      final oldDisplayValue = oldWidget.mode == 'Average'
          ? oldWidget.data.averageDailySpending
          : oldWidget.data.recommendedDailySpending;

      // Get the new value for the animation's "end"
      final newDisplayValue = widget.mode == 'Average'
          ? widget.data.averageDailySpending
          : widget.data.recommendedDailySpending;
      
      _animation = Tween<double>(begin: oldDisplayValue, end: newDisplayValue)
          .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
      
      _controller.forward(from: 0.0);
    }
  }

  void _updateAnimation() {
    final displayValue = widget.mode == 'Average'
        ? widget.data.averageDailySpending
        : widget.data.recommendedDailySpending;
    
    _animation = Tween<double>(begin: 0.0, end: displayValue)
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
    
    return Column(
      children: [
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return WalletSpeedometer(
              targetAverage: widget.data.targetDailyAverage,
              currentAverage: _animation.value,
              color: widget.data.category.color,
              size: SpeedometerSize.large,
            );
          },
        ),
        const SizedBox(height: 8),
        Text(
          widget.data.category.name,
          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          '${currencyFormat.format(widget.mode == 'Average' ? widget.data.averageDailySpending : widget.data.recommendedDailySpending)} / day',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}