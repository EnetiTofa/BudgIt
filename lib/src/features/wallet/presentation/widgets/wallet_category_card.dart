import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:budgit/src/features/wallet/domain/wallet_category_data.dart';
import 'package:budgit/src/features/wallet/presentation/widgets/wallet_speedometer.dart';
import 'package:budgit/src/features/wallet/presentation/screens/wallet_category_detail_screen.dart';

class WalletCategoryCard extends ConsumerStatefulWidget {
  final WalletCategoryData data;
  
  const WalletCategoryCard({
    super.key,
    required this.data,
  });

  @override
  ConsumerState<WalletCategoryCard> createState() => _WalletCategoryCardState();
}

class _WalletCategoryCardState extends ConsumerState<WalletCategoryCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _animation = Tween<double>(begin: 0.0, end: widget.data.weeklyProgress)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant WalletCategoryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data.weeklyProgress != oldWidget.data.weeklyProgress) {
      _animation = Tween<double>(begin: oldWidget.data.weeklyProgress, end: widget.data.weeklyProgress)
          .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
      _controller..value = 0.0..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: '\$');
    final theme = Theme.of(context);
    final data = widget.data;
    final isOverspent = data.totalSpentThisWeek > data.effectiveWeeklyBudget;
    
    // This logic automatically chooses black or white for readability
    final brightness = ThemeData.estimateBrightnessForColor(data.category.color);
    final contentColor = brightness == Brightness.dark ? Colors.white : Color(0xFF121212).withAlpha(200);

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      color: data.category.color, // Use category color for the background
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => WalletCategoryDetailScreen(category: data.category),
          ));
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            children: [
              // --- Header Row ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(data.category.icon, color: contentColor, size: 26),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      data.category.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: contentColor,
                        fontSize: 20,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  RichText(
                    text: TextSpan(
                      style: theme.textTheme.bodyMedium?.copyWith(color: contentColor.withOpacity(0.8)),
                      children: <TextSpan>[
                        TextSpan(
                          text: currencyFormat.format(data.totalSpentThisWeek),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isOverspent ? Colors.yellow.shade200 : contentColor,
                          ),
                        ),
                        TextSpan(
                          text: ' / ${currencyFormat.format(data.effectiveWeeklyBudget)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                          )
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // --- Animated Progress Bar ---
              SizedBox(
                height: 12,
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: _animation.value,
                        backgroundColor: theme.colorScheme.surface.withOpacity(0.7),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isOverspent ? Colors.yellow.shade200 : data.category.color.withOpacity(0.7)
                        ),
                      ),
                    );
                  },
                ),
              ),
              Divider(height: 24, color: contentColor.withOpacity(0.5)),

              // --- "Personal Trainer" Info Row ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  WalletSpeedometer(
                    targetAverage: data.targetDailyAverage,
                    currentAverage: data.averageDailySpending,
                    color: contentColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Rec. spend: ${currencyFormat.format(data.recommendedDailySpending)} / day',
                       style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: contentColor,
                       ),
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 16, color: contentColor.withOpacity(0.8)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}