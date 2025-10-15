import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/features/categories/domain/category.dart';
import 'package:budgit/src/features/wallet/domain/wallet_category_data.dart';
import 'package:budgit/src/features/wallet/presentation/providers/wallet_category_data_provider.dart';
import 'package:budgit/src/features/wallet/presentation/widgets/category/animated_wallet_gauge.dart';
import 'package:budgit/src/features/wallet/presentation/controllers/boost_controller.dart';
import 'package:budgit/src/features/wallet/presentation/widgets/category/category_display_widget.dart';
import 'package:budgit/src/features/wallet/presentation/widgets/category/expanded_mode.dart';
import 'package:budgit/src/features/categories/presentation/screens/edit_basic_category_screen.dart';

class WalletCategoryDetailScreen extends ConsumerStatefulWidget {
  final Category category;
  const WalletCategoryDetailScreen({super.key, required this.category});

  @override
  ConsumerState<WalletCategoryDetailScreen> createState() =>
      _WalletCategoryDetailScreenState();
}

class _WalletCategoryDetailScreenState
    extends ConsumerState<WalletCategoryDetailScreen> {
  ExpandedMode _expandedMode = ExpandedMode.none;

  @override
  Widget build(BuildContext context) {
    final allWalletDataAsync = ref.watch(walletCategoryDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.category.name} Wallet'),
      ),
      body: PopScope(
        canPop: _expandedMode == ExpandedMode.none,
        onPopInvoked: (didPop) {
          if (didPop) return;
          if (_expandedMode != ExpandedMode.none) {
            // Also invalidate the provider if the user uses the back button to collapse
            ref.invalidate(boostStateProvider(widget.category));
            setState(() {
              _expandedMode = ExpandedMode.none;
            });
          }
        },
        child: switch (allWalletDataAsync) {
          AsyncLoading() => const Center(child: CircularProgressIndicator()),
          AsyncError(:final error) => Center(child: Text('Error: $error')),
          AsyncData(:final value) => _buildContent(context, value),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, List<WalletCategoryData> allData) {
    try {
      final data =
          allData.firstWhere((d) => d.category.id == widget.category.id);
      final total = data.effectiveWeeklyBudget;
      final spent = data.spentInCompletedDays + data.spendingToday;
      final remaining = total - spent;

      final brightness = ThemeData.estimateBrightnessForColor(widget.category.color);
      final contentColor = brightness == Brightness.dark ? Colors.white : Color(0xFF121212).withAlpha(200);

      final boostStateAsync = ref.watch(boostStateProvider(widget.category));
      final totalBoostAmount = boostStateAsync.maybeWhen(
        data: (boostMap) =>
            boostMap.currentBoosts.values.fold(0.0, (sum, amount) => sum + amount),
        orElse: () => 0.0,
      );

      return Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 80.0),
                child: AnimatedWalletGauge(
                  remainingAmount: remaining,
                  totalAmount: total,
                  categoryColor: data.category.color,
                  isBoostMode: _expandedMode == ExpandedMode.boost,
                  boostAmount: totalBoostAmount,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: CategoryDisplayWidget(
                  category: data.category,
                  expandedMode: _expandedMode,
                  toCategory: data.category,
                  onDaysPressed: () =>
                      setState(() => _expandedMode = ExpandedMode.days),
                  onBoostPressed: () =>
                      setState(() => _expandedMode = ExpandedMode.boost),
                  onStatsPressed: () =>
                      setState(() => _expandedMode = ExpandedMode.stats),
                  // --- CHANGE: Invalidate provider on collapse ---
                  onCollapse: () {
                    // This line explicitly clears the provider's temporary state.
                    ref.invalidate(boostStateProvider(data.category));
                    setState(() => _expandedMode = ExpandedMode.none);
                  },
                  cornerRadius: 16.0,
                  rectangleHorizontalPadding: 16.0,
                  pentagonHorizontalPadding: 36.0,
                  recommendedSpending: data.recommendedDailySpending,
                  actionCardColor:
                      Theme.of(context).colorScheme.surfaceContainerLowest,
                  daysRemaining: data.daysRemaining,
                ),
              ),
            ],
          ),
          Positioned(
            top: 8,
            left: 28,
            child: AnimatedOpacity(
              opacity: _expandedMode != ExpandedMode.none ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: CornerActionButton(
                icon: data.category.icon,
                tooltip: 'Category Page',
                onPressed: () {
                },
                backgroundColor: data.category.color,
                iconColor: contentColor,
                iconSize: 28,
                size: 48,
              ),
            ),
          ),
          Positioned(
            top: 6,
            right: 28,
            child: AnimatedOpacity(
              opacity: _expandedMode != ExpandedMode.none ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: CornerActionButton(
                icon: Icons.edit_outlined,
                tooltip: 'Edit Category',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          EditBasicCategoryScreen(category: widget.category),
                    ),
                  );
                },
                backgroundColor: Theme.of(context).colorScheme.surface,
                iconColor: Theme.of(context).colorScheme.secondary,
                size: 36,
                iconSize: 28,
              ),
            ),
          ),
        ],
      );
    } catch (e) {
      return const Center(
        child: Text('This category does not have a wallet enabled.'),
      );
    }
  }
}

// CornerActionButton class remains the same...
class CornerActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;
  final Color? backgroundColor;
  final Color? iconColor;
  final double? iconSize;
  final double? size;

  const CornerActionButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.backgroundColor,
    this.iconColor,
    this.iconSize,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size ?? 48.0,
      height: size ?? 48.0,
      child: Material(
        color: backgroundColor ??
            Theme.of(context).colorScheme.surface.withOpacity(0.8),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        child: Tooltip(
          message: tooltip,
          child: IconButton(
            iconSize: iconSize,
            icon: Icon(icon),
            onPressed: onPressed,
            color: iconColor ?? Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}