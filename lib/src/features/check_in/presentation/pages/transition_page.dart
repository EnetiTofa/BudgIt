import 'package:flutter/material.dart';

class TransitionPage extends StatefulWidget {
  final VoidCallback onAutoAdvance;

  const TransitionPage({super.key, required this.onAutoAdvance});

  @override
  State<TransitionPage> createState() => _TransitionPageState();
}

class _TransitionPageState extends State<TransitionPage> {
  int _phase = 0; // 0 = Blank, 1 = Weekly, 2 = Monthly, 3 = Loading

  @override
  void initState() {
    super.initState();
    _playAnimationSequence();
  }

  Future<void> _playAnimationSequence() async {
    // Stage 1: Quick fade in for Weekly Success
    await Future.delayed(const Duration(milliseconds: 150));
    if (mounted) setState(() => _phase = 1);

    // Stage 2: Snappy swap to The Big Reset
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) setState(() => _phase = 2);

    // Stage 3: Swap to Loading / Crunching Numbers
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) setState(() => _phase = 3);

    // Stage 4: Auto-advance to the Review Screen
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) widget.onAutoAdvance();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final lastMonth = DateTime(now.year, now.month - 1, 1);
    final monthNames = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];
    final monthName = monthNames[lastMonth.month - 1];

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: AnimatedSwitcher(
            // Sped up the cross-fade so it doesn't drag
            duration: const Duration(milliseconds: 500),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 0.05), // A more subtle slide
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: _buildPhaseContent(theme, monthName),
          ),
        ),
      ),
    );
  }

  Widget _buildPhaseContent(ThemeData theme, String monthName) {
    switch (_phase) {
      case 1:
        return Column(
          key: const ValueKey('phase1'),
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_rounded,
              size: 88, // Slightly refined icon size
              color: theme
                  .colorScheme
                  .primary, // Using primary color for a more cohesive look
            ),
            const SizedBox(height: 24),
            Text(
              "Weekly Maintenance\nComplete",
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        );

      case 2:
        return Column(
          key: const ValueKey('phase2'),
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_awesome_rounded,
              size: 88,
              color: Colors.amber.shade600,
            ),
            const SizedBox(height: 24),
            Text(
              "Monthly Check in",
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: theme.colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              "Closing out $monthName and generating your report...",
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.secondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        );

      case 3:
        return Column(
          key: const ValueKey('phase3'),
          mainAxisSize: MainAxisSize.min,
          children: [
            // Upgraded, sleeker loading indicator
            SizedBox(
              width: 56,
              height: 56,
              child: CircularProgressIndicator(
                strokeWidth: 4.5,
                strokeCap: StrokeCap.round, // Gives it nice rounded edges
                backgroundColor: theme.colorScheme.primary.withOpacity(
                  0.15,
                ), // Creates a subtle track
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              "Crunching the numbers...",
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.secondary, // Softer text color
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
          ],
        );

      default:
        return const SizedBox.shrink(key: ValueKey('phase0'));
    }
  }
}
