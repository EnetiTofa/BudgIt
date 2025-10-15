import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgit/src/features/categories/domain/category.dart';
import 'package:budgit/src/features/wallet/presentation/controllers/boost_controller.dart';
import 'package:budgit/src/features/wallet/presentation/widgets/category/boost_slider_card.dart';
import 'package:budgit/src/features/wallet/presentation/providers/wallet_category_data_provider.dart';
import 'package:budgit/src/features/wallet/presentation/widgets/category/expanded_mode.dart';


class CategoryDisplayWidget extends StatelessWidget {
  final Color categoryColor;
  final int daysRemaining;
  final double recommendedSpending;
  final Category toCategory;
  final double rectangleHorizontalPadding;
  final double pentagonHorizontalPadding;
  final double cornerRadius;
  final double rectangleHeightRatio;
  final Color? actionCardColor;
  final ExpandedMode expandedMode;
  final VoidCallback onDaysPressed;
  final VoidCallback onBoostPressed;
  final VoidCallback onStatsPressed;
  final VoidCallback onCollapse;

  const CategoryDisplayWidget({
    super.key,
    required this.categoryColor,
    required this.daysRemaining,
    required this.recommendedSpending,
    required this.toCategory,
    this.rectangleHorizontalPadding = 16.0,
    this.pentagonHorizontalPadding = 32.0,
    this.cornerRadius = 48.0,
    this.rectangleHeightRatio = 0.7,
    this.actionCardColor,
    required this.expandedMode,
    required this.onDaysPressed,
    required this.onBoostPressed,
    required this.onStatsPressed,
    required this.onCollapse,
  });

  Widget _buildExpandedContent(BuildContext context, WidgetRef ref) {
    Widget content;
    String title;

    switch (expandedMode) {
      case ExpandedMode.boost:
        title = 'Boost ${toCategory.name} Wallet';
        content = _BoostContent(toCategory: toCategory, onCollapse: onCollapse);
        break;
      case ExpandedMode.days:
        title = 'Days Remaining';
        content = const Center(child: Text('Days Details UI will go here.'));
        break;
      case ExpandedMode.stats:
        title = 'Statistics';
        content = const Center(child: Text('Stats UI will go here.'));
        break;
      case ExpandedMode.none:
        title = '';
        content = const SizedBox.shrink();
        break;
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Column(
        key: ValueKey(expandedMode),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(Icons.keyboard_arrow_down),
                    iconSize: 32,
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      onCollapse();
                    },
                    tooltip: 'Collapse',
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: content),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const double verticalPadding = 16.0;
    const double pentagonHeight = 210;
    final cardColor =
        actionCardColor ?? Theme.of(context).colorScheme.surfaceContainer;
    final double rectangleTopY =
        (pentagonHeight - verticalPadding * 2) * rectangleHeightRatio +
            verticalPadding -
            48;
    const Duration animationDuration = Duration(milliseconds: 500);
    const Curve animationCurve = Curves.easeInOutCubic;

    final bool isExpanded = expandedMode != ExpandedMode.none;
    final brightness = ThemeData.estimateBrightnessForColor(categoryColor);
    final contentColor = brightness == Brightness.dark ? Colors.white : const Color(0xFF121212).withAlpha(200);

    return Stack(
      children: [
        AnimatedPositioned(
          duration: animationDuration,
          curve: animationCurve,
          top: isExpanded ? verticalPadding : rectangleTopY,
          left: rectangleHorizontalPadding,
          right: rectangleHorizontalPadding,
          bottom: verticalPadding,
          child: AnimatedContainer(
            duration: animationDuration,
            curve: animationCurve,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(24.0),
            ),
            child: Consumer(
              builder: (context, ref, child) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: isExpanded
                      ? _buildExpandedContent(context, ref)
                      : Column(
                          key: const ValueKey('details-content'),
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 110.0, bottom: 8.0),
                              child: Text('Wallet Details', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                            ),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 8, 16, 16),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _DetailActionCard(
                                        title: daysRemaining.toString(),
                                        subtitle: 'Days',
                                        onPressed: onDaysPressed,
                                        backgroundColor: cardColor,
                                        titleStyle: TextStyle(fontSize: 58, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.primary),
                                        subtitleStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.primary),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _DetailActionCard(
                                        subtitle: 'Boost',
                                        icon: Icons.rocket_launch,
                                        iconSize: 52,
                                        onPressed: onBoostPressed,
                                        backgroundColor: cardColor,
                                        subtitleStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.primary),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _DetailActionCard(
                                        subtitle: 'Stats',
                                        icon: Icons.bar_chart_outlined,
                                        onPressed: onStatsPressed,
                                        backgroundColor: cardColor,
                                        iconSize: 58,
                                        subtitleStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.primary),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                );
              },
            ),
          ),
        ),
        AnimatedPositioned(
          duration: animationDuration,
          curve: animationCurve,
          top: isExpanded ? -pentagonHeight : 0,
          left: 0,
          right: 0,
          height: pentagonHeight,
          child: ClipPath(
            clipper: _PentagonClipper(
              horizontalPadding: pentagonHorizontalPadding,
              verticalPadding: verticalPadding,
              cornerRadius: cornerRadius,
              rectangleHeightRatio: rectangleHeightRatio,
            ),
            child: Container(
              color: categoryColor,
              child: Align(
                alignment: const Alignment(0.0, -0.2),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Spacer(flex: 3),
                    RichText(
                      text: TextSpan(
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(
                              color: contentColor,
                              fontWeight: FontWeight.w900,
                              fontSize: 40,
                            ),
                        children: <TextSpan>[
                          TextSpan(
                            text:
                                '\$${recommendedSpending.toStringAsFixed(2)}',
                          ),
                          TextSpan(
                            text: ' / day',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: contentColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Recommended',
                      style: TextStyle(
                        color: Colors.black.withAlpha(135),
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                      ),
                    ),
                    const Spacer(flex: 5),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BoostContent extends ConsumerWidget {
  final Category toCategory;
  final VoidCallback onCollapse;
  const _BoostContent({required this.toCategory, required this.onCollapse});

  Future<void> _confirmBoosts(WidgetRef ref) async {
    await ref.read(boostStateProvider(toCategory).notifier).confirmBoosts();
    onCollapse();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boostStateAsync = ref.watch(boostStateProvider(toCategory));
    final availableCategoriesAsync = ref.watch(walletCategoryDataProvider);

    return switch (boostStateAsync) {
      AsyncLoading() => const Center(child: CircularProgressIndicator()),
      AsyncError(:final error) => Center(child: Text('Error: $error')),
      AsyncData(value: final boostData) => switch (availableCategoriesAsync) {
          AsyncLoading() => const Center(child: CircularProgressIndicator()),
          AsyncError() => const Center(child: Text('Could not load categories.')),
          AsyncData(:final value) => ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
                ...value
                    .where((data) => data.category.id != toCategory.id)
                    .where((data) {
                      // Manually calculate the remaining amount for the category
                      final amountRemaining = data.amountRemainingThisWeek;
                      final hasRemaining = amountRemaining > 0.01;
                      
                      // --- FIX: Access the 'currentBoosts' map inside the state object ---
                      final isAlreadyBoosting = boostData.currentBoosts.containsKey(data.category.id);
                      
                      return hasRemaining || isAlreadyBoosting;
                    })
                    .map((data) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: BoostSliderCard(
                            fromCategory: data.category,
                            toCategory: toCategory,
                          ),
                        )),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => _confirmBoosts(ref),
                      label: const Text('Confirm Boosts'),
                      icon: const Icon(Icons.check),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          _ => const SizedBox.shrink(),
        },
      _ => const SizedBox.shrink(),
    };
  }
}

class _DetailActionCard extends StatelessWidget {
  final String? title;
  final String subtitle;
  final IconData? icon;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final double? iconSize;

  const _DetailActionCard({
    required this.subtitle,
    this.title,
    this.icon,
    required this.onPressed,
    required this.backgroundColor,
    this.titleStyle,
    this.subtitleStyle,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    final defaultTitleStyle = const TextStyle(fontWeight: FontWeight.bold);
    final defaultSubtitleStyle = Theme.of(context).textTheme.bodySmall;

    Widget mainContent;
    if (icon != null) {
      mainContent = Icon(
        icon,
        color: Theme.of(context).colorScheme.primary,
        size: iconSize,
      );
    } else {
      mainContent = Text(
        title ?? '',
        style: defaultTitleStyle.merge(titleStyle),
      );
    }

    return SizedBox(
      height: double.infinity,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                SizedBox(
                  height: 80,
                  child: Center(child: mainContent),
                ),
                Text(
                  subtitle,
                  style: defaultSubtitleStyle?.merge(subtitleStyle),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PentagonClipper extends CustomClipper<Path> {
  final double horizontalPadding;
  final double verticalPadding;
  final double cornerRadius;
  final double rectangleHeightRatio;

  _PentagonClipper({
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.cornerRadius,
    required this.rectangleHeightRatio,
  });

  @override
  Path getClip(Size size) {
    final Path path = Path();
    final Offset v1 = Offset(horizontalPadding, verticalPadding);
    final Offset v2 = Offset(size.width - horizontalPadding, verticalPadding);
    final double verticalPartY =
        (size.height - verticalPadding * 2) * rectangleHeightRatio +
            verticalPadding;
    final Offset v3 = Offset(size.width - horizontalPadding, verticalPartY);
    final Offset v4 = Offset(size.width / 2, size.height - verticalPadding);
    final Offset v5 = Offset(horizontalPadding, verticalPartY);

    final p1Start = v1 + (v5 - v1) / (v5 - v1).distance * cornerRadius;
    final p1End = v1 + (v2 - v1) / (v2 - v1).distance * cornerRadius;
    final p2Start = v2 + (v1 - v2) / (v1 - v2).distance * cornerRadius;
    final p2End = v2 + (v3 - v2) / (v3 - v2).distance * cornerRadius;
    final p3Start = v3 + (v2 - v3) / (v2 - v3).distance * cornerRadius;
    final p3End = v3 + (v4 - v3) / (v4 - v3).distance * cornerRadius;
    final p4Start = v4 + (v3 - v4) / (v3 - v4).distance * cornerRadius;
    final p4End = v4 + (v5 - v4) / (v5 - v4).distance * cornerRadius;
    final p5Start = v5 + (v4 - v5) / (v4 - v5).distance * cornerRadius;
    final p5End = v5 + (v1 - v5) / (v1 - v5).distance * cornerRadius;
    path.moveTo(p1Start.dx, p1Start.dy);
    path.quadraticBezierTo(v1.dx, v1.dy, p1End.dx, p1End.dy);
    path.lineTo(p2Start.dx, p2Start.dy);
    path.quadraticBezierTo(v2.dx, v2.dy, p2End.dx, p2End.dy);
    path.lineTo(p3Start.dx, p3Start.dy);
    path.quadraticBezierTo(v3.dx, v3.dy, p3End.dx, p3End.dy);
    path.lineTo(p4Start.dx, p4Start.dy);
    path.quadraticBezierTo(v4.dx, v4.dy, p4End.dx, p4End.dy);
    path.lineTo(p5Start.dx, p5Start.dy);
    path.quadraticBezierTo(v5.dx, v5.dy, p5End.dx, p5End.dy);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}